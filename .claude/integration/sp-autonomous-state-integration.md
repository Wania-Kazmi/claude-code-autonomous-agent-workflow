# sp.autonomous State Integration Guide

> How to integrate workflow state management into the sp.autonomous command

---

## Quick Integration Checklist

- [x] workflow-state.json template created
- [x] workflow-state-manager skill created
- [x] workflow-state.py script created
- [x] Session recovery documented in CLAUDE.md
- [ ] Integrate into sp.autonomous command
- [ ] Add resume prompt at start
- [ ] Add state updates after each phase
- [ ] Add interrupt handler

---

## Phase 0: Add State Check

**Location**: `.claude/commands/sp.autonomous.md` - Phase 0 section

**Add this code**:

```bash
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 0: CHECK FOR EXISTING STATE
# ═══════════════════════════════════════════════════════════════════════════════

STATE_SCRIPT=".claude/scripts/workflow-state.py"

if [ -f ".specify/workflow-state.json" ]; then
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    EXISTING WORKFLOW STATE DETECTED                         ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo ""

    # Show resume report
    python3 "${STATE_SCRIPT}" resume-report

    echo ""
    read -p "Resume from this point? (y/n): " RESUME_CHOICE

    if [ "$RESUME_CHOICE" = "y" ] || [ "$RESUME_CHOICE" = "Y" ]; then
        echo "Resuming workflow..."
        RESUME_MODE=true

        # Load state
        CURRENT_PHASE=$(python3 "${STATE_SCRIPT}" get current_phase | jq -r '.')
        COMPLEXITY=$(python3 "${STATE_SCRIPT}" get complexity | jq -r '.')
        CURRENT_FEATURE=$(python3 "${STATE_SCRIPT}" get features.current | jq -r '.')

        echo "Resume Point:"
        echo "  Phase: ${CURRENT_PHASE}"
        echo "  Complexity: ${COMPLEXITY}"
        echo "  Current Feature: ${CURRENT_FEATURE}"
        echo ""
    else
        echo "Starting fresh..."
        RESUME_MODE=false

        # Backup old state
        BACKUP_FILE=".specify/workflow-state-$(date +%Y%m%d-%H%M%S).json.bak"
        mv .specify/workflow-state.json "${BACKUP_FILE}"
        echo "Old state backed up to: ${BACKUP_FILE}"
        echo ""
    fi
else
    echo "No existing workflow state. Starting fresh."
    RESUME_MODE=false
    CURRENT_PHASE=0
fi

# Initialize or continue
if [ "$RESUME_MODE" = "false" ]; then
    SESSION_ID=$(python3 "${STATE_SCRIPT}" init)
    echo "New session started: ${SESSION_ID}"
    CURRENT_PHASE=0
fi
```

---

## Phase Updates: Add State Tracking

**After each phase completes**, add:

```bash
# ═══════════════════════════════════════════════════════════════════════════════
# PHASE X: [PHASE NAME]
# ═══════════════════════════════════════════════════════════════════════════════

# START: Log phase start
python3 "${STATE_SCRIPT}" phase-start ${PHASE_NUMBER} ${FEATURE_ID:-}

# ... phase execution code ...

# COMPLETE: Log phase completion with grade
GRADE=$(get_validation_grade ${PHASE_NUMBER})  # From workflow-validator
python3 "${STATE_SCRIPT}" phase-complete ${PHASE_NUMBER} ${GRADE} ${FEATURE_ID:-}
```

### Example for Phase 8 (SPEC):

```bash
# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 8: SPEC
# ═══════════════════════════════════════════════════════════════════════════════

python3 "${STATE_SCRIPT}" phase-start 8 ${CURRENT_FEATURE:-}

echo "Creating specification..."

# Generate spec
create_spec "${CURRENT_FEATURE}"

# Validate
GRADE=$(validate_phase 8)

python3 "${STATE_SCRIPT}" phase-complete 8 ${GRADE} ${CURRENT_FEATURE:-}

echo "Phase 8 complete (Grade: ${GRADE})"
```

---

## Feature Tracking (COMPLEX Projects)

**When starting a feature**:

