#!/bin/bash

# Skill Usage Enforcement Script
# Run this before starting any coding task

set -e

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                    SKILL USAGE ENFORCEMENT CHECK                           ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 1. CHECK FOR FORBIDDEN DIRECTORIES
# ═══════════════════════════════════════════════════════════════════════════════

echo "Checking for forbidden directories..."

FORBIDDEN=("skill-lab" "workspace" "temp" "output")
VIOLATIONS=()

for dir in "${FORBIDDEN[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✗ VIOLATION: Forbidden directory exists: $dir"
        VIOLATIONS+=("$dir")
    fi
done

if [ ${#VIOLATIONS[@]} -eq 0 ]; then
    echo "  ✓ No forbidden directories found"
else
    echo ""
    echo "Cleaning up violations..."
    for dir in "${VIOLATIONS[@]}"; do
        echo "  Removing: $dir"
        rm -rf "$dir"
    done
    echo "  ✓ Cleanup complete"
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 2. CHECK SKILL COUNT
# ═══════════════════════════════════════════════════════════════════════════════

echo "Checking skill count..."

if [ -d ".claude/skills" ]; then
    SKILL_COUNT=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l)
    echo "  Found $SKILL_COUNT skills"

    if [ "$SKILL_COUNT" -gt 15 ]; then
        echo "  ⚠️  WARNING: Too many skills ($SKILL_COUNT > 15)"
        echo "  Consider consolidating skills"
    elif [ "$SKILL_COUNT" -gt 10 ]; then
        echo "  ⚠️  Approaching skill limit ($SKILL_COUNT/15)"
    else
        echo "  ✓ Skill count is reasonable"
    fi
else
    echo "  ⚠️  No .claude/skills directory found"
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 3. LIST AVAILABLE SKILLS
# ═══════════════════════════════════════════════════════════════════════════════

echo "Available skills for this project:"
echo ""

if [ -d ".claude/skills" ]; then
    for skill_dir in .claude/skills/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            skill_file="$skill_dir/SKILL.md"

            if [ -f "$skill_file" ]; then
                echo "  • $skill_name"
            fi
        fi
    done
else
    echo "  (No skills found)"
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 4. REMIND ABOUT SKILL USAGE
# ═══════════════════════════════════════════════════════════════════════════════

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                       SKILL USAGE REMINDER                                  ║"
echo "╠════════════════════════════════════════════════════════════════════════════╣"
echo "║                                                                            ║"
echo "║  BEFORE writing any code:                                                  ║"
echo "║  1. Identify which skills apply to the task                                ║"
echo "║  2. Load those skills via Skill() or Read()                                ║"
echo "║  3. Apply patterns from loaded skills                                      ║"
echo "║  4. ONLY THEN write code                                                   ║"
echo "║                                                                            ║"
echo "║  Example:                                                                  ║"
echo "║    Task: \"Write API endpoint\"                                            ║"
echo "║    → Load api-patterns skill                                              ║"
echo "║    → Load coding-standards skill                                          ║"
echo "║    → Apply patterns from both                                             ║"
echo "║    → Write code following patterns                                        ║"
echo "║                                                                            ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 5. CHECK FOR SKILL BYPASS IN RECENT WORK
# ═══════════════════════════════════════════════════════════════════════════════

echo "Checking for recent skill bypass..."

if [ -f ".claude/logs/skill-invocations.log" ]; then
    RECENT_INVOCATIONS=$(tail -n 100 .claude/logs/skill-invocations.log 2>/dev/null | wc -l)
    echo "  Recent skill invocations: $RECENT_INVOCATIONS"

    if [ "$RECENT_INVOCATIONS" -eq 0 ]; then
        echo "  ⚠️  WARNING: No recent skill usage detected"
        echo "  Make sure to use Skill() tool when working"
    else
        echo "  ✓ Skills are being used"
    fi
else
    echo "  (No skill invocation log found - first session)"
fi

echo ""
echo "✓ Enforcement check complete"
echo ""
