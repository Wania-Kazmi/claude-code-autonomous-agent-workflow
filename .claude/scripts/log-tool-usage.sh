#!/bin/bash
# Log tool usage by parsing tool input from stdin

LOG_FILE=".claude/logs/tool-usage.log"
TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

# Read stdin (contains tool input JSON)
INPUT=$(cat)

# Extract tool name from context (this will be set by the matcher)
TOOL_NAME="${1:-unknown}"

# Extract file path from JSON
if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // empty' 2>/dev/null)
fi

if [ -z "$FILE_PATH" ]; then
    FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/' 2>/dev/null)
fi

if [ -z "$FILE_PATH" ]; then
    FILE_PATH="(no file path)"
fi

# Log the tool usage
echo "[${TIMESTAMP}] Tool: ${TOOL_NAME} | File: ${FILE_PATH}" >> "$LOG_FILE" 2>/dev/null || true
