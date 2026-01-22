---
description: Full validation of Spec-Kit-Plus workflow - checks order, artifacts, and detects violations
---

# /q-validate

Perform comprehensive validation of the Spec-Kit-Plus workflow.

---

## What This Command Does

1. **Checks all phase artifacts** exist and are valid
2. **Validates JSON files** are parseable
3. **Checks markdown files** have required sections
4. **Detects violations** (skipped phases, out-of-order execution)
5. **Suggests fixes** for any issues found

---

## Execution Steps

### Step 1: Run Component Utilization Validation (NEW - CRITICAL)

**FIRST**, run the component utilization validation to check if skills/agents are being used:

```bash
python3 .claude/scripts/validate-utilization.py
```

This checks:
- Which skills are actually being invoked
- Which agents are actually being used
- Bypass detection (components exist but unused)
- Overall utilization percentage

**Report generated**: `.specify/validations/component-utilization-report.md`

### Step 2: Run Basic Status Check

Invoke the `workflow-validator` skill to get current workflow state.

### Step 2: Deep Validation

For each artifact, perform content validation:

#### JSON File Validation
```bash
# Check JSON files are valid
for f in .specify/*.json; do
    if [ -f "$f" ]; then
        python3 -c "import json; json.load(open('$f'))" 2>/dev/null && \
            echo "✓ $f is valid JSON" || \
            echo "✗ $f is INVALID JSON"
    fi
done
```

#### Markdown File Validation
```bash
# Check spec.md has required sections
if [ -f ".specify/spec.md" ]; then
    MISSING=""
    grep -q "## User Stories" .specify/spec.md || MISSING="$MISSING User Stories,"
    grep -q "## Functional Requirements" .specify/spec.md || MISSING="$MISSING Functional Requirements,"
    grep -q "## Non-Functional Requirements" .specify/spec.md || MISSING="$MISSING NFR,"

    if [ -z "$MISSING" ]; then
        echo "✓ spec.md has all required sections"
    else
        echo "✗ spec.md missing sections: $MISSING"
    fi
fi
```

#### Skill File Validation
```bash
# Check skills have frontmatter
for skill in .claude/skills/*/SKILL.md; do
    if [ -f "$skill" ]; then
        head -1 "$skill" | grep -q "^---" && \
            echo "✓ $skill has frontmatter" || \
            echo "✗ $skill missing frontmatter"
    fi
done
```

### Step 3: Order Validation

Check phases were executed in correct order:

```python
# Pseudo-code for order validation
phases_completed = []
for i, phase in enumerate(PHASE_ORDER):
    if artifact_exists(phase):
        phases_completed.append(i)

# Check for gaps
for i in range(1, max(phases_completed)):
    if i not in phases_completed:
        report_violation(f"Phase {i} was skipped")
```

### Step 4: Check Component Utilization Results

After validation, check if component utilization passed:

```bash
# Check the grade
GRADE=$(python3 -c "import json; print(json.load(open('.specify/validations/component-utilization.json'))['grade'])")

if [ "$GRADE" == "D" ] || [ "$GRADE" == "F" ]; then
    echo "❌ CRITICAL: Component utilization failed with grade $GRADE"
    echo "Review report: .specify/validations/component-utilization-report.md"
    exit 1
fi
```

### Step 5: Generate Combined Validation Report

Output detailed report combining all validations:

```markdown
# Workflow Validation Report

## Summary
- **Status**: VALID / INVALID
- **Violations**: 0 / N
- **Warnings**: 0 / N

## Phase Status
| Phase | Status | Artifact | Valid |
|-------|--------|----------|-------|
| 1. INIT | ✓ | .specify/ | ✓ |
| 2. ANALYZE PROJECT | ✓ | project-analysis.json | ✓ |
...

## Violations
(none)

## Warnings
- spec.md is shorter than expected (<500 lines)

## Recommendations
1. Complete phase 5 (GENERATE) before proceeding
2. Add more detail to spec.md
```

---

## Validation Rules

| Rule | Check | Severity |
|------|-------|----------|
| Sequential execution | Phases in order 1→13 | ERROR |
| Valid JSON | All .json files parseable | ERROR |
| Required sections | Markdown has headers | WARNING |
| Frontmatter present | Skills have --- block | ERROR |
| Task format | Tasks use `- [ ]` format | WARNING |
| Coverage threshold | Tests have 80%+ | WARNING |

---

## Example Output

```
╔════════════════════════════════════════════════════════════════╗
║                  WORKFLOW VALIDATION REPORT                     ║
╠════════════════════════════════════════════════════════════════╣
║  Status: VALID                                                 ║
║  Violations: 0                                                 ║
║  Warnings: 2                                                   ║
╠════════════════════════════════════════════════════════════════╣
║  Phase Validation:                                             ║
║  [✓] 1. INIT              - .specify/ exists                   ║
║  [✓] 2. ANALYZE PROJECT   - JSON valid                         ║
║  [✓] 3. ANALYZE REQS      - JSON valid                         ║
║  [✓] 4. GAP ANALYSIS      - JSON valid                         ║
║  [!] 5. GENERATE          - 9 skills (1 new)                   ║
║  [ ] 6. TEST              - Not started                        ║
╠════════════════════════════════════════════════════════════════╣
║  Warnings:                                                     ║
║  - gap-analysis.json: skills_missing is empty                  ║
║  - No test validation logs found                               ║
╠════════════════════════════════════════════════════════════════╣
║  Recommendation: Run TEST phase to validate generated skills   ║
╚════════════════════════════════════════════════════════════════╝
```
