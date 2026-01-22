# Multi-User TODO Collaboration - Quick Reference

> **New Feature**: Multiple developers can now work on the same project, with intelligent TODO merging and contributor tracking!

---

## What's New

### Before
- TODOs lost when starting new conversation
- Only worked for single user/session

### After
- ✅ TODOs persist across conversations
- ✅ Multiple users can collaborate
- ✅ Intelligent conflict resolution
- ✅ Contributor tracking
- ✅ Historical snapshots

---

## Quick Start

### For Solo Developers

```bash
# When starting a new conversation
bash .claude/scripts/resume-work.sh

# Ask Claude: "Please restore these TODOs"
```

### For Team Collaboration

```bash
# Developer A - End of day
# (TODOs auto-save when session ends)

# Developer B - Next day
bash .claude/scripts/resume-work.sh  # See A's TODOs
# Continue work, add new TODOs
# (TODOs auto-merge when session ends)

# Developer A - Returns
bash .claude/scripts/resume-work.sh  # See combined work
```

---

## New Commands

| Command | What It Does |
|---------|--------------|
| `python3 .claude/scripts/sync-todos.py contributors` | Show who contributed to TODOs |
| `python3 .claude/scripts/sync-todos.py history` | View historical snapshots |
| `python3 .claude/scripts/sync-todos.py status` | Check TODO status (enhanced with collaboration info) |
| `python3 .claude/scripts/sync-todos.py load` | Display TODOs (now shows collaboration badges) |
| `python3 .claude/scripts/sync-todos.py save` | Manual save (with intelligent merge) |

---

## How Merge Works

### Status Priority (Auto-Resolution)

When two developers modify the same TODO:

```
completed > in_progress > pending
```

**Example:**
- Developer A: "Implement API" → status: `in_progress`
- Developer B: "Implement API" → status: `completed`
- **Result**: status: `completed` ✅

### Contributor Tracking

Each TODO knows:
- `created_by`: Who created it
- `updated_by`: Who last modified it
- `contributors`: All sessions that touched it

### Visual Indicators

```
║  [completed] Implement login API 👥2     ← 2 contributors worked on this
║  [pending] Add password hashing          ← 1 contributor
```

---

## Real-World Scenario

### Day 1 - Developer A

```json
{
  "todos": [
    {"content": "Setup project", "status": "completed"},
    {"content": "Implement auth", "status": "in_progress"},
    {"content": "Add tests", "status": "pending"}
  ]
}
```

**Session ends** → Auto-saved to `.specify/todos.json`

---

### Day 2 - Developer B

```bash
$ bash .claude/scripts/resume-work.sh
```

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║              RESUMING WORK IN THIS PROJECT                     ║
╠════════════════════════════════════════════════════════════════╣
║  Project: my-project
║  Last Updated: 2026-01-22T10:30:00
╠════════════════════════════════════════════════════════════════╣
║  Completed: 1 | In Progress: 1 | Pending: 1
╠════════════════════════════════════════════════════════════════╣
║  TODO List:
║  [completed] Setup project
║  [in_progress] Implement auth
║  [pending] Add tests
╚════════════════════════════════════════════════════════════════╝
```

**B continues work:**

```json
{
  "todos": [
    {"content": "Implement auth", "status": "completed"},  // Completed A's work
    {"content": "Add tests", "status": "in_progress"},     // Started tests
    {"content": "Setup database", "status": "pending"}     // Added new task
  ]
}
```

**Session ends** → Auto-merged with A's TODOs

---

### Day 3 - Developer A Returns

```bash
$ bash .claude/scripts/resume-work.sh
```

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║              RESUMING WORK IN THIS PROJECT                     ║
╠════════════════════════════════════════════════════════════════╣
║  Project: my-project
║  Last Updated: 2026-01-22T16:45:00
║  👥 Collaborative: 2 session(s) contributed
║  Last Contributor: session-b-67890
╠════════════════════════════════════════════════════════════════╣
║  Completed: 2 | In Progress: 1 | Pending: 1
╠════════════════════════════════════════════════════════════════╣
║  TODO List:
║  [completed] Setup project
║  [completed] Implement auth 👥2
║  [in_progress] Add tests 👥2
║  [pending] Setup database
╚════════════════════════════════════════════════════════════════╝
```

---

## Checking Who Did What

