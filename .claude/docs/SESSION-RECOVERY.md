# Session Recovery - TODO Persistence Across Conversations

## Problem

When you start a **new conversation** in Claude Code (not resume an existing one), your TODO list doesn't carry over because:

- TODOs are stored per-session in `~/.claude/todos/{session-id}.json`
- New conversations get new session IDs
- No cross-session TODO persistence existed

## Solution: Project-Level TODO Persistence

We've implemented a **dual-storage system**:

1. **Session-level** - Normal Claude Code behavior (`~/.claude/todos/`)
2. **Project-level** - New system (`.specify/todos.json` in your project)

### How It Works

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     TODO PERSISTENCE FLOW                                    │
│                                                                             │
│  DURING SESSION:                                                            │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │  1. You use TodoWrite → Saves to session file                     │     │
│  │     ~/.claude/todos/{session-id}-agent-{agent-id}.json            │     │
│  │                                                                    │     │
│  │  2. Claude loads TODOs from session file (normal behavior)         │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  END OF SESSION (Stop hook):                                                │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │  3. Auto-save: Copies TODOs to project level                      │     │
│  │     .specify/todos.json                                            │     │
│  │                                                                    │     │
│  │  4. Stores metadata: timestamp, session ID, project name          │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  NEW SESSION (days/weeks later):                                            │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │  5. Run: bash .claude/scripts/resume-work.sh                      │     │
│  │                                                                    │     │
│  │  6. Displays project TODOs from last session                       │     │
│  │                                                                    │     │
│  │  7. You manually restore or ask Claude to restore them            │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Usage Guide

### When Starting a New Session

If you're starting a **new conversation** (not resuming), run this to see your saved TODOs:

```bash
bash .claude/scripts/resume-work.sh
```

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║              RESUMING WORK IN THIS PROJECT                     ║
╠════════════════════════════════════════════════════════════════╣
║  Project: my-project
╠════════════════════════════════════════════════════════════════╣
║  ✓ Found saved TODOs from previous session
╠════════════════════════════════════════════════════════════════╣
║  Project: my-project
║  Last Updated: 2026-01-22T15:41:15
╠════════════════════════════════════════════════════════════════╣
║  Completed: 3 | In Progress: 1 | Pending: 3
╠════════════════════════════════════════════════════════════════╣
║  TODO List:
║  [completed] Implement user authentication
║  [completed] Add database schema
║  [completed] Set up API routes
║  [in_progress] Write integration tests
║  [pending] Add E2E tests
║  [pending] Deploy to staging
║  [pending] Update documentation
╚════════════════════════════════════════════════════════════════╝
```

Then ask Claude:

> "Please restore these TODOs to our session"

Claude will use the TodoWrite tool to restore them.

---

### Manual Commands

#### Save Current TODOs to Project

```bash
python3 .claude/scripts/sync-todos.py save
```

**When to use:** If you want to manually save before ending your session.

#### Load Project TODOs (Display Only)

```bash
python3 .claude/scripts/sync-todos.py load
```

**When to use:** Check what TODOs are saved without restoring them.

#### Check TODO Status

```bash
python3 .claude/scripts/sync-todos.py status
```

**Output:**
```
✓ Project TODOs exist
  Last updated: 2026-01-22T15:41:15.432712
  Total tasks: 7
  Completed: 3 | In Progress: 1 | Pending: 3
```

---

## File Structure

### Session-Level Storage
```
~/.claude/todos/
├── {conversation-id}-agent-{agent-id}.json
├── {conversation-id}-agent-{agent-id}.json
└── ...
```

**Format:**
```json
[
  {
    "content": "Task description",
    "status": "completed|in_progress|pending",
    "activeForm": "Task action form"
  }
]
```

### Project-Level Storage
```
your-project/
└── .specify/
    └── todos.json
```

**Format:**
```json
{
  "last_updated": "2026-01-22T15:41:15.432712",
  "source_session": "5e4022cb-2d68-4541-adea-9c32edaa15f3-agent-...",
  "project": "my-project",
  "todos": [
    {
      "content": "Task description",
      "status": "completed",
      "activeForm": "Task action form"
    }
  ]
}
```

---

## Automatic Save on Session End

A **Stop hook** automatically saves your TODOs when the session ends.

**Hook Configuration** (in `.claude/settings.json`):
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 .claude/scripts/sync-todos.py save",
            "timeout": 3000
          }
        ]
      }
    ]
  }
}
```

