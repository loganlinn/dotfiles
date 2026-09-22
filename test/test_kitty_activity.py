"""Run with installed Kitty +runpy; exercises its real Progress and Screen types."""
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace as NS
from unittest.mock import Mock, patch

from kitty.fast_data_types import Screen, set_options
from kitty.options.types import defaults
from kitty.progress import Progress
from kitty.tab_bar import ExtraData, TabBarData, as_rgb
from kitty.window import Watchers

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'config/kitty'))
import kitty_activity_state as a


class Window:
    def __init__(self, id=1, *, started=False, bell=False, unread=False, progress=0, percent=0):
        self.id = id
        self.tab_id = self.os_window_id = 1
        self.user_vars = {}
        self.progress = Progress()
        self.progress.update(progress, percent)
        self.needs_attention = bell
        self.has_activity_since_last_focus = unread
        self.last_cmd_output_start_time = 123 if started else 0
        self.child = NS(foreground_processes=[])
        self.child_title = ''
        self.watchers = Watchers()
        self.tab = NS(mark_tab_bar_dirty=Mock())
        self.tabref = lambda: self.tab
        self.is_active = False
        self.writes = self.bells = 0

    def desktop_notify(self, code, raw):
        assert code == 9
        _, state, percent = bytes(raw).decode().split(';')
        self.progress.update(int(state), int(percent))
        self.writes += 1

    def on_bell(self):
        self.bells += 1
        if not self.is_active:
            self.needs_attention = True


