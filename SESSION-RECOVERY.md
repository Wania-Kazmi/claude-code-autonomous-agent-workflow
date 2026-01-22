# Session Recovery System for sp.autonomous

> **Complete persistence and resume capability for autonomous workflow**

---

## Overview

The `/sp.autonomous` command now supports **automatic session recovery**. If your laptop closes, process crashes, or session ends unexpectedly, you can resume exactly where you left off.

---

## How It Works

### Automatic State Tracking

Every significant event is automatically tracked:

| Event | What Gets Saved |
|-------|----------------|
| **Phase Start** | Phase number, name, timestamp |
| **Phase Complete** | Phase number, grade, validation status |
| **Feature Start** | Feature ID, name (COMPLEX projects) |
| **Feature Complete** | Feature ID, completion timestamp |
| **Task Progress** | Task ID, name, status |
| **Validation** | Quality gate grade, report path |

### State Files

```
.specify/
├── workflow-state.json        # Current state snapshot
└── workflow-progress.log      # Complete event history
```

### State File Structure

**workflow-state.json**:
```json
{
  "version": "2.0",
  "last_updated": "2026-01-22T14:30:00Z",
  "current_phase": 11,
  "complexity": "COMPLEX",
  "session_id": "session-20260122-103000",
  "phases_completed": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  "phases_in_progress": [11],
  "features": {
    "total": 3,
    "completed": ["F-01"],
    "current": "F-02",
    "pending": ["F-03"]
  },
  "artifacts": {
    "constitution": true,
    "spec": true,
    "plan": true,
    "tasks": true,
    "implementation_started": true,
    "tests_passing": false
  },
  "resume_capability": {
    "can_resume": true,
    "resume_point": "Phase 11: Feature F-02 Implementation",
    "resume_instructions": "Continue implementing F-02 starting from task 5"
  }
}
```

**workflow-progress.log**:
```
[2026-01-22T10:00:00Z] SESSION_START session_id=session-20260122-100000
[2026-01-22T10:00:05Z] PHASE_START phase=1 name=INIT
[2026-01-22T10:00:30Z] PHASE_COMPLETE phase=1 grade=A
[2026-01-22T10:03:05Z] FEATURE_START feature=F-01 name="User Authentication"
[2026-01-22T10:30:00Z] TASK_START task=T-F-02-005 name="Implement getTodos"
[2026-01-22T10:30:45Z] SESSION_INTERRUPT reason="User closed laptop"
```

---

## Usage

### Starting a New Build

```bash
# Start autonomous build
/sp.autonomous requirements.md

# State is automatically tracked - nothing extra to do!
```

### Resuming After Interruption

```bash
# Just run the same command again
/sp.autonomous requirements.md

# Claude will:
# 1. Detect existing workflow state
# 2. Show resume report
# 3. Continue from where it stopped
```

### Example Resume Flow

```
$ /sp.autonomous requirements.md

╔════════════════════════════════════════════════════════════════════════════╗
║                    WORKFLOW RESUME REPORT                                   ║
╠════════════════════════════════════════════════════════════════════════════╣

Project Type: COMPLEX
Current Phase: 11
Phases Completed: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

Features:
  Total: 3
  Completed: F-01
  Current: F-02
  Pending: F-03

Resume Point:
  Phase 11: Feature F-02 Implementation - Task 5 of 12

Instructions:
  Continue implementing F-02 starting from task T-F-02-005

Last Updated: 2026-01-22T14:30:00Z
Last Validation: Phase 10 - Grade B

╚════════════════════════════════════════════════════════════════════════════╝

Resume from this point? (y/n): y

Resuming workflow...
```

---

## Manual State Management

### Check Current State

```bash
# View current workflow state
/q-status

# Or use Python script directly:
python3 .claude/scripts/workflow-state.py resume-report
```

### Detect State from Artifacts

If `workflow-state.json` is missing or corrupted:

```bash
# Auto-detect state from filesystem
python3 .claude/scripts/workflow-state.py detect

# This checks:
# - Directory structure (.specify, .claude)
# - Generated files (constitution.md, spec.md, etc.)
# - Source code (src/, lib/)
# - Feature progress
```

### Reset State (Start Fresh)

```bash
# Reset workflow state
/q-reset

# Or manually:
rm .specify/workflow-state.json
rm .specify/workflow-progress.log
```

---

## Integration with sp.autonomous

The autonomous command automatically:

1. **On Start**: Checks for existing state
   ```python
   if workflow_state_exists():
       show_resume_report()
       if user_wants_to_resume():
           resume_from_saved_state()
       else:
           backup_old_state()
           start_fresh()
   else:
       start_fresh()
   ```

2. **During Execution**: Updates state after each phase
   ```python
   # After completing Phase 8
   update_phase_progress(8, 'complete', feature='F-02', grade='B')

   # After completing Feature F-01
   update_feature_progress('F-01', 'complete')
   ```

3. **On Interrupt**: Saves state gracefully
   ```bash
   trap 'on_interrupt' INT TERM

   function on_interrupt() {
       log_session_interrupt "User stopped process"
       generate_resume_report
       exit 0
   }
   ```

---

## Python Script API

### Initialize State

```bash
python3 .claude/scripts/workflow-state.py init
# Output: session-20260122-103000
```

### Update Phase

```bash
# Start phase 11
python3 .claude/scripts/workflow-state.py phase-start 11

# Complete phase 11 with grade B
python3 .claude/scripts/workflow-state.py phase-complete 11 B
```

### Update Feature (COMPLEX projects)

