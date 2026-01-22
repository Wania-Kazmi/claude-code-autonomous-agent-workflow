# Session Recovery - TODO Persistence Across Conversations

> **For New Users**: If this is your first time using this boilerplate, you won't have any saved TODOs yet. The system will create `.specify/todos.json` when you first use the TodoWrite tool. This documentation describes how TODOs persist once you've created them.

## Problem

When you start a **new conversation** in Claude Code (not resume an existing one), your TODO list doesn't carry over because:

- TODOs are stored per-session in `~/.claude/todos/{session-id}.json`
- New conversations get new session IDs
- No cross-session TODO persistence existed

## Solution: Project-Level TODO Persistence with Multi-User Collaboration

We've implemented a **dual-storage system** with **intelligent merge support**:

1. **Session-level** - Normal Claude Code behavior (`~/.claude/todos/`)
2. **Project-level** - New system (`.specify/todos.json` in your project)
3. **Multi-User Support** - Multiple developers/sessions can collaborate on the same TODO list

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

#### Show Contributors

```bash
python3 .claude/scripts/sync-todos.py contributors
```

**When to use:** See which sessions/users have contributed to the TODO list.

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║                  TODO CONTRIBUTORS                             ║
╠════════════════════════════════════════════════════════════════╣
║  Total Contributors: 3
╠════════════════════════════════════════════════════════════════╣
║  📝 5e4022cb-2d6...
║     Created: 5 | Contributed: 7
║  📝 a7f3b91c-8e2...
║     Created: 2 | Contributed: 3
║  📝 c9d1e5f2-4a6...
║     Created: 3 | Contributed: 5
╚════════════════════════════════════════════════════════════════╝
```

#### Show History

```bash
python3 .claude/scripts/sync-todos.py history
```

**When to use:** View historical snapshots of TODO changes.

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║                    TODO HISTORY                                ║
╠════════════════════════════════════════════════════════════════╣
║  1. 2026-01-22T16:30:00
║     Session: 5e4022cb-2d6... | TODOs: 10
║  2. 2026-01-22T14:15:00
║     Session: a7f3b91c-8e2... | TODOs: 8
║  3. 2026-01-21T11:45:00
║     Session: 5e4022cb-2d6... | TODOs: 6
╚════════════════════════════════════════════════════════════════╝
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

## Multi-User Collaboration

### The Scenario

Developer A and Developer B work on the same project at different times:

```
Day 1 - Developer A:
  ├── Creates TODOs for authentication feature
  ├── Marks 2 as in_progress
  ├── Completes 1 TODO
  └── Session ends → Auto-saves to .specify/todos.json

Day 2 - Developer B:
  ├── Runs: bash .claude/scripts/resume-work.sh
  ├── Sees Developer A's TODOs
  ├── Continues A's in_progress item
  ├── Adds 3 new TODOs for database setup
  ├── Completes 2 TODOs
  └── Session ends → Intelligently merges with A's TODOs

Day 3 - Developer A (returns):
  ├── Runs: bash .claude/scripts/resume-work.sh
  ├── Sees combined work:
  │   - A's original TODOs
  │   - B's new TODOs
  │   - Updated statuses from B
  └── Continues where they left off
```

### How Multi-User Merge Works

When multiple sessions contribute to the same project, the system:

1. **Detects Duplicates**: Uses content hash to identify same TODOs across sessions

2. **Prioritizes Status**: If both sessions modified the same TODO:
   - `completed` > `in_progress` > `pending`
   - The more advanced status wins

3. **Tracks Contributors**: Each TODO knows which sessions contributed to it
   - `created_by`: Who created this TODO
   - `contributors`: All sessions that touched it
   - `updated_by`: Who last modified it

4. **Preserves New Items**: TODOs unique to each session are added to the merged list

5. **Saves History**: Every merge creates a historical snapshot in `.specify/todo-history/`

### Example: Merge in Action

**Developer A's Session** (ends first):
```json
{
  "todos": [
    {"content": "Implement login API", "status": "in_progress"},
    {"content": "Add password hashing", "status": "pending"}
  ]
}
```

**Developer B's Session** (ends later):
```json
{
  "todos": [
    {"content": "Implement login API", "status": "completed"},  // Same TODO, more advanced
    {"content": "Add database migrations", "status": "pending"} // New TODO
  ]
}
```

**Merged Result**:
```json
{
  "todos": [
    {
      "content": "Implement login API",
      "status": "completed",  // B's status wins (completed > in_progress)
      "created_by": "session-A",
      "updated_by": "session-B",
      "contributors": ["session-A", "session-B"]
    },
    {
      "content": "Add password hashing",
      "status": "pending",
      "created_by": "session-A",
      "contributors": ["session-A"]
    },
    {
      "content": "Add database migrations",
      "status": "pending",
      "created_by": "session-B",
      "contributors": ["session-B"]
    }
  ],
  "collaboration": {
    "total_sessions": 2,
    "last_contributor": "session-B"
  }
}
```

### Visual Indicators

When loading TODOs, you'll see collaboration indicators:

```
║  [completed] Implement login API 👥2     ← 2 contributors
║  [pending] Add password hashing          ← 1 contributor
║  [pending] Add database migrations       ← 1 contributor
```

The `👥2` badge shows that 2 different sessions worked on this TODO.

### Collaboration Commands

```bash
# See who contributed what
python3 .claude/scripts/sync-todos.py contributors

# View historical changes
python3 .claude/scripts/sync-todos.py history

# Check current TODO state
python3 .claude/scripts/sync-todos.py status
```

### Conflict Resolution

**Q: What if two people mark different statuses for the same TODO?**

A: The system uses **status priority** - more advanced status wins:
- `completed` beats `in_progress` and `pending`
- `in_progress` beats `pending`

**Q: Can I see who did what?**

A: Yes! Each TODO tracks:
- Who created it (`created_by`)
- Who last updated it (`updated_by`)
- All contributors (`contributors` array)

**Q: What if I want to undo a merge?**

A: Check the history:
```bash
python3 .claude/scripts/sync-todos.py history
```

Historical snapshots are saved in `.specify/todo-history/` - you can manually restore from any snapshot if needed.

### Team Workflow Best Practices

1. **Always run `resume-work.sh` when starting**
   - See what others have done
   - Avoid duplicate work

2. **Check contributors before modifying TODOs**
   ```bash
   python3 .claude/scripts/sync-todos.py contributors
   ```

3. **Use descriptive TODO content**
   - Merge detection uses content matching
   - Clear descriptions prevent accidental duplicates

4. **Commit `.specify/todos.json` to git**
   - Share TODO state across team
   - Version control your task list

5. **Review history periodically**
   ```bash
   python3 .claude/scripts/sync-todos.py history
   ```

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
