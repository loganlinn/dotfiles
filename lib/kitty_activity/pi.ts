// Managed by kitty-activity hooks; v1
// Changes here are replaced by 'kitty-activity hooks install pi'.
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const socket = process.env.KITTY_LISTEN_ON;
  const window = process.env.KITTY_WINDOW_ID;
  if (!socket || !window || !/^[1-9][0-9]*$/.test(window)) return;

  let enabled = false;
  let active = false;
  let sequence = 0;
  let session = "";
  let lastState = "";
  let outcome = "completed";
  const waiting = new Set<string>();
  let queue = Promise.resolve();
  const publish = (state: string, event = "PiState") => {
    if (event === "PiState" && lastState === state) return queue;
    lastState = state;
    const payload = JSON.stringify({ session_id: session, sequence: ++sequence,
      hook_event_name: event, state });
    // Capture payload before queueing; serialize delivery across session changes.
    queue = queue.then(async () => {
      try {
        await pi.exec("kitty-activity", ["hooks", "emit", "pi", payload,
          "--to", socket, "--window-id", window], { timeout: 1500 });
      } catch { /* Status failures must not interrupt the agent. */ }
    });
    return queue;
  };
  const refresh = () => publish(waiting.size ? "attention" : active ? "working" : "idle");

  pi.on("session_start", async (_event, ctx) => {
    enabled = ctx.mode === "tui";
    if (!enabled) return;
    session = `${process.pid}:${Date.now()}:${++sequence}`;
    lastState = "";
    await publish("idle", "SessionStart");
    active = !ctx.isIdle();
    outcome = "completed";
    waiting.clear();
    await refresh();
  });
  pi.on("agent_start", async () => {
    if (!enabled) return;
    active = true;
    outcome = "completed";
    await publish("working", "UserPromptSubmit");
    await refresh();
  });
  pi.on("message_end", async (event) => {
    if (!enabled || event.message.role !== "assistant") return;
    if (event.message.stopReason === "aborted") outcome = "cancelled";
    else if (event.message.stopReason === "error") outcome = "failed";
  });
  pi.on("agent_settled", async (_event, ctx) => {
    if (!enabled || !ctx.isIdle()) return;
    active = false;
    waiting.clear();
    await publish("idle", outcome === "failed" ? "StopFailure" : outcome === "cancelled" ? "Interrupt" : "Stop");
  });
  pi.on("session_shutdown", async () => {
    if (!enabled) return;
    enabled = false;
    await publish("idle", "SessionEnd");
  });
  // Custom dialogs have no global lifecycle event. Their owners can emit this.
  pi.events.on("kitty-activity:attention", (data: unknown) => {
    if (!enabled || !data || typeof data !== "object") return;
    const request = data as { id?: unknown; active?: unknown };
    if (typeof request.id !== "string" || typeof request.active !== "boolean") return;
    if (request.active) waiting.add(request.id);
    else waiting.delete(request.id);
    void refresh();
  });
}
