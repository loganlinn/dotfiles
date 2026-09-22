"""Native activity bridge and read-only collector shared by tabs and diagnostics.

State lives on windows, not in user variables. All process discovery and refresh
happen in watcher callbacks/the existing housekeeping timer, never in drawing.
"""
from __future__ import annotations

import os
import re

from kitty.fast_data_types import add_timer, monotonic, remove_timer

# Temporary performance kill switch; implementation retained for later review.
ENABLED = False

ATTR = '_logan_native_activity'
TIMER = '_logan_activity_timer'
SPINNER = re.compile(r'^(?:● )?[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏](?:\s+|$)')
ACTION = re.compile(r'^(?:● )?\[ [!.] \] Action Required(?:\s*\|\s*|$)')
PROGRESS = {'working': 3, 'attention': 4, 'error': 2}
GLYPHS = {'error': '', 'paused': '', 'indeterminate': ''}
CALLBACKS = ('on_close', 'on_resize', 'on_title_change', 'on_cmd_startstop')


def record(w):
    d = getattr(w, ATTR, None)
    if d is None or d.get('version') != 2:
        old = d or {}
        d = dict(version=2, agent=None, session=None, pid=None, hook=None, title=None,
                 title_base=None, title_seen=None, override=None, owned=None, pending={}, tools={}, resolved=[],
                 last_event=None, outcome=None, bell_sent=False, retired=[], retired_pids={}, terminal=False,
                 turn=None, retired_turns=[], sequence=-1, checked=-10.0)
        d.update(old)
        d["version"] = 2
        setattr(w, ATTR, d)
    return d


def signature(w):
    p = w.progress
    return (p.state.value, p.percent, p.last_update_at)


def owns(w, d):
    return d['owned'] is not None and d['owned'] == signature(w)


def dirty(w):
    if (tab := w.tabref()) is not None:
        tab.mark_tab_bar_dirty()


def write_progress(w, state):
    # Invoke Kitty's OSC handler directly. Nothing is written to the child PTY.
    w.desktop_notify(9, memoryview(f'4;{state};0'.encode()))


def release(w, d):
    if owns(w, d):
        write_progress(w, 0)
    d['owned'] = None


def desired(d):
    if d['override'] is not None:
        return d['override'], 'explicit'
    if d['title'] is not None and d['agent'] == 'codex':
        return d['title'], 'codex-title'
    if d['pending']:
        return 'attention', 'hook'
    return d['hook'], 'hook'


def sync(w, refresh=False):
    d = record(w)
    state, _ = desired(d)
    owned = owns(w, d)
    # A different native write, including the same value, revokes ownership.
    if not owned:
        d['owned'] = None
        if w.progress.state.value:
            return
    before = signature(w)
    target = PROGRESS.get(state, 0)
    if not target:
        release(w, d)
    elif not owned or w.progress.state.value != target or refresh:
        write_progress(w, target)
        d['owned'] = signature(w)
    if signature(w) != before:
        dirty(w)


def reset(w, outcome=None):
    d = record(w)
    release(w, d)
    retired = (d['retired'] + ([d['session']] if d['session'] else []))[-32:]
    retired_pids = {s: d['retired_pids'].get(s) for s in retired}
    if d['session']:
        retired_pids[d['session']] = d['pid']
    last_event = d['last_event']
    delattr(w, ATTR)
    d = record(w)
    d.update(retired=retired, retired_pids=retired_pids, last_event=last_event, outcome=outcome)
    dirty(w)


def manual(w, state):
    if not ENABLED:
        return
    if state not in ('working', 'attention', 'idle', 'clear'):
        raise ValueError('invalid activity state')
    d = record(w)
    # clear removes only the manual override; other adapters remain effective.
    d['override'] = None if state == 'clear' else state
    sync(w)
    dirty(w)


def foreground(w):
    """Use Kitty's native process inventory, only outside rendering."""
    for proc in w.child.foreground_processes:
        argv = proc.get('cmdline') or []
        if not argv:
            continue
        name = os.path.basename(argv[0])
        if name in ('node', 'bun') and len(argv) > 1:
            name = os.path.basename(argv[1])
        agent = {'codex': 'codex', 'codex.js': 'codex', 'claude': 'claude',
                 'claude.js': 'claude', 'pi': 'pi'}.get(name)
        if name == 'cli.js' and len(argv) > 1:
            if '/pi-coding-agent/' in argv[1]:
                agent = 'pi'
            elif '/claude-code/' in argv[1]:
                agent = 'claude'
        if agent:
            return agent, proc['pid']
    return None, None


