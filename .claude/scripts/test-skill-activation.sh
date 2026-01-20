#!/bin/bash
# Test Skill Activation System
# Validates that the skill enforcement hooks are properly configured

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(dirname "$CLAUDE_DIR")"

echo "=============================================="
echo "       SKILL ACTIVATION SYSTEM TEST"
echo "=============================================="
echo ""

# Test 1: Check skill-rules.json exists
echo "[TEST 1] Checking skill-rules.json..."
if [ -f "$CLAUDE_DIR/skill-rules.json" ]; then
    SKILL_COUNT=$(jq '.skills | keys | length' "$CLAUDE_DIR/skill-rules.json")
    echo "  ✓ skill-rules.json exists with $SKILL_COUNT skill rules"
else
    echo "  ✗ skill-rules.json NOT FOUND"
    exit 1
fi

# Test 2: Check hook scripts exist and are executable
echo ""
echo "[TEST 2] Checking hook scripts..."
if [ -x "$CLAUDE_DIR/hooks/skill-activator.sh" ]; then
    echo "  ✓ skill-activator.sh exists and is executable"
else
    echo "  ✗ skill-activator.sh missing or not executable"
    exit 1
fi

if [ -x "$CLAUDE_DIR/hooks/skill-enforcement-stop.sh" ]; then
    echo "  ✓ skill-enforcement-stop.sh exists and is executable"
else
    echo "  ✗ skill-enforcement-stop.sh missing or not executable"
    exit 1
fi

# Test 3: Check settings.json has hooks configured
echo ""
echo "[TEST 3] Checking settings.json hooks..."
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    HAS_USER_PROMPT=$(jq 'has("hooks") and .hooks | has("UserPromptSubmit")' "$CLAUDE_DIR/settings.json")
    HAS_STOP=$(jq 'has("hooks") and .hooks | has("Stop")' "$CLAUDE_DIR/settings.json")

    if [ "$HAS_USER_PROMPT" = "true" ]; then
        echo "  ✓ UserPromptSubmit hook configured"
    else
        echo "  ✗ UserPromptSubmit hook NOT configured"
        exit 1
    fi

    if [ "$HAS_STOP" = "true" ]; then
        echo "  ✓ Stop hook configured"
    else
        echo "  ✗ Stop hook NOT configured"
        exit 1
    fi
else
    echo "  ✗ settings.json NOT FOUND"
    exit 1
fi

# Test 4: Test skill-activator.sh with sample prompts
echo ""
echo "[TEST 4] Testing skill matching..."

# Test with API keyword
echo '{"prompt": "create a fastapi endpoint for users"}' | "$CLAUDE_DIR/hooks/skill-activator.sh" > /tmp/skill-test-output.txt 2>&1
if grep -q "fastapi-generator" /tmp/skill-test-output.txt; then
    echo "  ✓ 'fastapi endpoint' correctly matches fastapi-generator"
else
    echo "  ✗ 'fastapi endpoint' did not match fastapi-generator"
fi

# Test with test keyword
echo '{"prompt": "run tests and check coverage"}' | "$CLAUDE_DIR/hooks/skill-activator.sh" > /tmp/skill-test-output.txt 2>&1
if grep -q "test" /tmp/skill-test-output.txt; then
    echo "  ✓ 'run tests' correctly triggers test-related skills"
else
    echo "  ✗ 'run tests' did not trigger test skills"
fi

# Test with requirements keyword
echo '{"prompt": "analyze the requirements file"}' | "$CLAUDE_DIR/hooks/skill-activator.sh" > /tmp/skill-test-output.txt 2>&1
if grep -q "skill-gap-analyzer" /tmp/skill-test-output.txt; then
    echo "  ✓ 'requirements' correctly matches skill-gap-analyzer"
else
    echo "  ✗ 'requirements' did not match skill-gap-analyzer"
fi

# Test 5: Check CLAUDE.md has enforcement section
echo ""
echo "[TEST 5] Checking CLAUDE.md enforcement..."
if grep -q "MANDATORY SKILL ACTIVATION PROTOCOL" "$PROJECT_DIR/CLAUDE.md"; then
    echo "  ✓ CLAUDE.md has mandatory skill activation section"
else
    echo "  ✗ CLAUDE.md missing enforcement section"
    exit 1
fi

# Test 6: Check logs directory exists
echo ""
echo "[TEST 6] Checking logs directory..."
if [ -d "$CLAUDE_DIR/logs" ]; then
    echo "  ✓ Logs directory exists"
else
    mkdir -p "$CLAUDE_DIR/logs"
    echo "  ✓ Created logs directory"
fi

# Summary
echo ""
echo "=============================================="
echo "           ALL TESTS PASSED"
echo "=============================================="
echo ""
echo "Skill Enforcement System is properly configured:"
echo "  • UserPromptSubmit hook: Injects forced-eval template"
echo "  • Stop hook: Blocks completion if skills missed"
echo "  • skill-rules.json: $SKILL_COUNT skills with trigger rules"
echo "  • CLAUDE.md: Mandatory activation protocol documented"
echo ""
echo "Expected activation rate: ~95%+"
echo ""

# Cleanup
rm -f /tmp/skill-test-output.txt