class BridgeTests(unittest.TestCase):
    def send(self, w, event, **kw):
        a.event(w, kw.pop('agent', 'claude'), dict(session_id='one', hook_event_name=event, **kw))

    def test_mixed_rollup_and_unread_is_not_work(self):
        windows = [Window(progress=1, percent=20), Window(progress=1, percent=80),
                   Window(progress=4, percent=99), Window(progress=3), Window(progress=3),
                   Window(progress=2), Window(bell=True, unread=True)]
        r = a.collect_tab(windows)
        self.assertEqual(r['percent'], 50)
        self.assertEqual(a.indicators(r, 'B ', 'U '), 'B   50%×2 2 U')
        self.assertEqual(a.collect_tab([Window(unread=True)])['state'], 'idle')
        self.assertEqual(a.collect_tab([])['state'], 'idle')

    def test_external_native_progress_survives_cleanup_even_same_state(self):
        for state in (1, 2, 3, 4):
            w = Window(started=True)
            a.manual(w, 'working')
            w.progress.update(state, 75)
            snapshot = a.signature(w)
            a.manual(w, 'idle')
            a.manual(w, 'clear')
            a.reset(w)
            self.assertEqual(snapshot, a.signature(w))
            self.assertEqual(a.collect_window(w)['source'], 'native-progress')

    def test_idle_suppresses_shell_fallback_and_clear_restores_it(self):
        w = Window(started=True)
        a.manual(w, 'working')
        a.manual(w, 'idle')
        self.assertEqual(a.collect_window(w)['state'], 'idle')
        a.manual(w, 'clear')
        self.assertEqual(a.collect_window(w)['state'], 'running')

    def test_parallel_and_out_of_order_requests(self):
        w = Window()
        self.send(w, 'PermissionRequest', tool_use_id='a')
        self.send(w, 'PermissionRequest', tool_use_id='b')
        self.send(w, 'PostToolUse', tool_use_id='other')
        self.assertEqual(w.progress.state.value, 4)
        self.send(w, 'PostToolUse', tool_use_id='a')
        self.assertEqual(w.progress.state.value, 4)
        self.send(w, 'PostToolUse', tool_use_id='b')
        self.assertEqual(w.progress.state.value, 3)
        self.send(w, 'PermissionRequest', tool_use_id='a')
        self.assertEqual(w.progress.state.value, 3)
        self.send(w, 'Elicitation', elicitation_id='x')
        self.send(w, 'PostToolUse', tool_use_id='x')
        self.assertEqual(w.progress.state.value, 4)
        self.send(w, 'ElicitationResult', elicitation_id='x')
        self.assertEqual(w.progress.state.value, 3)

    def test_permission_without_id_uses_input_fingerprint(self):
        w = Window()
        self.send(w, 'PreToolUse', tool_use_id='a', tool_name='Bash', tool_fingerprint='input-a')
        self.send(w, 'PreToolUse', tool_use_id='b', tool_name='Bash', tool_fingerprint='input-b')
        self.send(w, 'PermissionRequest', tool_name='Bash', tool_fingerprint='input-a')
        self.send(w, 'PostToolUse', tool_use_id='b', tool_name='Bash', tool_fingerprint='input-b')
        self.assertEqual(w.progress.state.value, 4)
        self.send(w, 'PostToolUse', tool_use_id='a', tool_name='Bash', tool_fingerprint='input-a')
        self.assertEqual(w.progress.state.value, 3)
        self.send(w, 'PermissionRequest', tool_name='Bash', tool_fingerprint='input-a')
        self.assertEqual(w.progress.state.value, 3)
        # A new call with the same input is a new request.
        self.send(w, 'PreToolUse', tool_use_id='c', tool_name='Bash', tool_fingerprint='input-a')
        self.send(w, 'PermissionRequest', tool_name='Bash', tool_fingerprint='input-a')
        self.assertEqual(w.progress.state.value, 4)


    def test_completion_cancel_failure_and_session_tombstone(self):
        for name, outcome, state, bells in [('Stop', 'completed', 0, 1),
                ('Interrupt', 'cancelled', 0, 0), ('StopFailure', 'failed', 2, 1)]:
            w = Window()
            self.send(w, 'UserPromptSubmit')
            self.send(w, name)
            self.send(w, name)
            self.send(w, 'PostToolUse', tool_use_id='late')
            self.assertEqual(w.progress.state.value, state)
            self.assertEqual(w.bells, bells)
            self.assertEqual(a.record(w)['outcome'], outcome)
            self.send(w, 'SessionEnd')
            self.send(w, 'UserPromptSubmit')
            self.assertEqual(w.progress.state.value, 0)

    def test_codex_title_identity_phases_idle_and_hook_fallback(self):
        w = Window()
        a.title_changed(w, '⠋ project')
        self.assertEqual(w.progress.state.value, 0)
        self.send(w, 'SessionStart', agent='codex')
        for title in ('⠋ project', '⠙ project', '[ ! ] Action Required | project', '[ . ] Action Required | project'):
            a.title_changed(w, title)
        self.assertEqual(w.progress.state.value, 4)
        self.send(w, 'PreToolUse', agent='codex', tool_name='Bash')
        self.assertEqual(w.progress.state.value, 4)
        w.is_active = True
        w.needs_attention = False
        self.assertEqual(w.progress.state.value, 4)
        a.title_changed(w, '⠹ project')
        self.assertEqual(w.progress.state.value, 3)
        a.title_changed(w, 'project')
        self.assertEqual(w.progress.state.value, 0)
        a.title_changed(w, 'unrelated editor title')
        self.assertEqual(w.progress.state.value, 3)
        self.assertEqual(a.collect_window(w)['source'], 'hook')

    def test_title_completion_and_hook_do_not_ring_twice(self):
        w = Window()
        self.send(w, 'SessionStart', agent='codex')
        a.title_changed(w, '⠋ project')
        a.title_changed(w, 'project')
        self.send(w, 'Stop', agent='codex')
        self.assertEqual(w.bells, 1)

    def test_dedup_and_quiet_work_heartbeat(self):
        w = Window(started=True)
        self.send(w, 'UserPromptSubmit')
        for _ in range(10):
            self.send(w, 'PreToolUse', tool_name='Bash')
        self.assertEqual(w.writes, 1)
        boss = NS(window_id_map={1:w}, all_tab_managers=[])
        for _ in range(4):
            w.progress.last_update_at -= 21
            a.record(w)['owned'] = a.signature(w)
            a.housekeeping(boss)
            self.assertEqual(w.progress.state.value, 3)
            self.assertFalse(w.progress.clear_progress())
        self.assertEqual(w.writes, 5)
        w.progress.update(1, 33)
        a.housekeeping(boss)
        self.assertEqual(w.progress.percent, 33)

    def test_shell_end_exit_and_removal(self):
        w = Window(started=True)
        w.child.foreground_processes = [{'pid':123, 'cmdline':['/bin/codex']}]
        a.identify(w, True)
        a.title_changed(w, '⠋ project')
        self.assertEqual(a.record(w)['agent'], 'codex')
        w.child.foreground_processes = []
        a.identify(w, True)
        self.assertEqual(w.progress.state.value, 0)
        a.manual(w, 'attention')
        a.on_cmd_startstop(None, w, {'is_start':False, 'exit_status':0})
        self.assertEqual(w.progress.state.value, 0)
        a.on_close(None, w, {})
        self.assertFalse(hasattr(w, a.ATTR))

    def test_stale_title_after_completion_does_not_restart_work(self):
        w = Window(started=True)
        self.send(w, 'SessionStart', agent='codex')
        a.title_changed(w, '⠋ project')
        self.send(w, 'Stop', agent='codex')
        a.title_changed(w, '⠋ project')
        self.assertEqual(w.progress.state.value, 0)

    def test_reload_retains_unrelated_callbacks_and_single_timer(self):
        import kitty.window
        import kitty.launch
        import kitty.tab_bar
        w = Window()
        namespace = {}
        exec(compile('def unrelated(*args): pass', '/tmp/unrelated/tab_activity.py', 'exec'), namespace)
        unrelated = namespace['unrelated']
        w.watchers.on_title_change = [unrelated, a.on_title_change, a.on_title_change]
        boss = NS(window_id_map={1:w}, all_tab_managers=[])
        legacy = NS(timer_id=88)
        original = kitty.window.global_watchers.ans
        kitty.window.global_watchers.ans = Watchers()
        try:
            with patch.object(a, 'add_timer', return_value=99) as add, \
                 patch.object(a, 'remove_timer') as remove, \
                 patch.object(kitty.tab_bar, 'load_custom_draw_tab_module', return_value={'_ctx':legacy}):
                a.install(boss)
                a.ensure_timer(boss)
                a.install(boss)
                self.assertEqual(add.call_count, 2)
                self.assertEqual([c.args[0] for c in remove.call_args_list], [88, 99])
                self.assertEqual(w.watchers.on_title_change, [unrelated, a.on_title_change])
        finally:
            kitty.window.global_watchers.ans = original


    def test_resumed_session_requires_a_new_foreground_process(self):
        w = Window(started=True)
        w.child.foreground_processes = [{'pid':1, 'cmdline':['codex']}]
        self.send(w, 'SessionStart', agent='codex')
        self.send(w, 'SessionEnd', agent='codex')
        self.send(w, 'SessionStart', agent='codex')
        self.assertIsNone(a.record(w)['session'])
        w.child.foreground_processes = [{'pid':2, 'cmdline':['codex']}]
        self.send(w, 'SessionStart', agent='codex')
        self.send(w, 'UserPromptSubmit', agent='codex')
        self.assertEqual(w.progress.state.value, 3)
        self.assertEqual(a.record(w)['pid'], 2)


    def test_pi_sequences_and_old_turn_events(self):
        w = Window()
        self.send(w, 'SessionStart', agent='pi', sequence=1)
        self.send(w, 'UserPromptSubmit', agent='pi', sequence=3, turn_id='new')
        self.send(w, 'PiState', agent='pi', sequence=2, state='attention')
        self.assertEqual(w.progress.state.value, 3)
        self.send(w, 'UserPromptSubmit', agent='pi', sequence=4, turn_id='newer')
        self.send(w, 'Stop', agent='pi', sequence=5, turn_id='new')
        self.assertEqual(w.progress.state.value, 3)


