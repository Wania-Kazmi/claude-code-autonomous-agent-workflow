#!/bin/bash
# Log file changes by parsing tool input from stdin
# Workaround for missing $CLAUDE_FILE_PATH environment variable

LOG_FILE=".claude/logs/file-changes.log"
TIMESTAMP=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

# Read stdin (contains tool input JSON)
INPUT=$(cat)

# Extract file path from JSON
# Method 1: Try jq if available
if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // empty' 2>/dev/null)
fi

# Method 2: Fallback to grep/sed
if [ -z "$FILE_PATH" ]; then
    FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/' 2>/dev/null)
fi

# If we still don't have a path, try to get any path-like string
if [ -z "$FILE_PATH" ]; then
    FILE_PATH=$(echo "$INPUT" | grep -oE '"[^"]*\.(ts|tsx|js|jsx|md|json|py|sh)"' | tr -d '"' | head -1 2>/dev/null)
fi

# If we still don't have a name, log as unknown
if [ -z "$FILE_PATH" ]; then
    FILE_PATH="unknown"
fi

# Log the change
echo "[${TIMESTAMP}] File modified: ${FILE_PATH}" >> "$LOG_FILE" 2>/dev/null || true
