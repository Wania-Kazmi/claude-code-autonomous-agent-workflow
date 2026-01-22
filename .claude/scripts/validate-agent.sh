#!/bin/bash
# validate-agent.sh - Validate agent quality
# Usage: ./validate-agent.sh <path/to/agent.md>

AGENT_PATH="$1"
SCORE=0
TOTAL=100
ISSUES=()

# Security: Validate path against symlink attacks
# Resolve symlinks and verify path is within .claude/agents/ directory
if command -v realpath >/dev/null 2>&1; then
    RESOLVED_PATH=$(realpath "$AGENT_PATH" 2>/dev/null)
    EXPECTED_BASE=$(realpath ".claude/agents" 2>/dev/null)

    if [ ! -f "$RESOLVED_PATH" ]; then
        echo "❌ FAIL: Agent file not found: $AGENT_PATH"
        exit 1
    fi

    # Verify path is within expected directory (prevent path traversal)
    if [[ "$RESOLVED_PATH" != "$EXPECTED_BASE"/* ]]; then
        echo "❌ FAIL: Path traversal detected - file must be within .claude/agents/"
        echo "   Resolved path: $RESOLVED_PATH"
        echo "   Expected base: $EXPECTED_BASE"
        exit 1
    fi
else
    # Fallback if realpath not available (basic check only)
    if [ ! -f "$AGENT_PATH" ]; then
        echo "❌ FAIL: Agent file not found: $AGENT_PATH"
        exit 1
    fi
    echo "⚠️  Warning: realpath not available, skipping symlink validation"
fi

AGENT_NAME=$(basename "$AGENT_PATH" .md)

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    AGENT QUALITY VALIDATION                     ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  File: $AGENT_PATH"
echo "║  Agent: $AGENT_NAME"
echo "╠════════════════════════════════════════════════════════════════╣"

# Check frontmatter fields (10%)
FRONTMATTER_SCORE=0
for FIELD in "name:" "description:" "tools:" "model:"; do
    if grep -q "^$FIELD" "$AGENT_PATH"; then
        FRONTMATTER_SCORE=$((FRONTMATTER_SCORE + 3))
    else
        ISSUES+=("Missing frontmatter field: $FIELD")
    fi
done

if [ "$FRONTMATTER_SCORE" -ge 10 ]; then
    FRONTMATTER_SCORE=10
fi
SCORE=$((SCORE + FRONTMATTER_SCORE))
echo "║  $([ $FRONTMATTER_SCORE -ge 10 ] && echo '✓' || echo '⚠') [$FRONTMATTER_SCORE/10] Frontmatter complete"

# Check model is valid (15%)
# SECURITY FIX: Sanitize extracted model value
MODEL=$(grep "^model:" "$AGENT_PATH" 2>/dev/null | sed 's/model: *//' | tr -d '\n\r' | head -c 20)
if echo "$MODEL" | grep -qE "^(haiku|sonnet|opus)$"; then
    SCORE=$((SCORE + 15))
    echo "║  ✓ [15/15] Valid model: $MODEL"
else
    ISSUES+=("Invalid model: '$MODEL' (must be haiku, sonnet, or opus)")
    echo "║  ✗ [0/15] Invalid model: $MODEL"
fi

# Check model appropriateness (15%)
# Simple heuristic: check if model matches agent purpose
MODEL_APPROPRIATE=false

if echo "$AGENT_NAME" | grep -qE "(git-ops|file-ops|format-checker)"; then
    # These should use haiku
    if [ "$MODEL" == "haiku" ]; then
        MODEL_APPROPRIATE=true
    else
        ISSUES+=("Agent '$AGENT_NAME' should use 'haiku' model (lightweight task)")
    fi
elif echo "$AGENT_NAME" | grep -qE "(architect|planner|security)"; then
    # These should use opus
    if [ "$MODEL" == "opus" ]; then
        MODEL_APPROPRIATE=true
    else
        ISSUES+=("Agent '$AGENT_NAME' should use 'opus' model (complex reasoning)")
    fi
else
    # Most agents should use sonnet
    if [ "$MODEL" == "sonnet" ]; then
        MODEL_APPROPRIATE=true
    else
        ISSUES+=("Agent '$AGENT_NAME' may be better with 'sonnet' model")
    fi
fi

if $MODEL_APPROPRIATE; then
    SCORE=$((SCORE + 15))
    echo "║  ✓ [15/15] Model appropriate for task"
else
    SCORE=$((SCORE + 8))
    echo "║  ⚠ [8/15] Model may not be optimal"
fi

# Check tools are minimal (15%)
if grep -q "tools:.*\*" "$AGENT_PATH"; then
    ISSUES+=("Tools list uses wildcard (*) - should be minimal/specific")
    echo "║  ✗ [0/15] Tools too broad (uses *)"
else
    TOOLS_COUNT=$(grep "^tools:" "$AGENT_PATH" | sed 's/tools: *//' | tr ',' '\n' | wc -l)
    if [ "$TOOLS_COUNT" -le 5 ]; then
        SCORE=$((SCORE + 15))
        echo "║  ✓ [15/15] Tools minimal ($TOOLS_COUNT tools)"
    elif [ "$TOOLS_COUNT" -le 8 ]; then
        SCORE=$((SCORE + 10))
        ISSUES+=("Tools list has $TOOLS_COUNT tools - consider reducing")
        echo "║  ⚠ [10/15] Tools list moderate"
    else
        SCORE=$((SCORE + 5))
        ISSUES+=("Tools list has $TOOLS_COUNT tools - too many")
        echo "║  ⚠ [5/15] Too many tools"
    fi
fi

# Check required sections (40%)
SECTIONS_SCORE=0

if grep -qiE "^## (When to Use|Trigger|Use When)" "$AGENT_PATH"; then
    SECTIONS_SCORE=$((SECTIONS_SCORE + 10))
    echo "║  ✓ [10/10] Has 'When to Use' section"
else
    ISSUES+=("Missing '## When to Use' section")
    echo "║  ✗ [0/10] No 'When to Use' section"
fi

if grep -qiE "^## (Workflow|Steps|Process)" "$AGENT_PATH"; then
    SECTIONS_SCORE=$((SECTIONS_SCORE + 15))
    echo "║  ✓ [15/15] Has 'Workflow' section"
else
    ISSUES+=("Missing '## Workflow' section")
    echo "║  ✗ [0/15] No 'Workflow' section"
fi

if grep -qiE "^## (Success|Success Criteria|Validation)" "$AGENT_PATH"; then
    SECTIONS_SCORE=$((SECTIONS_SCORE + 15))
    echo "║  ✓ [15/15] Has 'Success Criteria' section"
else
    ISSUES+=("Missing '## Success Criteria' section")
    echo "║  ✗ [0/15] No 'Success' section"
fi

if grep -qiE "^## (Fail|Failure|Error|Troubleshoot)" "$AGENT_PATH"; then
    SECTIONS_SCORE=$((SECTIONS_SCORE + 10))
    echo "║  ✓ [10/10] Has 'Failure Handling' section"
else
    ISSUES+=("Missing '## Failure Handling' section")
    echo "║  ✗ [0/10] No 'Failure' section"
fi

SCORE=$((SCORE + SECTIONS_SCORE))

# Check for vague phrases (10% - deduct if found)
VAGUE_CHECK=10
if grep -qiE "(as needed|if necessary|when appropriate|etc\\.)" "$AGENT_PATH"; then
    VAGUE_CHECK=0
    ISSUES+=("Contains vague phrases (as needed, if necessary, etc.) - be more specific")
    echo "║  ✗ [0/10] Contains vague language"
else
    SCORE=$((SCORE + 10))
    echo "║  ✓ [10/10] Instructions unambiguous"
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
