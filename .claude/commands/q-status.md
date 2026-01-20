---
description: Check Spec-Kit-Plus workflow status with Quality Gate grades - shows phase progress, validation reports, and next actions
---

# /q-status

Check the current state of Spec-Kit-Plus workflow with Quality Gate validation grades.

---

## What This Command Does

1. **Scans project** for workflow artifacts
2. **Reads validation reports** from `.specify/validations/`
3. **Shows grades** (A/B/C/D/F) for each completed phase
4. **Identifies current phase** and overall workflow health
5. **Reports violations** - skipped or rejected phases
6. **Suggests next action**

---

## Execution Steps

### Step 1: Check All Phase Artifacts and Grades

```bash
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              WORKFLOW STATUS REPORT (Quality Gate)             ║"
echo "╠════════════════════════════════════════════════════════════════╣"

# Track phases
CURRENT_PHASE=0
VIOLATIONS=""
TOTAL_SCORE=0
PHASES_GRADED=0

# Helper function to get grade from validation report
get_grade() {
    PHASE=$1
    REPORT=".specify/validations/phase-$PHASE-report.md"
    if [ -f "$REPORT" ]; then
        GRADE=$(grep -m1 "Grade:" "$REPORT" | sed 's/.*Grade: //' | head -c1)
        SCORE=$(grep -m1 "Score:" "$REPORT" | sed 's/.*Score: //' | sed 's/\/100//')
        echo "$GRADE|$SCORE"
    else
        echo "-|-"
    fi
}

# Phase 1: INIT
if [ -d ".specify" ] && [ -d ".claude" ]; then
    RESULT=$(get_grade 1)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 1. INIT                          Grade: $GRADE ($SCORE/100) ║"
        TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
        PHASES_GRADED=$((PHASES_GRADED + 1))
    else
        echo "║  [✓] 1. INIT                          Grade: PENDING       ║"
    fi
    PHASE_1=true
    CURRENT_PHASE=1
else
    echo "║  [ ] 1. INIT                                                   ║"
    PHASE_1=false
fi

# Phase 2: ANALYZE PROJECT
if [ -f ".specify/project-analysis.json" ]; then
    RESULT=$(get_grade 2)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 2. ANALYZE PROJECT                Grade: $GRADE ($SCORE/100) ║"
        TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
        PHASES_GRADED=$((PHASES_GRADED + 1))
    else
        echo "║  [✓] 2. ANALYZE PROJECT                Grade: PENDING       ║"
    fi
    PHASE_2=true
    CURRENT_PHASE=2
else
    echo "║  [ ] 2. ANALYZE PROJECT                                        ║"
    PHASE_2=false
fi

# Phase 3: ANALYZE REQUIREMENTS
if [ -f ".specify/requirements-analysis.json" ]; then
    RESULT=$(get_grade 3)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 3. ANALYZE REQUIREMENTS          Grade: $GRADE ($SCORE/100) ║"
        TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
        PHASES_GRADED=$((PHASES_GRADED + 1))
    else
        echo "║  [✓] 3. ANALYZE REQUIREMENTS          Grade: PENDING       ║"
    fi
    PHASE_3=true
    CURRENT_PHASE=3
else
    echo "║  [ ] 3. ANALYZE REQUIREMENTS                                   ║"
    PHASE_3=false
fi

# Phase 4: GAP ANALYSIS
if [ -f ".specify/gap-analysis.json" ]; then
    RESULT=$(get_grade 4)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 4. GAP ANALYSIS                  Grade: $GRADE ($SCORE/100) ║"
        TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
        PHASES_GRADED=$((PHASES_GRADED + 1))
    else
        echo "║  [✓] 4. GAP ANALYSIS                  Grade: PENDING       ║"
    fi
    PHASE_4=true
    CURRENT_PHASE=4
else
    echo "║  [ ] 4. GAP ANALYSIS                                           ║"
    PHASE_4=false
fi

# Phase 5: GENERATE (check skill count > 9 base skills)
SKILL_COUNT=$(find .claude/skills -name "SKILL.md" -type f 2>/dev/null | wc -l)
if [ "$SKILL_COUNT" -gt 9 ]; then
    RESULT=$(get_grade 5)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 5. GENERATE ($SKILL_COUNT skills)       Grade: $GRADE ($SCORE/100) ║"
        TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
        PHASES_GRADED=$((PHASES_GRADED + 1))
    else
        echo "║  [✓] 5. GENERATE ($SKILL_COUNT skills)       Grade: PENDING       ║"
    fi
    PHASE_5=true
    CURRENT_PHASE=5
else
    echo "║  [ ] 5. GENERATE ($SKILL_COUNT base skills)                          ║"
    PHASE_5=false
fi

# Phase 6: TEST
if [ -f ".specify/validations/phase-6-report.md" ]; then
    RESULT=$(get_grade 6)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    echo "║  [✓] 6. TEST                            Grade: $GRADE ($SCORE/100) ║"
    TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
    PHASES_GRADED=$((PHASES_GRADED + 1))
    PHASE_6=true
    CURRENT_PHASE=6
else
    echo "║  [ ] 6. TEST                                                   ║"
    PHASE_6=false
fi

# Phase 7: CONSTITUTION
if [ -f ".specify/constitution.md" ]; then
    RESULT=$(get_grade 7)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 7. CONSTITUTION                  Grade: $GRADE ($SCORE/100) ║"
        TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
        PHASES_GRADED=$((PHASES_GRADED + 1))
    else
        echo "║  [✓] 7. CONSTITUTION                  Grade: PENDING       ║"
    fi
    PHASE_7=true
    CURRENT_PHASE=7
else
    echo "║  [ ] 7. CONSTITUTION                                           ║"
    PHASE_7=false
fi

# Phase 8: SPEC
if [ -f ".specify/spec.md" ]; then
    RESULT=$(get_grade 8)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 8. SPEC                          Grade: $GRADE ($SCORE/100) ║"
        TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
        PHASES_GRADED=$((PHASES_GRADED + 1))
    else
        echo "║  [✓] 8. SPEC                          Grade: PENDING       ║"
    fi
    PHASE_8=true
    CURRENT_PHASE=8
else
    echo "║  [ ] 8. SPEC                                                   ║"
    PHASE_8=false
fi

# Phase 9: PLAN
if [ -f ".specify/plan.md" ]; then
    RESULT=$(get_grade 9)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 9. PLAN                          Grade: $GRADE ($SCORE/100) ║"
        TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
        PHASES_GRADED=$((PHASES_GRADED + 1))
    else
        echo "║  [✓] 9. PLAN                          Grade: PENDING       ║"
    fi
    PHASE_9=true
    CURRENT_PHASE=9
else
    echo "║  [ ] 9. PLAN                                                   ║"
    PHASE_9=false
fi

# Phase 10: TASKS
if [ -f ".specify/tasks.md" ]; then
    RESULT=$(get_grade 10)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 10. TASKS                        Grade: $GRADE ($SCORE/100) ║"
        TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
        PHASES_GRADED=$((PHASES_GRADED + 1))
    else
        echo "║  [✓] 10. TASKS                        Grade: PENDING       ║"
    fi
    PHASE_10=true
    CURRENT_PHASE=10
else
    echo "║  [ ] 10. TASKS                                                  ║"
    PHASE_10=false
fi

# Phase 11: IMPLEMENT
if [ -f ".specify/tasks.md" ]; then
    TOTAL=$(grep -c "\- \[" .specify/tasks.md 2>/dev/null || echo 0)
    DONE=$(grep -c "\- \[X\]\|\- \[x\]" .specify/tasks.md 2>/dev/null || echo 0)
    if [ "$DONE" -gt 0 ]; then
        RESULT=$(get_grade 11)
        GRADE=${RESULT%|*}
        SCORE=${RESULT#*|}
        if [ "$GRADE" != "-" ]; then
            echo "║  [~] 11. IMPLEMENT ($DONE/$TOTAL)         Grade: $GRADE ($SCORE/100) ║"
            TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
            PHASES_GRADED=$((PHASES_GRADED + 1))
        else
            echo "║  [~] 11. IMPLEMENT ($DONE/$TOTAL tasks)  Grade: IN PROGRESS  ║"
        fi
        CURRENT_PHASE=11
    else
        echo "║  [ ] 11. IMPLEMENT                                              ║"
    fi
else
    echo "║  [ ] 11. IMPLEMENT                                              ║"
fi

# Phase 12: QA
if [ -f ".specify/validations/phase-12-report.md" ]; then
    RESULT=$(get_grade 12)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    echo "║  [✓] 12. QA                            Grade: $GRADE ($SCORE/100) ║"
    TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
    PHASES_GRADED=$((PHASES_GRADED + 1))
    PHASE_12=true
    CURRENT_PHASE=12
else
    echo "║  [ ] 12. QA                                                    ║"
    PHASE_12=false
fi

# Phase 13: DELIVER
if git log --oneline -1 2>/dev/null | grep -qi "autonomous build complete\|spec-kit-plus"; then
    RESULT=$(get_grade 13)
    GRADE=${RESULT%|*}
    SCORE=${RESULT#*|}
    if [ "$GRADE" != "-" ]; then
        echo "║  [✓] 13. DELIVER                      Grade: $GRADE ($SCORE/100) ║"
    else
        echo "║  [✓] 13. DELIVER                      COMPLETE!            ║"
    fi
    CURRENT_PHASE=13
else
    echo "║  [ ] 13. DELIVER                                               ║"
fi

# Calculate average grade
if [ "$PHASES_GRADED" -gt 0 ]; then
    AVG_SCORE=$((TOTAL_SCORE / PHASES_GRADED))
    if [ "$AVG_SCORE" -ge 90 ]; then OVERALL_GRADE="A"
    elif [ "$AVG_SCORE" -ge 80 ]; then OVERALL_GRADE="B"
    elif [ "$AVG_SCORE" -ge 70 ]; then OVERALL_GRADE="C"
    elif [ "$AVG_SCORE" -ge 50 ]; then OVERALL_GRADE="D"
    else OVERALL_GRADE="F"
    fi
else
    AVG_SCORE=0
    OVERALL_GRADE="-"
fi

echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Current Phase: $((CURRENT_PHASE + 1))                                                ║"
echo "║  Overall Grade: $OVERALL_GRADE (Avg: $AVG_SCORE/100)                                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
```

