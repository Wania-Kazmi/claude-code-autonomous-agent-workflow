#!/bin/bash
# validate-hook.sh - Validate hooks.json quality
# Usage: ./validate-hook.sh <path/to/hooks.json>

HOOKS_PATH="$1"
SCORE=0
TOTAL=100
ISSUES=()

# Check file exists
if [ ! -f "$HOOKS_PATH" ]; then
    echo "❌ FAIL: Hooks file not found: $HOOKS_PATH"
    exit 1
fi

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    HOOKS QUALITY VALIDATION                     ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  File: $HOOKS_PATH"
echo "╠════════════════════════════════════════════════════════════════╣"

# Check valid JSON (15%) - SECURITY FIX: Use sys.argv instead of interpolation
if python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$HOOKS_PATH" 2>/dev/null; then
    SCORE=$((SCORE + 15))
    echo "║  ✓ [15/15] Valid JSON"
else
    ISSUES+=("Invalid JSON - file does not parse")
    echo "║  ✗ [0/15] Invalid JSON"
    echo "╚════════════════════════════════════════════════════════════════╝"
    exit 1
fi

# SECURITY FIX: Use heredoc with sys.argv for all Python code
# Count hooks
HOOK_COUNT=$(python3 - "$HOOKS_PATH" <<'PYTHON'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
    count = 0
    if 'hooks' in data:
        for hook_type in ['PreToolUse', 'PostToolUse', 'Stop', 'UserPromptSubmit']:
            if hook_type in data['hooks']:
                count += len(data['hooks'][hook_type])
    print(count)
PYTHON
)

echo "║  Found $HOOK_COUNT hook(s)"

# Check each hook has required fields (20%)
MISSING_FIELDS=0
HOOK_DETAILS=$(python3 - "$HOOKS_PATH" <<'PYTHON'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
    if 'hooks' not in data:
        print('NO_HOOKS')
        sys.exit(0)

    for hook_type in ['PreToolUse', 'PostToolUse', 'Stop', 'UserPromptSubmit']:
        if hook_type not in data['hooks']:
            continue
        for i, hook in enumerate(data['hooks'][hook_type]):
            if 'matcher' not in hook and hook_type != 'Stop':
                print(f'MISSING_MATCHER {hook_type}[{i}]')
            if 'hooks' not in hook:
                print(f'MISSING_HOOKS {hook_type}[{i}]')
            if 'description' not in hook:
                print(f'MISSING_DESC {hook_type}[{i}]')
PYTHON
)

if echo "$HOOK_DETAILS" | grep -q "MISSING"; then
    MISSING_COUNT=$(echo "$HOOK_DETAILS" | grep -c "MISSING")
    SCORE=$((SCORE + 10))
    ISSUES+=("$MISSING_COUNT hook(s) missing required fields")
    echo "║  ⚠ [10/20] Some hooks missing fields"
else
    SCORE=$((SCORE + 20))
    echo "║  ✓ [20/20] All hooks have required fields"
fi

# Check matcher syntax validity (20%)
INVALID_MATCHERS=$(python3 - "$HOOKS_PATH" <<'PYTHON'
import json, sys, re
with open(sys.argv[1]) as f:
    data = json.load(f)
    if 'hooks' not in data:
        print(0)
    else:
        invalid = 0
        for hook_type in ['PreToolUse', 'PostToolUse', 'UserPromptSubmit']:
            if hook_type not in data['hooks']:
                continue
            for hook in data['hooks'][hook_type]:
                if 'matcher' not in hook:
                    continue
                matcher = hook['matcher']
                # Check for common errors
                if ' = ' in matcher and ' == ' not in matcher:
                    invalid += 1  # Single = instead of ==
                if 'Tool ==' in matcher or 'tool =' in matcher:
                    invalid += 1  # Case or operator issues
        print(invalid)
PYTHON
)

if [ "$INVALID_MATCHERS" -eq 0 ]; then
    SCORE=$((SCORE + 20))
    echo "║  ✓ [20/20] Matcher syntax valid"
else
    SCORE=$((SCORE + 10))
    ISSUES+=("$INVALID_MATCHERS matcher(s) may have syntax errors")
    echo "║  ⚠ [10/20] Some matchers may be invalid"
fi

# Check bash syntax in commands (20%)
BASH_ERRORS=$(python3 - "$HOOKS_PATH" <<'PYTHON'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
    if 'hooks' not in data:
        print(0)
    else:
        errors = 0
        for hook_type in data['hooks']:
            for hook in data['hooks'][hook_type]:
                if 'hooks' not in hook:
                    continue
                for cmd_hook in hook['hooks']:
                    if cmd_hook.get('type') == 'command' and 'command' in cmd_hook:
                        # Check if it starts with shebang
                        cmd = cmd_hook['command']
                        if not cmd.strip().startswith('#!/bin/bash') and not cmd.strip().startswith('#!'):
                            errors += 1
        print(errors)
PYTHON
)

if [ "$BASH_ERRORS" -eq 0 ]; then
    SCORE=$((SCORE + 20))
    echo "║  ✓ [20/20] Bash commands have shebang"
else
    SCORE=$((SCORE + 15))
    ISSUES+=("$BASH_ERRORS command(s) missing #!/bin/bash shebang")
    echo "║  ⚠ [15/20] Some commands missing shebang"
fi

# Check descriptions exist (10%)
NO_DESC=$(python3 - "$HOOKS_PATH" <<'PYTHON'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
    if 'hooks' not in data:
        print(0)
    else:
        no_desc = 0
        for hook_type in data['hooks']:
            for hook in data['hooks'][hook_type]:
                if 'description' not in hook or not hook['description'].strip():
                    no_desc += 1
        print(no_desc)
PYTHON
)

if [ "$NO_DESC" -eq 0 ]; then
    SCORE=$((SCORE + 10))
    echo "║  ✓ [10/10] All hooks have descriptions"
else
    SCORE=$((SCORE + 5))
    ISSUES+=("$NO_DESC hook(s) missing description")
    echo "║  ⚠ [5/10] Some hooks missing descriptions"
fi

# Check for potential conflicts (15%)
# Simple heuristic: check if multiple hooks match same tool
CONFLICTS=$(python3 - "$HOOKS_PATH" <<'PYTHON'
import json, sys
from collections import Counter
with open(sys.argv[1]) as f:
    data = json.load(f)
    if 'hooks' not in data:
        print(0)
    else:
        matchers = []
        for hook_type in ['PreToolUse', 'PostToolUse']:
            if hook_type in data['hooks']:
                for hook in data['hooks'][hook_type]:
                    if 'matcher' in hook:
                        # Extract tool name from matcher
                        if 'tool ==' in hook['matcher']:
                            parts = hook['matcher'].split('tool ==')
                            if len(parts) > 1:
                                tool = parts[1].split()[0].strip('"\'')
                                matchers.append((hook_type, tool))

        # Check for duplicates
        counter = Counter(matchers)
        conflicts = sum(1 for count in counter.values() if count > 1)
        print(conflicts)
PYTHON
)

if [ "$CONFLICTS" -eq 0 ]; then
    SCORE=$((SCORE + 15))
    echo "║  ✓ [15/15] No hook conflicts detected"
else
    SCORE=$((SCORE + 10))
    ISSUES+=("$CONFLICTS potential hook conflict(s)")
    echo "║  ⚠ [10/15] Potential conflicts"
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