def identify(w, force=False):
    if not ENABLED:
        return
    d = record(w)
    now = monotonic()
    if not force and now - d['checked'] < 5:
        return
    d['checked'] = now
    agent, pid = foreground(w)
    if d['pid'] and d['pid'] != pid:
        reset(w, 'exit')
        d = record(w)
    d['checked'] = now
    if agent:
        d.update(agent=agent, pid=pid)
        if not d['session']:
            d['session'] = f'foreground:{pid}'
    elif d['agent'] and not d['pid']:
        # Hook identity without a process match is valid only during this shell
        # command. on_cmd_startstop clears it; do not guess from output.
        if not w.last_cmd_output_start_time:
            reset(w, 'exit')


def title_changed(w, title):
    d = record(w)
    if d['agent'] != 'codex' or d['title_seen'] == title:
        return
    d['title_seen'] = title
    old = d['title']
    match = ACTION.match(title)
    spinner = SPINNER.match(title)
    if match:
        d['title'] = 'attention'
        base = title[match.end():].strip()
        if base:
            d['title_base'] = base
    elif spinner:
        d['title'] = 'working'
        if old != 'working':
            d['bell_sent'] = False
        d['title_base'] = title[spinner.end():].lstrip(' |').strip()
    elif title == d['title_base'] or title in ('Ready', 'Idle'):
        d['title'] = 'idle'
    else:
        d['title'] = None  # Unrecognized title: fall back to lifecycle hooks.
    if d['title'] != old:
        sync(w)
        if d['title'] == 'idle' and old == 'working' and not d['bell_sent']:
            w.on_bell()
            d['bell_sent'] = True


def request_key(p, elicitation=False):
    keys = ('elicitation_id', 'request_id') if elicitation else ('tool_use_id', 'tool_call_id', 'call_id', 'request_id')
    for key in keys:
        if p.get(key):
            return ('elicitation:' if elicitation else 'tool:') + str(p[key])
    if not elicitation and p.get('tool_fingerprint'):
        return 'tool-fingerprint:' + p['tool_fingerprint']
    # Only match a missing-ID request to the same tool/server, never another tool.
    name = p.get('mcp_server_name') if elicitation else p.get('tool_name')
    return ('elicitation-name:' if elicitation else 'tool-name:') + str(name or 'unknown')