### Step 2: Check Validation Reports

List validation reports and check for any REJECTED phases:

```bash
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    VALIDATION REPORTS                          ║"
echo "╠════════════════════════════════════════════════════════════════╣"

if [ -d ".specify/validations" ]; then
    for report in .specify/validations/phase-*-report.md; do
        if [ -f "$report" ]; then
            PHASE=$(echo "$report" | grep -o 'phase-[0-9]*' | grep -o '[0-9]*')
            STATUS=$(grep -m1 "Status:" "$report" | sed 's/.*Status: //')
            GRADE=$(grep -m1 "Grade:" "$report" | sed 's/.*Grade: //' | head -c1)

            if [ "$STATUS" == "REJECTED" ] || [ "$STATUS" == "REJECTED" ]; then
                echo "║  Phase $PHASE: REJECTED (Grade $GRADE) ← NEEDS ATTENTION        ║"
            else
                echo "║  Phase $PHASE: APPROVED (Grade $GRADE)                          ║"
            fi
        fi
    done
else
    echo "║  No validation reports found                                   ║"
    echo "║  Run /sp.autonomous to generate validation reports             ║"
fi

echo "╚════════════════════════════════════════════════════════════════╝"
```

### Step 3: Check for Violations

Look for out-of-order execution:
- If Phase N is complete but Phase N-1 is not → VIOLATION
- If Phase has REJECTED status but later phase exists → VIOLATION

