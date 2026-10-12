# Agent hooks through mise

Native plugins/extensions register events; global mise tasks implement the hooks.
Claude, Codex, pi, and oh-my-pi use the same tasks, layered on the current
project's `mise.toml` and `mise.agent-<agent>.toml` (`claude`, `codex`, `omp`, or `pi`).
Shared environment and tools belong
in `config/mise/config.agent.toml`; included config files cannot contain tasks
or task templates, so those live in `config/mise/tasks/agent-hooks.toml` and
`config/mise/conf.d/agent-hooks.toml`.

## Install and manage

From this dotfiles checkout, bootstrap all four agents:

```sh
mise run --skip-tools agent:hooks:bootstrap
```

After bootstrap, these work from any directory:

```sh
mise -E agent-claude run --skip-tools agent:hooks:install
mise -E agent-codex run --skip-tools agent:hooks:install
mise -E agent-omp run --skip-tools agent:hooks:install
mise -E agent-pi run --skip-tools agent:hooks:install
mise -E agent-codex run --skip-tools agent:hooks:status
mise -E agent-codex run --skip-tools agent:hooks:update
mise -E agent-codex run --skip-tools agent:hooks:uninstall
```

Replace `agent-codex` with `agent-claude`, `agent-omp`, or `agent-pi` for the other agents. `--skip-tools` keeps
management commands from installing unrelated tools from the current project;
the prepare task explicitly installs the pinned hook dependencies. The pi/omp
tasks do not require Claude's manifest validator.

| Environment | Native registration | Default user location |
| --- | --- | --- |
| `agent-claude` | `agent-hooks@dotfiles` plugin | `~/.claude` |
| `agent-codex` | `agent-hooks@dotfiles` plugin | `~/.codex` |
| `agent-omp` | `dotfiles-agent-hooks` via `omp plugin link` | `~/.omp/plugins` |
| `agent-pi` | Local `packages/pi-family` package via `pi install` | `~/.pi/agent/settings.json` |

Claude/Codex installation registers the local `dotfiles` marketplace. pi and
oh-my-pi load the same local package in place, each using its own manifest key
(`pi` or `omp`). Native CLI commands own registration and removal; existing
settings and extensions are retained. No extra symlinks into `~/.pi/agent/extensions`
or `~/.omp/agent/extensions` are needed. Native directory/profile overrides are
honored by their CLIs.

Removing the plugin/package removes its event bindings; it leaves the
marketplace, shared tasks, installed tools, and other plugins/settings intact.
Use a new agent session after installing or updating. Codex additionally tracks
trust per hook: review `agent-hooks@dotfiles` in `/hooks` if it needs approval.

The framework installs with **no active hooks**: the Claude/Codex hook files
and both pi/omp extension lists are empty. No extension module is loaded by
the pi-family package. The shared `agent:hook:atuin` and `agent:hook:activity` tasks are available
to run explicitly, but neither is registered with an agent. Atuin bindings are
provided under `examples/` for later opt-in; installing or updating the plugin
does not load those examples. The existing `kitty-activity` script remains
responsible for its own disabled state. These tasks do not install either
tool's legacy standalone hook registrations. The existing Atuin JSON task is
for Claude/Codex; Atuin's pi integration is a TypeScript extension, not
`atuin hook pi`. Do not route pi/omp events to the Claude/Codex JSON parser
without an explicit adapter.

Launch each agent with its mise environment:

```sh
mise -E agent-claude exec -- claude
mise -E agent-codex exec -- codex
mise -E agent-omp exec -- omp
mise -E agent-pi exec -- pi
```

Launching this way supplies the selected tools and environment to the agent
and its shell subprocesses. Loading a plugin by itself does not initialize
the agent's shell environment.

The `agent-*` selectors load global overlays named `config.agent-<agent>.toml`,
which include the shared `config.agent.toml`. They also load the project's base
`mise.toml` and matching `mise.agent-<agent>.toml` overlay. Existing bare overlays
such as `mise.codex.toml` or `mise.pi.toml` are no longer selected automatically;
rename them to match, or select both environments explicitly:

```sh
mise -E pi,agent-pi exec -- pi
```

Using only `agent-pi` also avoids selecting the existing `~/mise.pi.toml`.
Selecting `pi,agent-pi` includes that file and requires its encrypted credentials
to be decryptable.

## Add a hook

1. Define a shared task in `config/mise/tasks/agent-hooks.toml`. Extend
   `agent:hook` to retain the caller's working directory. Put hook-specific
   dependencies in `tools` and `env`, and add the tool pins to `agent:hooks:prepare`.
2. When you want to enable it, bind the native event in
   `plugins/agent-hooks/hooks/claude.json` and/or `codex.json`. Keep each agent's
   event names, matchers, and timeouts here. The Atuin examples show Claude's
   additional `PostToolUseFailure` binding; Codex currently exposes only
   `PreToolUse` and `PostToolUse` for this purpose.
3. Bump both plugin manifest versions and the marketplace entry, then run
   `agent:hooks:update` for each agent. Task edits take effect immediately through
   the global symlinks; installed plugin manifests may be cached.

For pi/oh-my-pi, put TypeScript or JavaScript entry points in
`packages/pi-family/src/` and explicitly add them to `pi.extensions` and/or
`omp.extensions` in that package's `package.json`. Keeping code under `src/`
avoids convention-based extension discovery. These arrays are independent;
use separate entry points for agent-specific bindings and import shared logic.
Register native events with the extension API (for example `tool_call` and
`tool_result`), and invoke mise with the explicit `agent-pi` or `agent-omp` environment
and `ctx.cwd`. Use `node:child_process` with a piped stdin to send event JSON;
the installed pi version's `pi.exec` API does not accept stdin. Return decisions
through each agent's native extension API; Claude hook JSON and exit code 2
are not automatically interpreted as pi/omp extension decisions. Local package
edits take effect on `/reload` or a new session; the update task refreshes only
this local registration and never upgrades the agent or unrelated packages.

Native references: [pi packages](https://pi.dev/docs/latest/packages),
[oh-my-pi extension loading](https://github.com/can1357/oh-my-pi/blob/main/docs/extension-loading.md).

The example hook commands select the agent environment explicitly, even if the agent was
launched from a GUI. They use the dotfiles mise launcher to avoid depending on
the agent's initial PATH. `--raw --quiet` passes native JSON through stdin and
stdout without task prefixes. `--skip-tools`, `MISE_AUTO_INSTALL=0`, and
`MISE_OFFLINE=1` keep tool downloads out of hook execution. Prepare tools before
using them; missing tools should be diagnosed outside the five-second hook path.

Atuin and activity are observational, so their bindings/tasks tolerate failure.
For a future blocking hook, remove `|| true`, preserve its exit code (including
2), and emit only the agent's documented JSON on stdout. Send diagnostics to
stderr. A native event gives each registered hook its own JSON input. Mise task
dependencies do not broadcast stdin or export their environment to later tasks:
if several dependent tasks need the payload, have an entry task capture it once
in a private temporary file and pass its path, with one final task emitting JSON.

Project configs may override these global task names and templates. Treat the
project's mise configuration as executable code, just like other mise tasks.