**What This Does:**
- When you close Claude Code or end the session
- Automatically copies session TODOs to `.specify/todos.json`
- No manual intervention needed

---

## Best Practices

### 1. Start Every New Conversation With

```bash
bash .claude/scripts/resume-work.sh
```

Then ask Claude to restore the TODOs shown.

### 2. Check TODO Status Before Ending

```bash
python3 .claude/scripts/sync-todos.py status
```

Verify your TODOs are saved.

### 3. Commit `.specify/todos.json` to Git

Add to your `.gitignore` exceptions:
```
# .gitignore
.specify/*
!.specify/todos.json
```

**Benefit:** Team members can see project TODOs.

### 4. Clean Up Old TODOs

Periodically review and remove completed tasks:

```bash
python3 .claude/scripts/sync-todos.py load
# Manually edit .specify/todos.json to remove old tasks
```

---

## Troubleshooting

### "No session TODOs found to save"

**Cause:** Your current session has no TODOs.

**Fix:** Use TodoWrite tool to create some TODOs first.

### "No project TODOs found"

**Cause:** This is a new project with no saved TODOs yet.

**Fix:** Normal for new projects. TODOs will be saved after your first session.

### TODOs Not Loading in New Session

**Cause:** New conversations have different session IDs.

**Fix:** This is expected. Use `resume-work.sh` to display saved TODOs, then manually restore them.

### ".specify/todos.json" is Corrupted

**Cause:** Manual editing broke JSON structure.

**Fix:**
```bash
# Validate JSON
python3 -m json.tool .specify/todos.json

# If invalid, restore from session
rm .specify/todos.json
python3 .claude/scripts/sync-todos.py save
```

---

## Advanced: Custom TODO Workflows

### Export TODOs to Markdown

```bash
python3 << 'EOF'
import json

with open('.specify/todos.json') as f:
    data = json.load(f)

print(f"# TODOs for {data['project']}\n")
print(f"*Last updated: {data['last_updated']}*\n")

for todo in data['todos']:
    status = {
        'completed': '✓',
        'in_progress': '→',
        'pending': '☐'
    }.get(todo['status'], '?')

    print(f"{status} {todo['content']}")
EOF
```

### Filter TODOs by Status

```bash
python3 << 'EOF'
import json
import sys

status = sys.argv[1] if len(sys.argv) > 1 else 'pending'

with open('.specify/todos.json') as f:
    data = json.load(f)

filtered = [t for t in data['todos'] if t['status'] == status]

print(f"{len(filtered)} {status} tasks:")
for todo in filtered:
    print(f"  - {todo['content']}")
EOF
```

Usage:
```bash
python3 filter.py pending
python3 filter.py completed
python3 filter.py in_progress
```

---

## Future Enhancements

Potential improvements:

- [ ] Auto-restore TODOs on new session (no manual step)
- [ ] TODO history/versioning
- [ ] Multi-project TODO aggregation
- [ ] Web dashboard for TODOs
- [ ] Integration with GitHub Issues
- [ ] Sync across devices

---

## Technical Details

### Why Not Automatic Restore?

**Design Decision:** We chose **manual restoration** because:

1. **User Control** - You decide which TODOs are still relevant
2. **Clean Sessions** - New conversations start fresh unless you want the context
3. **No Noise** - Doesn't clutter new sessions with old TODOs

**Future:** We may add an opt-in auto-restore feature.

### File Format Rationale

**Why JSON?**
- Cross-platform (works on Windows, macOS, Linux)
- Python native support (no dependencies)
- Human-readable
- Easy to parse and manipulate

**Why `.specify/`?**
- Workflow-related state already lives here
- Consistent with project organization
- Easy to find and version control

### Performance

**Storage Overhead:**
- Minimal: ~1-5 KB per project
- No performance impact on Claude Code

**Hook Execution Time:**
- Stop hook: <500ms (async, doesn't block)

---

## Support

**Issues?** Report at: https://github.com/anthropics/claude-code/issues

**Questions?** Run:
```bash
claude "/help"
```