### Step 4: Suggest Next Action

Based on current phase and validation status, recommend:

| Current Phase | Grade | Next Action |
|---------------|-------|-------------|
| 0 (not started) | - | Run `/sp.autonomous requirements/your-file.md` |
| Any | D/F | Fix issues identified in validation report |
| 1 (INIT) | A/B/C | Analyze current project structure |
| 2 (ANALYZE) | A/B/C | Read and analyze requirements file |
| 3 (REQS) | A/B/C | Run gap analysis |
| 4 (GAP) | A/B/C | Generate missing skills/agents/hooks |
| 5 (GENERATE) | A/B/C | Test generated components |
| 6 (TEST) | A/B/C | Create constitution.md |
| 7 (CONSTITUTION) | A/B/C | Generate specification |
| 8 (SPEC) | A/B/C | Create implementation plan |
| 9 (PLAN) | A/B/C | Generate task breakdown |
| 10 (TASKS) | A/B/C | Start implementing with TDD |
| 11 (IMPLEMENT) | A/B/C | Run QA checks |
| 12 (QA) | A/B/C | Commit and deliver |
| 13 (DELIVER) | A/B/C | COMPLETE! 🎉 |

### Step 5: Output Status JSON

Create `.specify/workflow-status.json` with full status for programmatic access:

