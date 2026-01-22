# Session Recovery Quick Reference

## User Commands

| Command | What It Does |
|---------|--------------|
| `/sp.autonomous requirements.md` | Start or resume autonomous build |
| `/q-status` | Check current workflow state |
| `/q-reset` | Reset state (start fresh) |

## What Happens Automatically

✅ State saved after each phase
✅ Progress logged to `.specify/workflow-progress.log`
✅ Resume point updated automatically
✅ Artifacts tracked as they're created

## Resume Flow

```
1. Run: /sp.autonomous requirements.md
2. Claude detects existing state
3. Shows resume report with current progress
4. Asks: "Resume from this point? (y/n)"
5. You choose:
   - y: Continues from where it stopped
   - n: Starts fresh (old state backed up)
```

## State Files

```
.specify/
├── workflow-state.json      ← Current state snapshot
└── workflow-progress.log    ← Complete event history
```

## Check State Manually

```bash
# Show resume report
python3 .claude/scripts/workflow-state.py resume-report

# Get specific value
python3 .claude/scripts/workflow-state.py get current_phase

# Detect state from artifacts
python3 .claude/scripts/workflow-state.py detect
```

## Common Scenarios

### Laptop Closed During Build

```
Session 1: Phases 1-10 complete, Phase 11 started
         [LAPTOP CLOSED]
Session 2: Resume from Phase 11
```

### Process Crashed

```
Session 1: Working on Feature F-02
         [CRASH]
Session 2: Resume Feature F-02 from saved state
```

### Want to Start Over

```bash
/q-reset
# Old state backed up automatically
```

## What Gets Tracked

- ✓ Current phase (0-13)
- ✓ Completed phases
- ✓ Feature progress (COMPLEX projects)
- ✓ Quality gate grades
- ✓ Artifact existence
- ✓ Last updated timestamp

## Pro Tips

1. **Let it run** - State saves automatically
2. **Safe to interrupt** - Close laptop anytime
3. **Check progress** - Use `/q-status`
4. **Trust resume** - Calculated from artifacts
5. **Fresh start** - Use `/q-reset` when needed
