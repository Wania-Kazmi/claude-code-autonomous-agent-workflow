#!/bin/bash
# test-security-fixes.sh - Test security fixes in validation scripts
# Tests path traversal protection, symlink attack prevention, and other security measures

# Note: Don't use set -e as we're catching failures with pass/fail functions

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          SECURITY FIXES VALIDATION TEST SUITE                  ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo ""

PASS_COUNT=0
FAIL_COUNT=0
TEST_COUNT=0

pass() {
    ((PASS_COUNT++))
    ((TEST_COUNT++))
    echo "✅ PASS: $1"
}

fail() {
    ((FAIL_COUNT++))
    ((TEST_COUNT++))
    echo "❌ FAIL: $1"
}

test_section() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "$1"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# Test 1: validate-utilization.py Security Fixes
# ═══════════════════════════════════════════════════════════════════

test_section "Test 1: validate-utilization.py - Path Traversal Protection"

# Test 1.1: is_safe_path function exists
if grep -q "def is_safe_path" .claude/scripts/validate-utilization.py; then
    pass "is_safe_path() function defined"
else
    fail "is_safe_path() function not found"
fi

# Test 1.2: Path traversal protection in transcript discovery
if grep -q "is_safe_path(claude_dir, f)" .claude/scripts/validate-utilization.py; then
    pass "Path traversal protection applied to transcript discovery"
else
    fail "Path traversal protection missing from transcript discovery"
fi

# Test 1.3: parse_phase_arg function exists
if grep -q "def parse_phase_arg" .claude/scripts/validate-utilization.py; then
    pass "parse_phase_arg() function defined"
else
    fail "parse_phase_arg() function not found"
fi

# Test 1.4: Phase argument validation (1-20 range)
if grep -q "1 <= phase <= 20" .claude/scripts/validate-utilization.py; then
    pass "Phase argument validated for reasonable bounds (1-20)"
else
    fail "Phase argument bounds checking missing"
fi

# Test 1.5: File permissions using os.fdopen
if grep -q "os.fdopen.*0o600" .claude/scripts/validate-utilization.py; then
    pass "Secure file permissions (0600) applied to output files"
else
    fail "Secure file permissions not applied"
fi

# Test 1.6: Specific exception handling (no bare except)
if grep -q "except (json.JSONDecodeError, IOError, OSError" .claude/scripts/validate-utilization.py; then
    pass "Specific exception types used (no bare except)"
else
    fail "Bare except clauses still present"
fi

# Test 1.7: Directory permissions
if grep -q "os.makedirs.*0o700" .claude/scripts/validate-utilization.py; then
    pass "Secure directory permissions (0700) applied"
else
    fail "Secure directory permissions not applied"
fi

# ═══════════════════════════════════════════════════════════════════
# Test 2: validate-skill.sh Security Fixes
# ═══════════════════════════════════════════════════════════════════

test_section "Test 2: validate-skill.sh - Symlink Attack Prevention"

# Test 2.1: realpath usage
if grep -q "realpath" .claude/scripts/validate-skill.sh; then
    pass "realpath used to resolve symlinks"
else
    fail "realpath not used"
fi

# Test 2.2: Path validation against base directory
if grep -q 'RESOLVED_PATH.*EXPECTED_BASE' .claude/scripts/validate-skill.sh; then
    pass "Path validated against expected base directory"
else
    fail "Path validation missing"
fi

# Test 2.3: Expected base is .claude/skills
if grep -q '.claude/skills' .claude/scripts/validate-skill.sh; then
    pass "Validates against .claude/skills directory"
else
    fail "Expected base directory not set correctly"
fi

# Test 2.4: Fallback for systems without realpath
if grep -q "command -v realpath" .claude/scripts/validate-skill.sh; then
    pass "Fallback provided for systems without realpath"
else
    fail "No fallback for missing realpath"
fi

# ═══════════════════════════════════════════════════════════════════
# Test 3: validate-agent.sh Security Fixes
# ═══════════════════════════════════════════════════════════════════

test_section "Test 3: validate-agent.sh - Symlink Attack Prevention"

# Test 3.1: realpath usage
if grep -q "realpath" .claude/scripts/validate-agent.sh; then
    pass "realpath used to resolve symlinks"
else
    fail "realpath not used"
fi

# Test 3.2: Path validation against base directory
if grep -q 'RESOLVED_PATH.*EXPECTED_BASE' .claude/scripts/validate-agent.sh; then
    pass "Path validated against expected base directory"
else
    fail "Path validation missing"
fi

# Test 3.3: Expected base is .claude/agents
if grep -q '.claude/agents' .claude/scripts/validate-agent.sh; then
    pass "Validates against .claude/agents directory"
else
    fail "Expected base directory not set correctly"
fi

# ═══════════════════════════════════════════════════════════════════
# Test 4: validate-hook.sh Security Fixes
# ═══════════════════════════════════════════════════════════════════

