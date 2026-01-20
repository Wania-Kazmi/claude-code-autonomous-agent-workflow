#!/bin/bash
# Dynamic Skill Enforcement Stop Hook
# Checks if skills were used based on actual available skills
# Does NOT assume specific skill names - fully dynamic

set -e

# Read the stop context from stdin
STOP_JSON=$(cat)

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$CLAUDE_DIR/skills"
RULES_FILE="$CLAUDE_DIR/skill-rules.json"
LOG_FILE="$CLAUDE_DIR/logs/skill-enforcement.log"

# Ensure log directory exists
mkdir -p "$CLAUDE_DIR/logs"

# If no skills directory exists, allow completion (skills not yet generated)
if [ ! -d "$SKILLS_DIR" ]; then
    echo '{"decision": "approve", "reason": "No skills directory - skills not yet generated"}'
    exit 0
fi

# Count available skills
SKILL_COUNT=$(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l)

# If no skills exist yet, allow completion
if [ "$SKILL_COUNT" -eq 0 ]; then
    echo '{"decision": "approve", "reason": "No skills generated yet"}'
    exit 0
fi

# Get list of available skills
AVAILABLE_SKILLS=""
for skill_dir in "$SKILLS_DIR"/*/; do
    if [ -f "${skill_dir}SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        AVAILABLE_SKILLS="$AVAILABLE_SKILLS $skill_name"
    fi
done
AVAILABLE_SKILLS=$(echo "$AVAILABLE_SKILLS" | xargs)

# Extract transcript/conversation to check for skill usage
# Look for evidence of Skill() tool calls in the conversation
TRANSCRIPT=$(echo "$STOP_JSON" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    # Try different possible keys for transcript
    t = d.get('transcript', d.get('messages', d.get('conversation', '')))
    if isinstance(t, list):
        print(' '.join(str(m) for m in t))
    else:
        print(str(t))
except:
    print('')
" 2>/dev/null || echo "")

# Check if any skill was invoked
SKILLS_USED=""
for skill in $AVAILABLE_SKILLS; do
    # Check various patterns that indicate skill usage
    if echo "$TRANSCRIPT" | grep -qi "Skill.*$skill\|skill.*$skill\|invok.*$skill"; then
        SKILLS_USED="$SKILLS_USED $skill"
    fi
done
SKILLS_USED=$(echo "$SKILLS_USED" | xargs)

# Get original prompt to determine if skills should have been used
ORIGINAL_PROMPT=$(echo "$STOP_JSON" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('originalPrompt', d.get('prompt', d.get('userPrompt', ''))))
except:
    print('')
" 2>/dev/null || echo "")
PROMPT_LOWER=$(echo "$ORIGINAL_PROMPT" | tr '[:upper:]' '[:lower:]')

# Check if prompt matches any technology pattern that would require skills
SHOULD_USE_SKILLS=$(python3 << EOF 2>/dev/null || echo "false"
import json
import re

prompt = """$PROMPT_LOWER"""
rules_file = "$RULES_FILE"

try:
    with open(rules_file, 'r') as f:
        rules = json.load(f)
except:
    print("false")
    exit()

# Check if any mandatory category matches
mandatory_categories = rules.get('enforcementRules', {}).get('mandatory', {}).get('categories', [])
patterns = rules.get('technologyPatterns', {})

for category in mandatory_categories:
    if category not in patterns:
        continue
    config = patterns[category]

    # Check keywords
    for kw in config.get('keywords', []):
        if kw.lower() in prompt:
            print("true")
            exit()

    # Check patterns
    for pattern in config.get('intentPatterns', []):
        if re.search(pattern, prompt, re.IGNORECASE):
            print("true")
            exit()

print("false")
EOF
)

# Decision logic
if [ "$SHOULD_USE_SKILLS" = "true" ] && [ -z "$SKILLS_USED" ] && [ -n "$AVAILABLE_SKILLS" ]; then
    # Skills should have been used but weren't
    cat << EOF
{
    "decision": "block",
    "reason": "SKILL ENFORCEMENT: Your task matches patterns that should use available skills, but no skills were invoked. Available skills: $AVAILABLE_SKILLS. Please go back and evaluate these skills using the EVALUATE → ACTIVATE → IMPLEMENT protocol. Use Skill(skill-name) to invoke relevant skills before completing."
}
EOF
    echo "[$(date -Iseconds)] BLOCKED | Prompt: ${ORIGINAL_PROMPT:0:50}... | Available: $AVAILABLE_SKILLS | Used: none" >> "$LOG_FILE" 2>/dev/null || true
else
    # Allow completion
    echo '{"decision": "approve"}'
    echo "[$(date -Iseconds)] APPROVED | Available: $AVAILABLE_SKILLS | Used: $SKILLS_USED" >> "$LOG_FILE" 2>/dev/null || true
fi

exit 0