def event(w, agent, p):
    if not ENABLED:
        return
    if agent not in ('codex', 'claude', 'pi') or not isinstance(p, dict) or p.get('agent_id'):
        return
    name = p.get('hook_event_name')
    session = str(p.get('session_id') or p.get('thread_id') or '')
    if not session:
        return  # A delayed anonymous hook cannot safely own a window.
    d = record(w)
    if session in d['retired']:
        # Resuming a conversation can reuse its session ID in a new process.
        # A late SessionStart from the retired process must still be rejected.
        if name != 'SessionStart':
            return
        agent_now, pid_now = foreground(w)
        if agent_now != agent or not pid_now or pid_now == d['retired_pids'].get(session):
            return
        d['retired'].remove(session)
        d['retired_pids'].pop(session, None)
    if not d['session']:
        agent_now, pid_now = foreground(w)
        if agent_now == agent:
            d['pid'] = pid_now
    if d['session'] and d['session'] != session:
        if d['session'].startswith('foreground:') and d['agent'] == agent:
            d['session'] = session
        elif name == 'SessionStart':
            reset(w)
            d = record(w)
        else:
            return
    d.update(agent=agent, session=session)
    seq = p.get('sequence')
    if isinstance(seq, int):
        if seq <= d['sequence']:
            return
        d['sequence'] = seq
    turn = p.get('prompt_id') or p.get('turn_id')
    if turn and turn in d['retired_turns']:
        return
    if turn and d['turn'] and turn != d['turn']:
        if name != 'UserPromptSubmit':
            return
        d['retired_turns'] = (d['retired_turns'] + [d['turn']])[-32:]
    if turn:
        d['turn'] = turn
    d['last_event'] = name
    if name == 'SessionEnd':
        reset(w, 'exit')
        return
    if d['terminal'] and name not in ('UserPromptSubmit', 'SessionStart'):
        return
    if name == 'SessionStart':
        if d['hook'] is not None:
            return
        d['hook'] = 'idle'
    elif name == 'UserPromptSubmit':
        d.update(hook='working', terminal=False, outcome=None, title=None, bell_sent=False)
        d['pending'].clear()
        d['resolved'].clear()
        d['tools'].clear()
    elif name in ('Stop', 'StopFailure', 'Interrupt'):
        d.update(hook='error' if name == 'StopFailure' else 'idle', title=None,
                 terminal=True, outcome={'Stop': 'completed', 'StopFailure': 'failed', 'Interrupt': 'cancelled'}[name])
        d['pending'].clear()
        sync(w)
        if name in ('Stop', 'StopFailure') and not d['bell_sent']:
            w.on_bell()
            d['bell_sent'] = True
        return
    elif name == 'PiState':
        state = p.get('state')
        if state in ('working', 'attention', 'idle'):
            d['hook'] = state
    elif name in ('PermissionRequest', 'Elicitation', 'PreToolUse'):
        tool = str(p.get('tool_name', '')).rsplit('.', 1)[-1]
        waiting = name != 'PreToolUse' or tool in ('AskUserQuestion', 'ExitPlanMode', 'request_user_input')
        key = request_key(p, name == 'Elicitation')
        if key in d['resolved']:
            return
        if name == 'PreToolUse' and p.get('tool_fingerprint'):
            d['tools'][key] = p['tool_fingerprint']
            fingerprint_key = 'tool-fingerprint:' + p['tool_fingerprint']
            if fingerprint_key in d['resolved']:
                d['resolved'].remove(fingerprint_key)
        if waiting:
            d['pending'][key] = name
        d['hook'] = 'working'
    elif name in ('PostToolUse', 'PostToolUseFailure', 'ElicitationResult'):
        key = request_key(p, name == 'ElicitationResult')
        d['pending'].pop(key, None)
        d['tools'].pop(key, None)
        resolved = [key]
        fingerprint = p.get('tool_fingerprint')
        if fingerprint and fingerprint not in d['tools'].values():
            alias = 'tool-fingerprint:' + fingerprint
            d['pending'].pop(alias, None)
            resolved.append(alias)
        # Elicitation can omit its ID on the request but include it on the result.
        if name == 'ElicitationResult' and p.get('mcp_server_name'):
            d['pending'].pop('elicitation-name:' + p['mcp_server_name'], None)
        d['resolved'] = (d['resolved'] + resolved)[-256:]
        d['hook'] = 'working'
        if name == 'PostToolUseFailure':
            d['outcome'] = 'cancelled' if p.get('is_interrupt') else 'tool-failed'
    elif name == 'Notification':
        kind = p.get('notification_type')
        if kind in ('permission_prompt', 'elicitation_dialog'):
            # Notifications lack tool IDs. Do not add a second unresolvable wait
            # if its corresponding request is already known.
            if not d['pending']:
                d['pending'][request_key(p, kind == 'elicitation_dialog')] = name
        elif kind == 'idle_prompt':
            d['hook'] = 'idle'
            if not d['bell_sent']:
                w.on_bell()
                d['bell_sent'] = True
        else:
            return
    else:
        return
    sync(w)


def collect_window(w):
    d = getattr(w, ATTR, {})
    p = w.progress
    native = p.state.value
    owner = bool(d and owns(w, d))
    state = 'attention' if w.needs_attention or native in (2, 4) else 'working' if native in (1, 3) else 'idle'
    source = 'native-progress' if native else 'shell'
    override = d.get('override')
    if native and owner:
        source = desired(d)[1]
    elif not native:
        effective, effective_source = desired(d) if d else (None, 'shell')
        if effective == 'idle':
            source = effective_source
        elif w.last_cmd_output_start_time > 0:
            state = 'running'
    if w.needs_attention and not native:
        state, source = 'attention', 'bell'
    return dict(window_id=w.id, tab_id=w.tab_id, os_window_id=w.os_window_id,
                state=state, source=source, override=override,
                native_bell=w.needs_attention, native_unread=w.has_activity_since_last_focus,
                native_progress=dict(state=p.state.name, percent=p.percent),
                adapter_owns_progress=owner, agent=d.get('agent'), session_id=d.get('session'),
                last_hook_event=d.get('last_event'), outcome=d.get('outcome'),
                pending_requests=list(d.get('pending', {})))