test_section "Test 4: validate-hook.sh - Path Validation"

# Test 4.1: realpath usage
if grep -q "realpath" .claude/scripts/validate-hook.sh; then
    pass "realpath used to resolve symlinks"
else
    fail "realpath not used"
fi

# Test 4.2: Expected base is .claude
if grep -q 'realpath ".claude"' .claude/scripts/validate-hook.sh; then
    pass "Validates against .claude directory"
else
    fail "Expected base directory not set correctly"
fi

# Test 4.3: Python injection fix still present
if grep -q "sys.argv\[1\]" .claude/scripts/validate-hook.sh; then
    pass "Python injection fix preserved (sys.argv[1] usage)"
else
    fail "Python injection fix may have been removed"
fi

# Test 4.4: Heredoc with quoted delimiter
if grep -q "<<'PYTHON'" .claude/scripts/validate-hook.sh; then
    pass "Heredoc uses quoted delimiter (prevents variable expansion)"
else
    fail "Heredoc delimiter not quoted"
fi

# ═══════════════════════════════════════════════════════════════════
# Test 5: Functional Tests
# ═══════════════════════════════════════════════════════════════════

test_section "Test 5: Functional Tests - Verify Fixes Don't Break Functionality"

# Test 5.1: validate-utilization.py runs successfully
if python3 .claude/scripts/validate-utilization.py > /dev/null 2>&1; then
    pass "validate-utilization.py executes successfully"
else
    fail "validate-utilization.py execution failed"
fi

# Test 5.2: validate-skill.sh runs successfully on valid file
# Note: Allow non-zero exit (script may return 1 for warnings) but check it produces output
if bash .claude/scripts/validate-skill.sh .claude/skills/coding-standards/SKILL.md 2>&1 | grep -q "SKILL QUALITY VALIDATION"; then
    pass "validate-skill.sh executes successfully on valid skill"
else
    fail "validate-skill.sh execution failed"
fi

# Test 5.3: validate-agent.sh runs successfully on valid file
# Note: Allow non-zero exit (script may return 1 for warnings) but check it produces output
if bash .claude/scripts/validate-agent.sh .claude/agents/code-reviewer.md 2>&1 | grep -q "AGENT QUALITY VALIDATION"; then
    pass "validate-agent.sh executes successfully on valid agent"
else
    fail "validate-agent.sh execution failed"
fi

# Test 5.4: validate-hook.sh runs successfully on valid file
if bash .claude/scripts/validate-hook.sh .claude/settings.json > /dev/null 2>&1; then
    pass "validate-hook.sh executes successfully on valid hooks file"
else
    fail "validate-hook.sh execution failed"
fi

# ═══════════════════════════════════════════════════════════════════
# Test 6: Security Regression Tests
# ═══════════════════════════════════════════════════════════════════

test_section "Test 6: Security Regression Tests"

# Test 6.1: No bare except clauses remain
if ! grep -q "^[[:space:]]*except:[[:space:]]*$" .claude/scripts/validate-utilization.py 2>/dev/null; then
    pass "No bare 'except:' clauses found"
else
    BARE_EXCEPT_COUNT=$(grep -c "^[[:space:]]*except:[[:space:]]*$" .claude/scripts/validate-utilization.py 2>/dev/null)
    fail "Found $BARE_EXCEPT_COUNT bare 'except:' clauses"
fi

# Test 6.2: No hardcoded credentials
if ! grep -iE "(password|api_key|secret|token).*=.*['\"]" .claude/scripts/validate-*.{py,sh} 2>/dev/null; then
    pass "No hardcoded credentials found"
else
    fail "Potential hardcoded credentials detected"
fi

# Test 6.3: No eval() or exec() usage in Python
if ! grep -E "(eval|exec)\(" .claude/scripts/validate-utilization.py 2>/dev/null; then
    pass "No eval() or exec() usage found"
else
    fail "Dangerous eval() or exec() usage detected"
fi

# Test 6.4: No shell=True in subprocess calls
if ! grep "shell=True" .claude/scripts/validate-utilization.py 2>/dev/null; then
    pass "No subprocess calls with shell=True"
else
    fail "subprocess with shell=True detected (potential command injection)"
fi

# ═══════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                        TEST SUMMARY                             ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Total Tests: $TEST_COUNT"
echo "║  Passed:      $PASS_COUNT"
echo "║  Failed:      $FAIL_COUNT"
echo "╠════════════════════════════════════════════════════════════════╣"

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "║  Result: ✅ ALL TESTS PASSED"
    echo "╚════════════════════════════════════════════════════════════════╝"
    exit 0
else
    echo "║  Result: ❌ SOME TESTS FAILED"
    echo "╚════════════════════════════════════════════════════════════════╝"
    exit 1
fi
