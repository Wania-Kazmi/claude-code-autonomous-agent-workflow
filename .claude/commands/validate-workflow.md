---
description: Validate workflow phases using Quality Gate Teacher. Grades outputs A-F and approves/rejects.
---

# /validate-workflow

Load and apply the workflow-validator skill to validate the current phase.

## Instructions

1. Read the workflow-validator skill from `.claude/skills/workflow-validator/SKILL.md`
2. Apply its validation criteria to the current workflow state
3. Generate a validation report with grades
4. Output APPROVED or REJECTED with specific feedback

## Quick Reference

```
GRADING SCALE:
- A (90-100%): Excellent - exceeds expectations
- B (80-89%):  Good - meets all requirements
- C (70-79%):  Acceptable - meets minimum requirements
- D (60-69%):  Poor - needs improvement → REJECTED
- F (<60%):    Failing - major issues → REJECTED
```

## Usage

```bash
# Validate current phase
/validate-workflow

# Check specific phase
/validate-workflow phase:constitution

# Full workflow status
/validate-workflow status
```