class RendererTests(unittest.TestCase):
    def setUp(self):
        set_options(defaults)
        path = ROOT/'config/kitty/tab_bar.py'
        self.m = {'__name__':'activity_renderer_test', '__file__':str(path)}
        exec(compile(path.read_text(), str(path), 'exec'), self.m)
        self.tabs = {}
        self.boss = NS(tab_for_id=self.tabs.get, all_tabs=[])
        self.m['get_boss'] = lambda: self.boss
        self.m['ensure_timer'] = Mock()
        self.m['_tab_flag_color'] = lambda id: None

    def tearDown(self):
        set_options(None)

    def render(self, windows, active=False, limit=80):
        self.tabs[1] = windows
        ctx = self.m['DrawTabContext']()
        ctx._tab_title = lambda: ('directory/', 'project')
        ctx._draw_left_status = lambda bg: 0
        ctx._draw_right_status = lambda: None
        screen = Screen(None, 1, 100, 0)
        ctx.set_context(None, screen, TabBarData(title='project', tab_id=1, is_active=active), 0, limit, 1, True, ExtraData())
        ctx.draw()
        line = screen.line(0)
        return str(line), line.cursor_from(1), screen.cursor.x

    def test_work_is_steady_bright_and_attention_contrasts(self):
        for _ in range(3):
            _, cursor, _ = self.render([Window(progress=3)])
            self.assertEqual(cursor.fg, as_rgb(self.m['FG']))
        for active in (False, True):
            _, cursor, _ = self.render([Window(progress=4)], active)
            self.assertEqual(cursor.fg, as_rgb(self.m['SELECTED_ATTENTION_FG'] if active else self.m['RED']))
            self.assertEqual(cursor.bg, as_rgb(self.m['PURPLE'] if active else self.m['DARK']))

    def test_narrow_unicode_tabs_never_overflow(self):
        for limit in range(1, 24):
            text, _, end = self.render([Window(progress=4), Window(progress=3)], limit=limit)
            self.assertLessEqual(end, limit, text)
        text, _, _ = self.render([Window(progress=4), Window(progress=3)])
        self.assertLess(text.index(''), text.index(''))
        self.assertIn('directory/project', text)

    def test_tab_isolation_and_no_process_discovery_in_draw(self):
        w = Window(progress=3)
        self.tabs[2] = [Window(progress=4)]
        with patch.object(a, 'foreground', side_effect=AssertionError('drawing inspected processes')):
            self.render([w])
            self.assertEqual(self.m['_tab_activity'](2)['state'], 'attention')
            self.assertEqual(self.m['_tab_activity'](1)['state'], 'working')


if __name__ == '__main__':
    unittest.main(argv=['test_kitty_activity'])
