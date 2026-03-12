---
name: task-garden
description: Create and maintain agent-friendly task plans in a tasks/ directory using markdown checkboxes. Use when asked to plan work, create task lists, set up project tracking, or organize implementation plans for agent consumption. Produces linked markdown files separating task lists from implementation details, tracks dependencies, and maintains collective learnings.
---

# Task Garden

Initialize or maintain a `tasks/` directory containing agent-consumable task plans.

## Directory Structure

```
tasks/
├── README.md           # Main orchestration file (agent entry point)
├── LEARNINGS.md        # Collective memory: decisions, discoveries, patterns
├── active/             # Tasks currently in progress
│   └── *.md           # Implementation details for active tasks
└── planned/            # Tasks not yet started
    └── *.md           # Implementation details for planned tasks
```

## Creating a New Task Garden

1. Create `tasks/` directory
2. Create `tasks/README.md` from template below
3. Create `tasks/LEARNINGS.md` with empty sections
4. Create `tasks/active/` and `tasks/planned/` directories

### tasks/README.md Template

```markdown
# Task Plan

> **For Agents**: Work on the next unchecked item in Active Tasks. Update checkbox when done.
> Mark tasks blocked with `[~]` and note the blocker. Move tasks between sections as status changes.
> Record significant learnings in [LEARNINGS.md](LEARNINGS.md). Maintain all links.

## Active Tasks

Tasks currently in progress. Work top-to-bottom.

- [ ] Task name → [details](active/task-name.md)
  - Depends on: none
- [ ] Another task → [details](active/another-task.md)
  - Depends on: Task name

## Planned Tasks

Tasks not yet started. Move to Active when ready.

- [ ] Future task → [details](planned/future-task.md)
  - Depends on: Another task

## Completed

- [x] Done task → [details](active/done-task.md)

---

**Link maintenance**: When renaming/moving files, update all references. Run `grep -r "](.*\.md)" tasks/` to find links.
```

### tasks/LEARNINGS.md Template

```markdown
# Learnings

Collective memory for agents. Keep entries concise, factual, and referenced.

## Decisions

| Decision | Rationale | Reference |
|----------|-----------|-----------|
| Example: Use X over Y | Performance in benchmarks | `abc123`, `src/config.ts` |

## Discoveries

- Brief finding with reference (`commit` or `path/to/file`)

## Patterns

Reusable approaches discovered during implementation.

### Pattern Name

Brief description. See `path/to/example`.
```

### Task Detail File Template

```markdown
# Task: Name

## Goal

One sentence describing the outcome.

## Context

Why this matters. Links to relevant code: `src/example.ts:42`

## Approach

1. Step one
2. Step two
3. Step three

## Acceptance

- [ ] Criterion one
- [ ] Criterion two

## Dependencies

- **Blocked by**: [Other task](../active/other.md) (if any)
- **Blocks**: [Future task](../planned/future.md) (if any)

## Notes

Implementation notes, gotchas, or decisions made.
```

## Maintaining the Garden

When working on tasks:

1. **Start work**: Move task from Planned to Active, update links
2. **Complete work**: Check box `[x]`, move to Completed section
3. **Blocked**: Mark with `[~]`, document blocker in detail file
4. **New discovery**: Add to LEARNINGS.md with commit hash or file path
5. **Link check**: After moves/renames, verify all `](*.md)` links resolve

## Agent Instructions Section

Include this block in README.md for agent guidance:

```markdown
> **For Agents**: Work on the next unchecked item in Active Tasks. Update checkbox when done.
> Mark tasks blocked with `[~]` and note the blocker. Move tasks between sections as status changes.
> Record significant learnings in [LEARNINGS.md](LEARNINGS.md). Maintain all links.
```

## Dependency Notation

Show dependencies inline under each task:

```markdown
- [ ] Implement auth → [details](active/auth.md)
  - Depends on: Database schema
- [ ] Add user profile → [details](active/profile.md)
  - Depends on: Implement auth, Database schema
```

For complex dependency graphs, add a section:

```markdown
## Dependency Graph

auth ← profile ← settings
     ↖ dashboard
database ← auth
```

## Writing Style

- **Task names**: Action verb + object ("Implement auth", "Fix pagination")
- **Learnings**: Concise, factual, externally referenced
- **Details**: Minimal prose, maximum actionability
- **References**: Commit hashes (`abc123`), relative paths (`src/foo.ts:42`)