def collect_tab(tab):
    rows = [collect_window(w) for w in tab] if tab is not None else []
    counts = {key: 0 for key in ('bell', 'error', 'paused', 'determinate', 'indeterminate', 'unread', 'running')}
    percentages = []
    for row in rows:
        counts['bell'] += bool(row['native_bell'])
        counts['unread'] += bool(row['native_unread'])
        p = row['native_progress']
        if p['state'] == 'set':
            counts['determinate'] += 1
            percentages.append(p['percent'])
        elif p['state'] in GLYPHS:
            counts[p['state']] += 1
        counts['running'] += row['state'] == 'running'
    state = ('attention' if counts['bell'] or counts['error'] or counts['paused'] else
             'working' if percentages or counts['indeterminate'] else
             'running' if counts['running'] else 'idle')
    return dict(state=state, counts=counts,
                percent=round(sum(percentages) / len(percentages)) if percentages else None)


def indicators(rollup, bell, unread):
    c = rollup['counts']
    def count(symbol, n):
        return symbol.strip() + (str(n) if n > 1 else '') if symbol.strip() and n else ''
    parts = [count(bell, c['bell']), count(GLYPHS['error'], c['error']),
             count(GLYPHS['paused'], c['paused'])]
    if c['determinate']:
        parts.append(f"{rollup['percent']}%" + (f"×{c['determinate']}" if c['determinate'] > 1 else ''))
    parts.extend((count(GLYPHS['indeterminate'], c['indeterminate']), count(unread, c['unread'])))
    return ' '.join(p for p in parts if p)


def on_title_change(boss, w, data):
    if data.get('from_child'):
        identify(w)
        title_changed(w, data['title'])


def on_cmd_startstop(boss, w, data):
    reset(w, None if data['is_start'] else ('completed' if not data.get('exit_status') else 'failed'))
    if data['is_start']:
        record(w)['checked'] = -10.0


def on_close(boss, w, data):
    # Window destruction owns screen teardown; discard bookkeeping only.
    if hasattr(w, ATTR):
        delattr(w, ATTR)


def on_resize(boss, w, data):
    initialize(w)


def initialize(w):
    w.user_vars.pop('tab_activity', None)
    record(w)
    identify(w)
    title_changed(w, w.child_title)


def housekeeping(boss):
    if not ENABLED:
        return
    for w in tuple(boss.window_id_map.values()):
        if getattr(w, 'destroyed', False):
            continue
        identify(w)
        d = record(w)
        title_changed(w, w.child_title)
        if owns(w, d) and monotonic() - w.progress.last_update_at >= 20:
            sync(w, refresh=True)
    for tm in boss.all_tab_managers:
        tm.mark_tab_bar_dirty()


def ensure_timer(boss):
    if not ENABLED:
        return
    if boss is not None and not getattr(boss, TIMER, None):
        setattr(boss, TIMER, add_timer(lambda _: housekeeping(boss), 1, True))


def owned_callback(fn):
    filename = getattr(getattr(fn, '__code__', None), 'co_filename', '')
    owned_files = {os.path.realpath(__file__),
                   os.path.realpath(os.path.join(os.path.dirname(__file__), 'tab_activity.py'))}
    return bool(filename) and os.path.realpath(filename) in owned_files


def install(boss):
    """Replace only our callbacks, including Kitty's cached future-window watchers."""
    if not ENABLED:
        return
    from kitty.window import global_watchers
    from kitty.launch import watcher_modules
    from kitty.tab_bar import load_custom_draw_tab_module
    ctx = load_custom_draw_tab_module().get('_ctx')
    legacy_timer = getattr(ctx, 'timer_id', None)
    if legacy_timer:
        remove_timer(legacy_timer)
        ctx.timer_id = None
    old_timer = getattr(boss, TIMER, None)
    if old_timer:
        remove_timer(old_timer)
        setattr(boss, TIMER, None)
    watchers = [global_watchers.ans, *(w.watchers for w in boss.window_id_map.values())]
    for watcher in watchers:
        for name in (*CALLBACKS, 'on_set_user_var'):
            callbacks = getattr(watcher, name)
            callbacks[:] = [cb for cb in callbacks if not owned_callback(cb)]
            if name in CALLBACKS:
                callbacks.append(globals()[name])
    for path, module in watcher_modules.items():
        watcher_path = os.path.join(os.path.dirname(__file__), 'tab_activity.py')
        if os.path.realpath(path) == os.path.realpath(watcher_path) and isinstance(module, dict):
            module.pop('on_set_user_var', None)
            module.update({name: globals()[name] for name in CALLBACKS})
    for w in boss.window_id_map.values():
        initialize(w)
    ensure_timer(boss)