```bash
# ═══════════════════════════════════════════════════════════════════════════════
# START FEATURE
# ═══════════════════════════════════════════════════════════════════════════════

FEATURE_ID="F-01"
FEATURE_NAME="User Authentication"

python3 "${STATE_SCRIPT}" feature-start "${FEATURE_ID}"

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║  Feature: ${FEATURE_ID} - ${FEATURE_NAME}"
echo "╚════════════════════════════════════════════════════════════════════════════╝"

# Run feature phases (8, 9, 10, 11)
run_feature_spec ${FEATURE_ID}
run_feature_plan ${FEATURE_ID}
run_feature_tasks ${FEATURE_ID}
run_feature_implement ${FEATURE_ID}

# Mark feature complete
python3 "${STATE_SCRIPT}" feature-complete "${FEATURE_ID}"

echo "Feature ${FEATURE_ID} complete!"
```

---

## Interrupt Handler

**Add to the beginning of sp.autonomous**:

```bash
#!/bin/bash

STATE_SCRIPT=".claude/scripts/workflow-state.py"

# ═══════════════════════════════════════════════════════════════════════════════
# INTERRUPT HANDLER
# ═══════════════════════════════════════════════════════════════════════════════

on_interrupt() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                        SESSION INTERRUPTED                                  ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo ""

    # Log interrupt to progress log
    echo "[$(date -Iseconds)] SESSION_INTERRUPT reason=\"User stopped process\"" >> .specify/workflow-progress.log

    echo "Workflow state has been saved."
    echo ""
    echo "To resume:"
    echo "  /sp.autonomous [requirements-file]"
    echo ""
    echo "Resume report:"
    python3 "${STATE_SCRIPT}" resume-report

    exit 0
}

trap on_interrupt INT TERM
```

---

## Resume Logic

**Add resume branching in Phase 0**:

```bash
# ═══════════════════════════════════════════════════════════════════════════════
# RESUME BRANCHING
# ═══════════════════════════════════════════════════════════════════════════════

if [ "$RESUME_MODE" = "true" ]; then
    echo "Jumping to Phase ${CURRENT_PHASE}..."

    case ${CURRENT_PHASE} in
        0|1)
            run_phase_1
            run_phase_2
            # ... continue
            ;;
        2)
            run_phase_2
            run_phase_3
            # ... continue
            ;;
        7)
            run_phase_7
            run_phase_8
            # ... continue
            ;;
        11)
            if [ "${COMPLEXITY}" = "COMPLEX" ]; then
                # Resume feature implementation
                resume_feature_implementation ${CURRENT_FEATURE}
            else
                run_phase_11
            fi
            ;;
        12)
            run_phase_12
            run_phase_13
            ;;
        13)
            run_phase_13
            ;;
        *)
            echo "Resuming from phase ${CURRENT_PHASE}"
            resume_from_phase ${CURRENT_PHASE}
            ;;
    esac
else
    # Fresh start - run all phases
    run_all_phases
fi
```

---

## Artifact Tracking

**Update artifact flags as files are created**:

```bash
# After creating constitution
create_constitution
python3 -c "
import json
state = json.load(open('.specify/workflow-state.json'))
state['artifacts']['constitution'] = True
state['last_updated'] = '$(date -Iseconds)'
json.dump(state, open('.specify/workflow-state.json', 'w'), indent=2)
"

# After creating spec
create_spec
python3 -c "
import json
state = json.load(open('.specify/workflow-state.json'))
state['artifacts']['spec'] = True
state['last_updated'] = '$(date -Iseconds)'
json.dump(state, open('.specify/workflow-state.json', 'w'), indent=2)
"

# After implementation starts
mkdir -p src
python3 -c "
import json
state = json.load(open('.specify/workflow-state.json'))
state['artifacts']['implementation_started'] = True
state['last_updated'] = '$(date -Iseconds)'
json.dump(state, open('.specify/workflow-state.json', 'w'), indent=2)
"

# After tests pass
npm test
python3 -c "
import json
state = json.load(open('.specify/workflow-state.json'))
state['artifacts']['tests_passing'] = True
state['last_updated'] = '$(date -Iseconds)'
json.dump(state, open('.specify/workflow-state.json', 'w'), indent=2)
"
```

