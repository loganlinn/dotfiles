---
name: new-skill
description: Create new skills (slash commands) with proper directory structure and SKILL.md template. Use when the user asks to create, scaffold, or initialize a new skill or slash command. Supports optional project and scope arguments to control where the skill is created.
---

# New Skill

Create new skills (slash commands) with proper structure and template files.

## Usage

The user will invoke this skill with:
- `/new-skill <name>` - Create a user-scoped skill
- `/new-skill <name> --project <project>` - Create in specific project
- `/new-skill <name> --scope user|project` - Explicitly set scope

## Arguments

- `name` (required): Name of the skill to create (kebab-case)
- `--project` (optional): Project path or name
- `--scope` (optional): Either "user" or "project" (defaults to "user" if not specified)

## Process

1. **Parse arguments** from the user's request:
   - Extract skill name (required)
   - Extract project path if provided
   - Extract scope if provided (defaults to "user")

2. **Determine output directory**:
   - User scope: `~/.claude/skills/<name>/`
   - Project scope with project: `<project>/.claude/skills/<name>/`
   - Project scope without project: Use current working directory as project root

3. **Run init_skill.py**:
   ```bash
   ~/.claude/skills/skill-creator/scripts/init_skill.py <name> --path <output-directory>
   ```

4. **Inform the user**:
   - Report the created skill location
   - Remind them to edit SKILL.md
   - Suggest next steps (edit, add resources, package)

## Example Workflows

**Create user skill:**
```
User: /new-skill pdf-editor
→ Creates ~/.claude/skills/pdf-editor/
```

**Create project skill:**
```
User: /new-skill api-client --scope project
→ Creates ./.claude/skills/api-client/ in current project
```

**Create in specific project:**
```
User: /new-skill deploy-helper --project ~/myapp
→ Creates ~/myapp/.claude/skills/deploy-helper/
```

## Error Handling

- If skill name is missing, ask the user for it
- If scope is "project" but no project specified and not in a project directory, ask for clarification
- If skill already exists, warn the user and ask if they want to overwrite
- If init_skill.py fails, report the error to the user

## Post-Creation Guidance

After creating the skill, remind the user to:
1. Edit `SKILL.md` to add their instructions
2. Add any bundled resources (`scripts/`, `references/`, `assets/`)
3. Test the skill
4. Package with: `~/.claude/skills/skill-creator/scripts/package_skill.py <path>`
