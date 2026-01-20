---
description: Reset Spec-Kit-Plus workflow state - clears .specify/ artifacts for fresh start
---

# /q-reset

Reset the Spec-Kit-Plus workflow to start fresh.

---

## What This Command Does

1. **Asks for confirmation** before destructive action
2. **Backs up** existing artifacts (optional)
3. **Clears** `.specify/` directory
4. **Preserves** `.claude/` infrastructure (skills, agents, hooks)
5. **Logs** the reset action

---

## Execution Steps

### Step 1: Confirm Reset

**IMPORTANT**: Ask user for confirmation before proceeding.

```
⚠️  WARNING: This will reset the workflow state!

The following will be DELETED:
- .specify/project-analysis.json
- .specify/requirements-analysis.json
- .specify/gap-analysis.json
- .specify/constitution.md
- .specify/spec.md
- .specify/plan.md
- .specify/data-model.md
- .specify/tasks.md
- .specify/workflow-status.json

The following will be PRESERVED:
- .claude/skills/ (all skills)
- .claude/agents/ (all agents)
- .claude/hooks/ (all hooks)
- .claude/logs/ (build logs)
- Source code (src/, etc.)

Continue? (yes/no)
```

### Step 2: Backup (Optional)

If user wants backup:

```bash
# Create timestamped backup
BACKUP_DIR=".specify-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r .specify/* "$BACKUP_DIR/" 2>/dev/null
echo "Backup created at: $BACKUP_DIR"
```

### Step 3: Clear Artifacts

```bash
# Remove workflow artifacts (preserve templates)
rm -f .specify/project-analysis.json
rm -f .specify/requirements-analysis.json
rm -f .specify/gap-analysis.json
rm -f .specify/constitution.md
rm -f .specify/spec.md
rm -f .specify/plan.md
rm -f .specify/data-model.md
rm -f .specify/tasks.md
rm -f .specify/workflow-status.json

# Keep templates
# .specify/templates/ is preserved

echo "Workflow artifacts cleared"
```

### Step 4: Log Reset

```bash
echo "[$(date -Iseconds)] [RESET] Workflow reset by user" >> .claude/logs/autonomous.log
```

### Step 5: Confirm Reset Complete

```
╔════════════════════════════════════════════════════════════════╗
║                    WORKFLOW RESET COMPLETE                      ║
╠════════════════════════════════════════════════════════════════╣
║  Cleared:                                                      ║
║  - All analysis JSON files                                     ║
║  - constitution.md                                             ║
║  - spec.md, plan.md, tasks.md                                  ║
║                                                                ║
║  Preserved:                                                    ║
║  - 9 skills in .claude/skills/                                 ║
║  - 10 agents in .claude/agents/                                ║
║  - All hooks and commands                                      ║
║  - Source code                                                 ║
╠════════════════════════════════════════════════════════════════╣
║  Ready for fresh /sp.autonomous run                            ║
╚════════════════════════════════════════════════════════════════╝
```

---

## Reset Levels

| Level | What It Clears | Command |
|-------|---------------|---------|
| **Soft** | Analysis JSONs only | `/q-reset --soft` |
| **Normal** | All .specify/ artifacts | `/q-reset` |
| **Hard** | .specify/ + generated skills | `/q-reset --hard` |
| **Full** | Everything except source | `/q-reset --full` |

### Soft Reset
Clears only analysis files, keeps spec/plan/tasks:
- project-analysis.json
- requirements-analysis.json
- gap-analysis.json

### Normal Reset (Default)
Clears all .specify/ artifacts except templates.

### Hard Reset
Also clears generated skills (keeps base 8 skills):
```bash
# Remove skills created after base set
# Base skills: api-patterns, backend-patterns, claudeception,
# coding-standards, database-patterns, mcp-code-execution-template,
# skill-gap-analyzer, testing-patterns, workflow-validator
```

### Full Reset
Clears everything except source code:
```bash
rm -rf .specify/*
rm -rf .claude/skills/*  # Will need to re-clone
rm -rf .claude/agents/*
rm -rf .claude/logs/*
rm -rf .claude/build-reports/*
```

---

## When to Use

| Scenario | Recommended Action |
|----------|-------------------|
| Want to re-analyze requirements | `/q-reset --soft` |
| Starting fresh with same project | `/q-reset` |
| Requirements changed significantly | `/q-reset` |
| Want completely clean slate | `/q-reset --hard` |
| Testing the autonomous workflow | `/q-reset` |

---

## Safety Features

1. **Always asks confirmation** before deleting
2. **Offers backup** option
3. **Preserves source code** - never deletes src/
4. **Logs all resets** for audit trail
5. **Preserves base skills** - won't delete core infrastructure