---

## Complete Integration Example

**Minimal sp.autonomous with state management**:

```bash
#!/bin/bash

set -e

STATE_SCRIPT=".claude/scripts/workflow-state.py"

# Interrupt handler
on_interrupt() {
    echo ""
    echo "Session interrupted. State saved."
    echo "[$(date -Iseconds)] SESSION_INTERRUPT" >> .specify/workflow-progress.log
    python3 "${STATE_SCRIPT}" resume-report
    exit 0
}
trap on_interrupt INT TERM

# Check for existing state
if [ -f ".specify/workflow-state.json" ]; then
    python3 "${STATE_SCRIPT}" resume-report
    read -p "Resume? (y/n): " RESUME
    if [ "$RESUME" = "y" ]; then
        CURRENT_PHASE=$(python3 "${STATE_SCRIPT}" get current_phase | jq -r '.')
    else
        mv .specify/workflow-state.json .specify/workflow-state.backup.json
        python3 "${STATE_SCRIPT}" init > /dev/null
        CURRENT_PHASE=0
    fi
else
    python3 "${STATE_SCRIPT}" init > /dev/null
    CURRENT_PHASE=0
fi

# Run phases
for PHASE in $(seq ${CURRENT_PHASE} 13); do
    echo "Running Phase ${PHASE}..."

    python3 "${STATE_SCRIPT}" phase-start ${PHASE}

    # Execute phase (your existing logic)
    run_phase ${PHASE}

    # Validate
    GRADE=$(validate_phase ${PHASE})

    python3 "${STATE_SCRIPT}" phase-complete ${PHASE} ${GRADE}

    echo "Phase ${PHASE} complete (${GRADE})"
done

echo "Workflow complete!"
```

---

## Testing the Integration

1. **Test Fresh Start**:
   ```bash
   rm -rf .specify
   /sp.autonomous requirements.md
   # Should initialize state and start from Phase 0
   ```

2. **Test Resume**:
   ```bash
   # Run autonomous build
   /sp.autonomous requirements.md
   # Kill process mid-way (Ctrl+C)

   # Resume
   /sp.autonomous requirements.md
   # Should show resume report and continue
   ```

3. **Test Phase Skip**:
   ```bash
   # Manually edit .specify/workflow-state.json
   # Set current_phase to 11
   /sp.autonomous requirements.md
   # Should jump to Phase 11
   ```

4. **Test Feature Resume** (COMPLEX project):
   ```bash
   # Set up COMPLEX project with 3 features
   # Complete F-01, start F-02
   # Kill process

   # Resume
   /sp.autonomous requirements.md
   # Should resume at F-02
   ```

---

## State File Locations

After integration, state files will be at:

```
.specify/
├── workflow-state.json          # Current state
├── workflow-progress.log        # Event log
└── workflow-state-*.json.bak    # Backups
```

---

## Validation Integration

Combine with workflow-validator:

```bash
# After phase execution
python3 "${STATE_SCRIPT}" phase-start ${PHASE}

# Run phase work
execute_phase ${PHASE}

# Validate with workflow-validator
VALIDATION_REPORT=$(validate_phase_quality ${PHASE})
GRADE=$(extract_grade_from_report "${VALIDATION_REPORT}")

# Save validation report path
python3 -c "
import json
state = json.load(open('.specify/workflow-state.json'))
state['validation_status']['validation_reports'].append('${VALIDATION_REPORT}')
json.dump(state, open('.specify/workflow-state.json', 'w'), indent=2)
"

# Mark complete with grade
python3 "${STATE_SCRIPT}" phase-complete ${PHASE} ${GRADE}
```

---

## Next Steps

1. Add state initialization to Phase 0
2. Add `phase-start` calls before each phase
3. Add `phase-complete` calls after validation
4. Add `feature-start` and `feature-complete` for COMPLEX projects
5. Add interrupt handler at beginning
6. Add resume logic for phase branching
7. Test thoroughly

**Result**: Fully resumable autonomous workflow!
