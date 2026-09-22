// Run with Node >= 22.19.
import assert from 'node:assert/strict';
import extension from '../lib/kitty_activity/pi.ts';
process.env.KITTY_LISTEN_ON = 'unix:/tmp/pi-fixture';
process.env.KITTY_WINDOW_ID = '37';
const callbacks = new Map(), events = new Map(), payloads = [];
extension({
  on: (name, fn) => callbacks.set(name, fn),
  events: { on: (name, fn) => events.set(name, fn) },
  exec: async (cmd, args, opts) => {
    assert.equal(cmd, 'kitty-activity');
    assert.deepEqual(args.slice(0, 3), ['hooks', 'emit', 'pi']);
    assert.deepEqual(args.slice(4), ['--to', 'unix:/tmp/pi-fixture', '--window-id', '37']);
    assert.equal(opts.timeout, 1500);
    payloads.push(JSON.parse(args[3]));
    return {};
  },
});
const fire = (name, idle = false, mode = 'tui', event = {}) => callbacks.get(name)(event, {mode, isIdle: () => idle});
await fire('session_start', true, 'rpc');
await fire('agent_start');
assert.deepEqual(payloads, []);
await fire('session_start', true);
await fire('agent_start');
assert.equal(payloads.at(-1).state, 'working');
events.get('kitty-activity:attention')({id:'one', active:true});
events.get('kitty-activity:attention')({id:'two', active:true});
events.get('kitty-activity:attention')({id:'one', active:false});
await new Promise(resolve => setImmediate(resolve));
assert.equal(payloads.at(-1).state, 'attention');
events.get('kitty-activity:attention')({id:'two', active:false});
await new Promise(resolve => setImmediate(resolve));
assert.equal(payloads.at(-1).state, 'working');
await fire('agent_settled', false);
assert.equal(payloads.at(-1).state, 'working');
await fire('agent_settled', true);
assert.equal(payloads.at(-1).hook_event_name, 'Stop');
await fire('agent_start');
await fire('message_end', false, 'tui', {message:{role:'assistant', stopReason:'aborted'}});
await fire('agent_settled', true);
assert.equal(payloads.at(-1).hook_event_name, 'Interrupt');
await fire('agent_start');
await fire('message_end', false, 'tui', {message:{role:'assistant', stopReason:'error'}});
await fire('agent_settled', true);
assert.equal(payloads.at(-1).hook_event_name, 'StopFailure');
await fire('session_shutdown');
assert.equal(payloads.at(-1).hook_event_name, 'SessionEnd');
assert.equal(new Set(payloads.map(p => p.session_id)).size, 1);
for(let i=1;i<payloads.length;i++) assert.ok(payloads[i].sequence > payloads[i-1].sequence);
console.log('pi lifecycle, completion/cancellation/failure, nested input, TUI gate, targeting and ordering passed');
