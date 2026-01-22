#!/bin/bash
# Debug hook to capture all available data

LOG_FILE=".claude/logs/hook-debug.log"

echo "=== HOOK EXECUTION: $(date -Iseconds) ===" >> "$LOG_FILE"
echo "PWD: $(pwd)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "=== ARGUMENTS ===" >> "$LOG_FILE"
echo "Args count: $#" >> "$LOG_FILE"
for i in "$@"; do
    echo "Arg: $i" >> "$LOG_FILE"
done
echo "" >> "$LOG_FILE"

echo "=== CLAUDE VARIABLES ===" >> "$LOG_FILE"
env | grep -i claude >> "$LOG_FILE" 2>&1 || echo "No CLAUDE_* vars found" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "=== ALL ENV VARS ===" >> "$LOG_FILE"
env | sort >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "=== STDIN ===" >> "$LOG_FILE"
timeout 1 cat >> "$LOG_FILE" 2>&1 || echo "No stdin or timeout" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "=== END ===" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