```bash
$ python3 .claude/scripts/sync-todos.py contributors
```

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║                  TODO CONTRIBUTORS                             ║
╠════════════════════════════════════════════════════════════════╣
║  Total Contributors: 2
╠════════════════════════════════════════════════════════════════╣
║  📝 session-a-12345...
║     Created: 3 | Contributed: 3
║  📝 session-b-67890...
║     Created: 1 | Contributed: 3
╚════════════════════════════════════════════════════════════════╝
```

---

## Viewing History

```bash
$ python3 .claude/scripts/sync-todos.py history
```

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║                    TODO HISTORY                                ║
╠════════════════════════════════════════════════════════════════╣
║  1. 2026-01-22T16:45:00
║     Session: session-b-67... | TODOs: 4
║  2. 2026-01-22T10:30:00
║     Session: session-a-12... | TODOs: 3
╚════════════════════════════════════════════════════════════════╝
```

---

## File Structure

```
your-project/
├── .specify/
│   ├── todos.json              # Current merged TODOs
│   └── todo-history/           # Historical snapshots
│       ├── 20260122_103000_session-a.json
│       └── 20260122_164500_session-b.json
└── .claude/
    └── scripts/
        └── sync-todos.py       # Enhanced with merge logic
```

---

## Data Format

### `.specify/todos.json` (Enhanced)

```json
{
  "last_updated": "2026-01-22T16:45:00.123456",
  "last_session": "session-b-67890...",
  "sessions": [
    "session-a-12345...",
    "session-b-67890..."
  ],
  "project": "my-project",
  "collaboration": {
    "total_sessions": 2,
    "last_contributor": "session-b"
  },
  "todos": [
    {
      "content": "Implement auth",
      "status": "completed",
      "activeForm": "Implementing auth",
      "created_by": "session-a-12345...",
      "updated_by": "session-b-67890...",
      "updated_at": "2026-01-22T16:30:00",
      "contributors": [
        "session-a-12345...",
        "session-b-67890..."
      ]
    }
  ]
}
```

### Historical Snapshot

```json
{
  "timestamp": "2026-01-22T16:45:00.123456",
  "session": "session-b-67890...",
  "todos": [...]
}
```

---

## Best Practices

### 1. Always Resume Work

```bash
# First thing when starting new conversation
bash .claude/scripts/resume-work.sh
```

### 2. Check Contributors Before Modifying

```bash
# See who's been working on what
python3 .claude/scripts/sync-todos.py contributors
```

### 3. Use Clear TODO Descriptions

Merge detection uses content matching. Clear descriptions prevent duplicates:

```
✅ "Implement user authentication with JWT"
❌ "Do auth" (too vague, might create duplicates)
```

### 4. Commit `.specify/todos.json` to Git

```bash
git add .specify/todos.json
git commit -m "docs: update project TODOs"
git push
```

### 5. Review History Periodically

```bash
# See evolution of TODOs over time
python3 .claude/scripts/sync-todos.py history
```

---

## FAQ

### Q: What if two people mark different statuses?

**A:** Status priority wins - more advanced status is kept:
- `completed` beats `in_progress` and `pending`
- `in_progress` beats `pending`

### Q: Can I undo a merge?

**A:** Yes! Historical snapshots are saved in `.specify/todo-history/`. You can manually restore from any snapshot.

### Q: How do I know if someone else worked on a TODO?

**A:** Look for the `👥` badge when loading TODOs, or run:
```bash
python3 .claude/scripts/sync-todos.py contributors
```

### Q: Does this work with git?

**A:** Yes! Commit `.specify/todos.json` to share TODO state across team. Merges happen automatically when sessions end.

### Q: What if I don't want to collaborate?

**A:** Everything works the same! The system just tracks your sessions. You'll see `1 session contributed` instead of multiple.

---

## Troubleshooting

### Issue: Duplicate TODOs appearing

**Cause:** Different wording for same task

**Fix:** Use consistent descriptions. The system matches by content hash.

### Issue: Status not updating

**Cause:** Lower priority status trying to override higher priority

**Fix:** This is intentional. `completed` always wins over `in_progress` which wins over `pending`.

### Issue: History growing too large

**Fix:** Periodically clean old snapshots:
```bash
# Keep last 30 days
find .specify/todo-history -mtime +30 -delete
```

---

## Technical Details

### Merge Algorithm

1. **Hash TODOs** by content for duplicate detection
2. **Compare statuses** using priority ranking
3. **Track contributors** in metadata
4. **Save history** snapshot before merge
5. **Write merged result** to `.specify/todos.json`

### Status Priority

```python
status_priority = {
    'completed': 3,
    'in_progress': 2,
    'pending': 1
}
```

Higher number wins in conflicts.

### Contributor Tracking

Each TODO maintains:
- `created_by`: Original session ID
- `updated_by`: Last modifying session ID
- `contributors`: Array of all session IDs

---

## See Also

- [SESSION-RECOVERY.md](SESSION-RECOVERY.md) - Full documentation
- [Testing](../.claude/tests/test_multiuser_todos.py) - Test suite with 15 tests

---

**Questions?** Check the full documentation at `.claude/docs/SESSION-RECOVERY.md`