```bash
# Start feature F-02
python3 .claude/scripts/workflow-state.py feature-start F-02

# Complete feature F-02
python3 .claude/scripts/workflow-state.py feature-complete F-02
```

### Get State Values

```bash
# Get current phase
python3 .claude/scripts/workflow-state.py get current_phase
# Output: 11

# Get complexity
python3 .claude/scripts/workflow-state.py get complexity
# Output: "COMPLEX"

# Get nested value
python3 .claude/scripts/workflow-state.py get features.current
# Output: "F-02"
```

---

## What Gets Tracked

### Phase-Level Tracking

| Phase | What's Tracked |
|-------|---------------|
| 0 | Initialization, directory setup |
| 1-6 | Project analysis, skill generation |
| 7 | Constitution creation |
| 8-10 | Spec, plan, tasks (per feature if COMPLEX) |
| 11 | Implementation progress, task completion |
| 12 | QA, testing, validation |
| 13 | Delivery, final commit |

### Feature-Level Tracking (COMPLEX Projects)

For multi-feature projects:
- Current feature being worked on
- Completed features list
- Pending features queue
- Per-feature phase progress

### Artifact Tracking

Monitors existence of key files:
- `.specify/constitution.md`
- `.specify/spec.md`
- `.specify/plan.md`
- `.specify/tasks.md`
- Source code directories (`src/`, `lib/`)
- Test files

### Validation Tracking

Stores quality gate results:
- Last validated phase
- Grade received (A/B/C/D/F)
- Validation report paths

---

## Resume Scenarios

### Scenario 1: Laptop Closed Mid-Implementation

```
Session 1:
  Phase 1-10: Complete
  Phase 11: Started implementing Feature F-02
  [LAPTOP CLOSED]

Session 2:
  Detects: Phase 11, Feature F-02, Task 5 of 12
  Resumes: Continues from Task 5
  Skips: Already completed phases 1-10
```

### Scenario 2: Process Killed During Testing

```
Session 1:
  Phase 1-11: Complete
  Phase 12: Running integration tests
  [PROCESS KILLED]

Session 2:
  Detects: Phase 12 in progress
  Resumes: Re-runs integration tests from start
  Skips: Implementation (already done)
```

### Scenario 3: Complex Project with Multiple Features

```
Session 1:
  Feature F-01: Complete
  Feature F-02: Phases 8, 9, 10 complete, Phase 11 started
  [SESSION END]

Session 2:
  Detects: Feature F-02, Phase 11
  Resumes: Continues F-02 implementation
  Queue: F-03 still pending
```

---

## Best Practices

### 1. Let It Run

The system tracks automatically. No manual intervention needed.

### 2. Safe to Interrupt

Close your laptop anytime - state is saved after each phase.

### 3. Check Progress Anytime

```bash
/q-status  # Quick status check
```

### 4. Trust the Resume

The resume point is calculated based on:
- Completed phases
- Existing artifacts
- Feature progress
- Task completion

### 5. Fresh Start When Needed

```bash
/q-reset  # Clear state, start over
```

---

## Files Reference

### Core Files

| File | Purpose | When Created |
|------|---------|--------------|
| `.specify/workflow-state.json` | Current state snapshot | On `init` |
| `.specify/workflow-progress.log` | Event history | On first event |
| `.claude/scripts/workflow-state.py` | State manager | Pre-installed |

### Backup Files

Auto-created when resetting:
- `.specify/workflow-state-20260122-103000.json.bak`

---

## Troubleshooting

### State File Missing

```bash
# Auto-detect from artifacts
python3 .claude/scripts/workflow-state.py detect
```

### State Corrupted

```bash
# Backup and detect
mv .specify/workflow-state.json .specify/workflow-state.backup.json
python3 .claude/scripts/workflow-state.py detect
```

### Resume Point Wrong

```bash
# Manually edit workflow-state.json
# Update current_phase, features.current, etc.
# Or reset and detect:
/q-reset
python3 .claude/scripts/workflow-state.py detect
```

### Want to Skip Phases

```bash
# Edit workflow-state.json:
{
  "current_phase": 11,  # Change to desired phase
  "phases_completed": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]  # Add skipped phases
}
```

---

## Advanced Usage

### Custom Resume Point

```python
# Edit .specify/workflow-state.json
{
  "resume_capability": {
    "can_resume": true,
    "resume_point": "Phase 11: Custom task",
    "resume_instructions": "Start from custom-task.ts"
  }
}
```

### Analyze Progress Log

```bash
# Count phase completions
grep "PHASE_COMPLETE" .specify/workflow-progress.log | wc -l

# Find failures
grep "PHASE_FAIL" .specify/workflow-progress.log

# Session duration
SESSION_START=$(grep "SESSION_START" .specify/workflow-progress.log | head -1 | cut -d'[' -f2 | cut -d']' -f1)
SESSION_END=$(grep -E "SESSION_END|SESSION_INTERRUPT" .specify/workflow-progress.log | tail -1 | cut -d'[' -f2 | cut -d']' -f1)
echo "Duration: $SESSION_START to $SESSION_END"
```

### Monitor Real-Time

```bash
# Watch progress log in real-time
tail -f .specify/workflow-progress.log
```

---

## Summary

✅ **Automatic**: No manual state management needed
✅ **Resilient**: Survives crashes, interruptions, laptop closures
✅ **Granular**: Tracks phases, features, tasks
✅ **Smart**: Detects state from artifacts if needed
✅ **Transparent**: Full event log in workflow-progress.log
✅ **Recoverable**: Resume from exact interruption point

**Just run `/sp.autonomous requirements.md` - everything else is automatic!**
