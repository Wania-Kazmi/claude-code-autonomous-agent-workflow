#!/bin/bash
# Dynamic Skill Activator Hook
# Scans actual .claude/skills/ directory and matches against prompt
# Does NOT assume any specific skill names - fully dynamic

set -e

# Get the user prompt from stdin
PROMPT_JSON=$(cat)
USER_PROMPT=$(echo "$PROMPT_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('prompt',''))" 2>/dev/null || echo "$PROMPT_JSON")

# Convert to lowercase for matching
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$CLAUDE_DIR/skills"
RULES_FILE="$CLAUDE_DIR/skill-rules.json"
LOG_FILE="$CLAUDE_DIR/logs/skill-activations.log"

# Ensure log directory exists
mkdir -p "$CLAUDE_DIR/logs"

# Function to extract YAML frontmatter field from SKILL.md
extract_field() {
    local file=$1
    local field=$2
    # Extract content between --- markers, then get the field
    sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | grep "^${field}:" | sed "s/^${field}:\s*//" | tr -d '"' || echo ""
}

# Function to extract multi-line description
extract_description() {
    local file=$1
    python3 << EOF 2>/dev/null || echo ""
import re
with open("$file", 'r') as f:
    content = f.read()
# Find YAML frontmatter
match = re.search(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
if match:
    yaml_content = match.group(1)
    # Extract description (handles multi-line)
    desc_match = re.search(r'description:\s*\|?\s*\n?\s*(.*?)(?=\n\w+:|$)', yaml_content, re.DOTALL)
    if desc_match:
        print(desc_match.group(1).strip().replace('\n', ' '))
    else:
        # Single line description
        desc_match = re.search(r'description:\s*["\']?([^"\'\n]+)', yaml_content)
        if desc_match:
            print(desc_match.group(1).strip())
EOF
}

# Discover all available skills dynamically
discover_skills() {
    local skills=""
    if [ -d "$SKILLS_DIR" ]; then
        for skill_dir in "$SKILLS_DIR"/*/; do
            if [ -f "${skill_dir}SKILL.md" ]; then
                skill_name=$(basename "$skill_dir")
                skills="$skills $skill_name"
            fi
        done
    fi
    echo "$skills" | xargs
}

# Match prompt against a skill's description
skill_matches_prompt() {
    local skill_name=$1
    local skill_file="$SKILLS_DIR/$skill_name/SKILL.md"

    if [ ! -f "$skill_file" ]; then
        return 1
    fi

    # Get skill description
    local description=$(extract_description "$skill_file")
    local desc_lower=$(echo "$description" | tr '[:upper:]' '[:lower:]')

    # Check if any word from description appears in prompt (bi-directional matching)
    for word in $desc_lower; do
        # Skip short words
        if [ ${#word} -lt 4 ]; then
            continue
        fi
        if echo "$PROMPT_LOWER" | grep -qi "$word"; then
            return 0
        fi
    done

    # Check if skill name keywords appear in prompt
    local name_words=$(echo "$skill_name" | tr '-' ' ')
    for word in $name_words; do
        if [ ${#word} -lt 3 ]; then
            continue
        fi
        if echo "$PROMPT_LOWER" | grep -qi "$word"; then
            return 0
        fi
    done

    return 1
}

# Match prompt against technology patterns from rules file
match_technology_patterns() {
    if [ ! -f "$RULES_FILE" ]; then
        return
    fi

    python3 << EOF 2>/dev/null || true
import json
import re

prompt = """$PROMPT_LOWER"""

with open("$RULES_FILE", 'r') as f:
    rules = json.load(f)

matched_categories = []
patterns = rules.get('technologyPatterns', {})

for category, config in patterns.items():
    # Check keywords
    keywords = config.get('keywords', [])
    for kw in keywords:
        if kw.lower() in prompt:
            matched_categories.append(category)
            break
    else:
        # Check intent patterns (regex)
        intent_patterns = config.get('intentPatterns', [])
        for pattern in intent_patterns:
            if re.search(pattern, prompt, re.IGNORECASE):
                matched_categories.append(category)
                break

# Output unique categories
for cat in set(matched_categories):
    print(cat)
EOF
}

# Main logic
AVAILABLE_SKILLS=$(discover_skills)
MATCHED_SKILLS=""
MATCHED_CATEGORIES=""

# Get technology categories that match
MATCHED_CATEGORIES=$(match_technology_patterns)

# Find skills that match the prompt
for skill in $AVAILABLE_SKILLS; do
    if skill_matches_prompt "$skill"; then
        MATCHED_SKILLS="$MATCHED_SKILLS $skill"
    fi
done

MATCHED_SKILLS=$(echo "$MATCHED_SKILLS" | xargs)

# If no skills directory or no skills found, still show the protocol
if [ -z "$AVAILABLE_SKILLS" ]; then
    AVAILABLE_SKILLS="(no skills generated yet - create skills first)"
fi

# Output the forced-eval template
cat << 'FORCED_EVAL'

═══════════════════════════════════════════════════════════════════════════════
                    MANDATORY SKILL ACTIVATION PROTOCOL
═══════════════════════════════════════════════════════════════════════════════

BEFORE responding to this prompt, you MUST complete these steps IN ORDER:

┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 1: EVALUATE SKILLS                                                     │
│                                                                             │
│ For EACH available skill, write: [skill-name] - YES/NO - [reason]          │
│                                                                             │
FORCED_EVAL

echo "│ Available Skills: $AVAILABLE_SKILLS"
echo "│"

if [ -n "$MATCHED_SKILLS" ]; then
    echo "│ DETECTED MATCHES (likely relevant): $MATCHED_SKILLS"
    echo "│"
fi

if [ -n "$MATCHED_CATEGORIES" ]; then
    echo "│ Technology Categories Detected: $(echo $MATCHED_CATEGORIES | tr '\n' ', ')"
    echo "│"
fi

cat << 'FORCED_EVAL2'
├─────────────────────────────────────────────────────────────────────────────┤
│ STEP 2: ACTIVATE SKILLS                                                     │
│                                                                             │
│ For EVERY skill you marked YES:                                            │
│   → Call: Skill(skill-name) tool IMMEDIATELY                               │
│   → Do this BEFORE writing any implementation code                         │
│                                                                             │
│ CRITICAL: Your YES evaluation is MEANINGLESS unless you call Skill()       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ STEP 3: IMPLEMENT                                                           │
│                                                                             │
│ ONLY after completing Steps 1 and 2, proceed with the task.                │
│                                                                             │
│ If NO skills exist yet and the task requires generating skills first,      │
│ state that explicitly and generate the needed skills.                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

REMEMBER: Skills contain reusable intelligence. Direct implementation without
checking skills wastes accumulated knowledge and creates inconsistency.

═══════════════════════════════════════════════════════════════════════════════

FORCED_EVAL2

# Log activation
echo "[$(date -Iseconds)] Prompt: ${USER_PROMPT:0:100}... | Available: $AVAILABLE_SKILLS | Matched: $MATCHED_SKILLS | Categories: $MATCHED_CATEGORIES" >> "$LOG_FILE" 2>/dev/null || true

exit 0