```json
{
  "current_phase": 5,
  "overall_grade": "B",
  "average_score": 85,
  "phases": {
    "1": { "status": "complete", "grade": "A", "score": 100 },
    "2": { "status": "complete", "grade": "B", "score": 85 },
    "3": { "status": "complete", "grade": "A", "score": 92 },
    "4": { "status": "complete", "grade": "B", "score": 88 },
    "5": { "status": "in_progress", "grade": null, "score": null }
  },
  "violations": [],
  "rejected_phases": [],
  "next_action": "Complete Phase 5 GENERATE"
}
```

---

## Example Output

```
╔════════════════════════════════════════════════════════════════╗
║              WORKFLOW STATUS REPORT (Quality Gate)             ║
╠════════════════════════════════════════════════════════════════╣
║  [✓] 1. INIT                          Grade: A (100/100)       ║
║  [✓] 2. ANALYZE PROJECT               Grade: B (85/100)        ║
║  [✓] 3. ANALYZE REQUIREMENTS          Grade: A (92/100)        ║
║  [✓] 4. GAP ANALYSIS                  Grade: B (88/100)        ║
║  [→] 5. GENERATE                      ← CURRENT                ║
║  [ ] 6. TEST                                                   ║
║  [ ] 7. CONSTITUTION                                           ║
║  [ ] 8. SPEC                                                   ║
║  [ ] 9. PLAN                                                   ║
║  [ ] 10. TASKS                                                 ║
║  [ ] 11. IMPLEMENT                                             ║
║  [ ] 12. QA                                                    ║
║  [ ] 13. DELIVER                                               ║
╠════════════════════════════════════════════════════════════════╣
║  Current Phase: 5                                              ║
║  Overall Grade: B (Avg: 91/100)                                ║
╚════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════╗
║                    VALIDATION REPORTS                          ║
╠════════════════════════════════════════════════════════════════╣
║  Phase 1: APPROVED (Grade A)                                   ║
║  Phase 2: APPROVED (Grade B)                                   ║
║  Phase 3: APPROVED (Grade A)                                   ║
║  Phase 4: APPROVED (Grade B)                                   ║
╚════════════════════════════════════════════════════════════════╝

Next: Generate missing skills (express-patterns, postgresql-patterns)
      These skills must pass Quality Gate validation (Grade C or higher)
```

---

## Grade Reference

| Grade | Score Range | Meaning | Action |
|-------|-------------|---------|--------|
| A | 90-100 | Excellent | Proceed immediately |
| B | 80-89 | Good | Proceed with confidence |
| C | 70-79 | Acceptable | Proceed, minor improvements later |
| D | 50-69 | Needs Work | **STOP** - Fix issues first |
| F | 0-49 | Fail | **STOP** - Major rework needed |

---

## Related Commands

| Command | Purpose |
|---------|---------|
| `/q-status` | Check current workflow state with grades (this command) |
| `/q-validate` | Full validation with detailed quality checks |
| `/q-reset` | Reset workflow (clear .specify/) |
| `/sp.autonomous` | Run full autonomous workflow |
