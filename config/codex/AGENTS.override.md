# Working agreements

- If a skill causes you to ask for permission or confirmation, pause, leave requested work unfinished, or diverge from the user's intent, name and link to the exact SKILL.md file you read, quote the relevant instruction, and briefly explain how it applies. Distinguish explicit skill requirements from your interpretation of guidelines.
- Ask for confirmation before pushing pushing git commits to `main` branch, pushing to image to remote registry used by production service, executing SQL on production database server, or directly modifying AWS IAM or Identity Center resources.
- Prefer `uv` when running installing dependencies.
- Prefer git rebase over git merge
- Date-times in prose should prefer/include local timezone (PST), not just UTC.
- Finding source code locally, such as when I reference source code of a dependency or comparison to current project: `~/src/${HOST}/${OWNER}/${REPO}`, i.e. `~/src/github.com/loganlinn/agents`

# Repository documentation

- Write documentation for lasting use: explain purpose, rationale, interfaces, constraints, and repeatable workflows.
- Keep transient implementation history in commit messages, PR descriptions, or task discussions. Do not commit rollout narration, one-off validation results, or incidental ordering such as "the first candidate" or "the first application" to enduring documentation.
- Repository instructions should be reusable. Avoid single-use directions and temporary status notes that become obsolete when the current change is completed. Link to authoritative configuration instead of duplicating details maintained there.
- Deliberately temporal or sequential documents, such as migration plans, incident timelines, and work journals, are exceptions. Make their scope and temporal nature explicit; do not let them read as standing instructions.

# Git worktrees

- You are highly competent with git worktrees, but do not implicitly treat every task/objective as needing a new worktree. I will explicitly request work to be done in a new worktree. The base branch for the worktree should be clear from the request, otherwise request clarification. Typically it will be off latest trunk (main) branch, but common exception is when splitting/stacking ongoing work. Clearly announce when you switch context to a different worktree.
- Use `gmx` for agent-managed Git worktree creation and initialization in both the Codex CLI and native app.
- When a task requires a new worktree, run `gmx config show` in the target repository, then `gmx create <name>`. Let gmx resolve the directory, branch prefix, base ref, install specs, and hooks unless the user explicitly requests an override.
- Capture the worktree path returned by gmx and use it as the working directory for subsequent commands and edits. Read the applicable repository instructions there before making changes.
- `gmx create` already initializes the worktree. Run `gmx install --yes` in an existing worktree only when it needs initialization or the user requests it.
- Reuse the current task worktree when one is already provided. If Codex started in a native managed worktree, use that worktree and initialize it with gmx when needed rather than creating another one.
- If gmx fails, diagnose the failure before proceeding; do not silently bypass it with `git worktree add` or hand-written initialization.

# Terraform

- When terraform configuration uses workspaces, explicitly set `TF_WORKSPACE` when executing/scripting `terraform` command, rather than using `terraform workspace` for reproducibility. This is not needed for `atmos`.
- Terraform test coverage is NON-goal. Outside of policy-based testing (rego, opa, et al) should be considered tautological test anti-pattern; prefer to boycott existing convention. OK if helpful at devtime. If CI is red because of non-policy TF test, targeted removal is preferred remediation.
- When Terraform providers fail to create Unix sockets, run Terraform with `TMPDIR="$PLUGIN_UNIX_SOCKET_DIR"` if that variable is set.

# Computer use

- Avoid unless asked to use. If you're asked to open something in browser, use macOS `open` command with the URL.

# Testing

- Actively decide state your intentions when writing tests. Remain intellectually honest with whether a test belongs in the codebase or whether it's utility was limited to development task (does it break if the code evolves naturally?). Contribute tests to the codebase when defensible that it they reduces of regression.

# Manifesto

- We _care_ about the codebase and are willing to challenge the status quo when pragmatic to do so.

# Local infrastructure references

- When working with Terraform or Atmos, look for relevant local upstream source
  under ~/src/github.com/cloudposse-terraform-components/,
  ~/src/github.com/cloudposse/, and ~/src/github.com/terraform-aws-modules/.

- Read ~/src/github.com/cloudposse-terraform-components/AGENTS.md for workspace
  context. Its repositories.txt lists organization repositories as of the time
  it was written; only some are cloned locally. Check upstream before concluding
  that a suitable component does not exist.

- Use local checkouts for source inspection, verifying their revision against
  the version being evaluated or consumed. Local paths are discovery aids,
  not dependency sources to embed in shared configuration.

- When working in a repository, read its root AGENTS.local.md if present,
  in addition to the shared agent instructions.

# Tools

- Use the 1Password Environments MCP Server if you need to work with the 1Password developer environments without me having to explicitly ask.

# Forward-looking

- the gamma-app/platform repo is currently still in use as of 2026-11-21, but we have comitted to migrating to be embedded inside the gamma-app/gamma monorepo. Keep this in mind when making suggestions by checking if there are long-implications to the solution that would increase migraiton scope or otherwise capture our transient state as artifact that would go stale.

<!-- x-pub: gist:67fd05268798a6d2832a2a6bd90e1fc0?file=AGENTS.override.md -->

<!-- plannotator-inbox:start v9 · added by Plannotator. Remove it in the Inbox's Settings or with `plannotator uninstall` -->
## Plannotator Inbox

The person keeps a Plannotator Inbox on this computer: a window where they read what agents send and answer when they can.
If you have a `plannotator_inbox` tool or a `plannotator-inbox` MCP server, use its `send_message` to ask a decision only they can make (as a `:::question` block) or to hand over finished long work (a short summary with its pictures in place, `![alt](path)` in the body, and the files to read in `attachments`). Then keep working.
A decision inside a report or summary still goes in a `:::question` block, one block per decision.
When you mention an issue or PR outside the repo you started in, write owner/repo#123 or its full URL every time; a bare #123 links to your own repo.
Their reply comes back to this session by itself where your agent supports that; otherwise read the thread later with `read_thread`.
Be proactive about Inbox updates and about replying to the person through the Inbox when you think they would want you to. Don't withhold important updates or decisions, and don't batch updates to send later: proactivity is better than procrastination.
One thread per work stream, unless the person says otherwise.
A decision you sent to the Inbox stays there. When the person writes in this chat, say what is waiting there (a short summary and the thread's link), but never also ask it in the chat with a blocking question tool (AskUserQuestion or similar): that blocks the chat and splits the answer. Ask in the chat only about something new they raised here that needs no pictures or files, or when they ask for it.
Before reply_to into a thread you have not read in this context window, call read_thread with no id and match the subject.
In a `:::question` block, keep the choices in their natural order and never move your recommendation first; put it on its own line after the choices as `Recommended: <label>`, and never write "(recommended)" in a choice label.
<!-- plannotator-inbox:end -->
