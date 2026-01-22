#!/bin/bash
# validate-skill.sh - Validate SKILL.md quality
# Usage: ./validate-skill.sh <path/to/SKILL.md>

SKILL_PATH="$1"
SCORE=0
TOTAL=100
ISSUES=()

# Security: Validate path against symlink attacks
# Resolve symlinks and verify path is within .claude/skills/ directory
if command -v realpath >/dev/null 2>&1; then
    RESOLVED_PATH=$(realpath "$SKILL_PATH" 2>/dev/null)
    EXPECTED_BASE=$(realpath ".claude/skills" 2>/dev/null)

    if [ ! -f "$RESOLVED_PATH" ]; then
        echo "❌ FAIL: Skill file not found: $SKILL_PATH"
        exit 1
    fi

    # Verify path is within expected directory (prevent path traversal)
    if [[ "$RESOLVED_PATH" != "$EXPECTED_BASE"/* ]]; then
        echo "❌ FAIL: Path traversal detected - file must be within .claude/skills/"
        echo "   Resolved path: $RESOLVED_PATH"
        echo "   Expected base: $EXPECTED_BASE"
        exit 1
    fi
else
    # Fallback if realpath not available (basic check only)
    if [ ! -f "$SKILL_PATH" ]; then
        echo "❌ FAIL: Skill file not found: $SKILL_PATH"
        exit 1
    fi
    echo "⚠️  Warning: realpath not available, skipping symlink validation"
fi

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    SKILL QUALITY VALIDATION                     ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  File: $SKILL_PATH"
echo "╠════════════════════════════════════════════════════════════════╣"

# Check frontmatter (10%)
if head -20 "$SKILL_PATH" | grep -q "^---"; then
    if grep -q "^name:" "$SKILL_PATH"; then
        SCORE=$((SCORE + 4))
        echo "║  ✓ [4/4] Has name field"
    else
        ISSUES+=("Missing 'name:' in frontmatter")
        echo "║  ✗ [0/4] Missing name field"
    fi

    if grep -q "^description:" "$SKILL_PATH"; then
        SCORE=$((SCORE + 3))
        echo "║  ✓ [3/3] Has description field"
    else
        ISSUES+=("Missing 'description:' in frontmatter")
        echo "║  ✗ [0/3] Missing description field"
    fi

    if grep -q "^version:" "$SKILL_PATH"; then
        SCORE=$((SCORE + 3))
        echo "║  ✓ [3/3] Has version field"
    else
        ISSUES+=("Missing 'version:' in frontmatter")
        echo "║  ✗ [0/3] Missing version field"
    fi
else
    ISSUES+=("No frontmatter found (should start with ---)")
    echo "║  ✗ [0/10] No frontmatter"
fi

# Check name is kebab-case (5%)
# SECURITY FIX: Sanitize extracted name to prevent command injection
NAME=$(grep "^name:" "$SKILL_PATH" 2>/dev/null | sed 's/name: *//' | tr -d '\n\r' | head -c 100)
if echo "$NAME" | grep -qE "^[a-z][a-z0-9-]*[a-z0-9]$"; then
    SCORE=$((SCORE + 5))
    echo "║  ✓ [5/5] Name is kebab-case: $NAME"
else
    ISSUES+=("Name '$NAME' is not valid kebab-case")
    echo "║  ✗ [0/5] Name not kebab-case: $NAME"
fi

# Check description has triggers (10%)
if grep -qi "trigger" "$SKILL_PATH"; then
    SCORE=$((SCORE + 10))
    echo "║  ✓ [10/10] Description has triggers"
else
    ISSUES+=("Description should include 'Triggers:' keywords")
    echo "║  ✗ [0/10] No triggers in description"
fi

# Check workflow section (10%)
if grep -qE "^## (Workflow|Steps|Process|Execution)" "$SKILL_PATH"; then
    SCORE=$((SCORE + 10))
    echo "║  ✓ [10/10] Has workflow section"
else
    ISSUES+=("Missing ## Workflow (or Steps/Process) section")
    echo "║  ✗ [0/10] No workflow section"
fi

# Check code templates (15% - min 2 code blocks)
CODE_BLOCKS=$(grep -c '```' "$SKILL_PATH")
if [ "$CODE_BLOCKS" -ge 4 ]; then
    SCORE=$((SCORE + 15))
    echo "║  ✓ [15/15] Has $((CODE_BLOCKS / 2)) code examples"
elif [ "$CODE_BLOCKS" -ge 2 ]; then
    SCORE=$((SCORE + 8))
    ISSUES+=("Only $((CODE_BLOCKS / 2)) code block(s) - recommended 2+")
    echo "║  ⚠ [8/15] Only $((CODE_BLOCKS / 2)) code block"
else
    ISSUES+=("No code templates found")
    echo "║  ✗ [0/15] No code examples"
fi

# Check code syntax validity (15%)
# Extract code blocks and check basic syntax
SYNTAX_OK=true
# Simple check: look for obvious syntax errors
if grep -A 1000 '```typescript\|```javascript\|```python\|```bash' "$SKILL_PATH" | grep -q "undefined\|FIXME\|TODO"; then
    SCORE=$((SCORE + 10))
    ISSUES+=("Code blocks contain TODO/FIXME/undefined - may be incomplete")
    echo "║  ⚠ [10/15] Code has placeholders"
else
    SCORE=$((SCORE + 15))
    echo "║  ✓ [15/15] Code syntax appears valid"
fi

# Check validation section (10%)
if grep -qE "^## (Validation|Verification|Checklist|Success Criteria)" "$SKILL_PATH" || grep -q "\- \[ \]" "$SKILL_PATH"; then
    SCORE=$((SCORE + 10))
    echo "║  ✓ [10/10] Has validation section"
else
    ISSUES+=("Missing ## Validation section or checklist")
    echo "║  ✗ [0/10] No validation section"
fi

# Check for duplicates (10%)
SKILL_NAME=$(basename "$(dirname "$SKILL_PATH")")
SIMILAR_COUNT=$(find .claude/skills -name "SKILL.md" ! -path "$SKILL_PATH" -exec grep -l "$SKILL_NAME" {} \; 2>/dev/null | wc -l)
if [ "$SIMILAR_COUNT" -eq 0 ]; then
    SCORE=$((SCORE + 10))
    echo "║  ✓ [10/10] No duplicate skills found"
else
    SCORE=$((SCORE + 5))
    ISSUES+=("Found $SIMILAR_COUNT similar skill(s)")
    echo "║  ⚠ [5/10] Similar skills exist"
fi

# Check token efficiency (10%)
LINES=$(wc -l < "$SKILL_PATH")
# SECURITY FIX: Use wc -c instead of stat for cross-platform compatibility
SIZE=$(wc -c < "$SKILL_PATH" 2>/dev/null || echo 0)
if [ "$LINES" -lt 2000 ] && [ "$SIZE" -lt 51200 ]; then
    SCORE=$((SCORE + 10))
    echo "║  ✓ [10/10] Token efficient ($LINES lines, $SIZE bytes)"
elif [ "$LINES" -lt 3000 ]; then
    SCORE=$((SCORE + 5))
    ISSUES+=("Skill is large ($LINES lines) - consider splitting")
    echo "║  ⚠ [5/10] Large skill"
else
    ISSUES+=("Skill is too large ($LINES lines) - max 2000 recommended")
    echo "║  ✗ [0/10] Skill too large"
fi

# Check has examples (5%)
if grep -qi "example" "$SKILL_PATH"; then
    SCORE=$((SCORE + 5))
    echo "║  ✓ [5/5] Has examples"
else
    ISSUES+=("No examples found")
    echo "║  ✗ [0/5] No examples"
fi

# Determine grade
if [ "$SCORE" -ge 90 ]; then
    GRADE="A"
    STATUS="✅ APPROVED"
    EXIT_CODE=0
elif [ "$SCORE" -ge 80 ]; then
    GRADE="B"
    STATUS="✅ APPROVED"
    EXIT_CODE=0
elif [ "$SCORE" -ge 70 ]; then
    GRADE="C"
    STATUS="✅ APPROVED (with warnings)"
    EXIT_CODE=0
elif [ "$SCORE" -ge 50 ]; then
    GRADE="D"
    STATUS="❌ REJECTED (needs work)"
    EXIT_CODE=1
else
    GRADE="F"
    STATUS="❌ REJECTED (failing)"
    EXIT_CODE=1
fi

echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  SCORE: $SCORE/100"
echo "║  GRADE: $GRADE"
echo "║  STATUS: $STATUS"
echo "╠════════════════════════════════════════════════════════════════╣"

if [ ${#ISSUES[@]} -gt 0 ]; then
    echo "║  ISSUES FOUND:"
    for issue in "${ISSUES[@]}"; do
        echo "║  - $issue"
    done
    echo "╠════════════════════════════════════════════════════════════════╣"
fi

echo "╚════════════════════════════════════════════════════════════════╝"

exit $EXIT_CODE
