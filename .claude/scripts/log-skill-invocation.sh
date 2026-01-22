#!/bin/bash
# Log skill invocations by parsing tool input from stdin
# Workaround for missing $CLAUDE_SKILL_NAME environment variable

LOG_FILE=".claude/logs/skill-invocations.log"
DEBUG_FILE=".claude/logs/hook-stdin-debug.log"
TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

# Read stdin (contains tool input JSON)
INPUT=$(timeout 0.5 cat 2>/dev/null || echo "")

# Debug: log raw stdin
echo "=== STDIN CAPTURE ${TIMESTAMP} ===" >> "$DEBUG_FILE" 2>/dev/null
echo "$INPUT" >> "$DEBUG_FILE" 2>/dev/null
echo "=== END STDIN ===" >> "$DEBUG_FILE" 2>/dev/null

# Extract skill name from JSON using multiple methods
# Method 1: Try jq if available
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
    SKILL_NAME=$(echo "$INPUT" | jq -r '.skill // empty' 2>/dev/null)
fi

# Method 2: Fallback to grep/sed if jq not available or didn't work
if [ -z "$SKILL_NAME" ] && [ -n "$INPUT" ]; then
    SKILL_NAME=$(echo "$INPUT" | grep -o '"skill"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/' 2>/dev/null)
fi

# Method 3: Last resort - try to extract any quoted string that looks like a skill name
if [ -z "$SKILL_NAME" ] && [ -n "$INPUT" ]; then
    SKILL_NAME=$(echo "$INPUT" | grep -oE '(skill|name)[^:]*:[^"]*"[a-z][a-z0-9-]*"' | grep -oE '"[a-z][a-z0-9-]*"' | tr -d '"' | head -1 2>/dev/null)
fi

# If we still don't have a name, log as NO_STDIN if input was empty
if [ -z "$SKILL_NAME" ]; then
    if [ -z "$INPUT" ]; then
        SKILL_NAME="NO_STDIN"
    else
        SKILL_NAME="PARSE_FAILED"
    fi
fi

# Log the invocation
echo "[${TIMESTAMP}] Skill invoked: ${SKILL_NAME}" >> "$LOG_FILE" 2>/dev/null || true
