---
description: Initialize Spec-Kit-Plus workflow in a new project. Creates .specify/ and .claude/ directory structure.
---

# /q-init

**Input**: `$ARGUMENTS` (optional: project name)

---

## SPEC-KIT-PLUS PROJECT INITIALIZATION

This command sets up the Spec-Kit-Plus autonomous workflow structure in a new project.

```
╔════════════════════════════════════════════════════════════════════════════════╗
║                    SPEC-KIT-PLUS INITIALIZATION                                 ║
╠════════════════════════════════════════════════════════════════════════════════╣
║                                                                                ║
║   /q-init initializes a fresh project with the complete workflow structure.   ║
║                                                                                ║
║   Creates:                                                                     ║
║   ├── .specify/           Workflow artifacts                                   ║
║   │   ├── templates/      Spec templates                                       ║
║   │   ├── validations/    Validation reports                                   ║
║   │   └── features/       Feature specs (for COMPLEX projects)                 ║
║   │                                                                            ║
║   └── .claude/            Claude Code configuration                            ║
║       ├── skills/         Custom skills (will be generated)                    ║
║       ├── agents/         Agent definitions                                    ║
║       ├── commands/       Slash commands                                       ║
║       ├── rules/          Governance rules                                     ║
║       ├── logs/           Activity logs                                        ║
║       └── build-reports/  Build reports                                        ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

---

## STEP 1: CHECK CURRENT STATE (CRITICAL)

**NEVER overwrite existing directories. Check FIRST.**

```bash
echo "Checking project state..."

# Check .claude
if [ -d ".claude" ]; then
    SKILL_COUNT=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l)
    echo "✓ .claude/ exists with $SKILL_COUNT skills"
    CLAUDE_EXISTS="true"
else
    CLAUDE_EXISTS="false"
fi

# Check .specify
if [ -d ".specify" ]; then
    echo "✓ .specify/ exists"
    SPECIFY_EXISTS="true"
else
    SPECIFY_EXISTS="false"
fi

# If both exist, don't reinitialize
if [ "$CLAUDE_EXISTS" = "true" ] && [ "$SPECIFY_EXISTS" = "true" ]; then
    echo ""
    echo "⚠️  Project already initialized!"
    echo "   - .claude/ exists (with $SKILL_COUNT skills)"
    echo "   - .specify/ exists"
    echo ""
    echo "Options:"
    echo "  /q-reset      - Reset workflow state only"
    echo "  /sp.autonomous - Continue autonomous build"
    echo ""
    echo "Will NOT overwrite existing directories."
    exit 0
fi
```

### FORBIDDEN ACTIONS

```
✗ NEVER create: skill-lab/, workspace/, temp/
✗ NEVER create: .claude/ inside another directory
✗ NEVER overwrite existing .claude/skills/
```

---

## STEP 2: CREATE DIRECTORY STRUCTURE

```bash
echo "Creating Spec-Kit-Plus directory structure..."

# Create .specify structure
mkdir -p .specify/templates
mkdir -p .specify/validations
mkdir -p .specify/features

# Create .claude structure
mkdir -p .claude/skills
mkdir -p .claude/agents
mkdir -p .claude/commands
mkdir -p .claude/rules
mkdir -p .claude/logs
mkdir -p .claude/build-reports

echo "✓ Directory structure created"
```

---

## STEP 3: CREATE INITIAL FILES

### Workflow State
```bash
cat > .specify/workflow-state.json << 'EOF'
{
  "phase": 0,
  "status": "initialized",
  "project_type": "unknown",
  "timestamp": "$(date -Iseconds)",
  "features": [],
  "completed_phases": []
}
EOF
```

### CLAUDE.md (Project Instructions)
If CLAUDE.md doesn't exist, create a minimal version:

```bash
if [ ! -f "CLAUDE.md" ]; then
cat > CLAUDE.md << 'EOF'
# Project Instructions

## Quick Start

```bash
# Initialize workflow (already done)
/q-init

# Start autonomous build
/sp.autonomous

# Check status
/q-status

# Validate workflow
/q-validate
```

## Workflow Commands

| Command | Purpose |
|---------|---------|
| `/sp.autonomous` | Full autonomous build |
| `/q-status` | Check workflow state |
| `/q-validate` | Validate phases |
| `/q-reset` | Reset workflow |
| `/plan` | Create implementation plan |
| `/tdd` | Test-driven development |
| `/code-review` | Code quality review |

## Directory Structure

```
.specify/           # Workflow artifacts
.claude/            # Claude Code configuration
```
EOF
fi
```

---

## STEP 4: COPY TEMPLATE FILES (Optional)

If running from the template repository, copy essential files:

```bash
TEMPLATE_DIR="/mnt/c/Users/HP/Documents/code/claude-code-autonomous-agent-workflow"

# Copy skills if template exists
if [ -d "$TEMPLATE_DIR/.claude/skills" ]; then
    cp -r "$TEMPLATE_DIR/.claude/skills/"* .claude/skills/ 2>/dev/null || true
    echo "✓ Copied template skills"
fi

# Copy agents if template exists
if [ -d "$TEMPLATE_DIR/.claude/agents" ]; then
    cp -r "$TEMPLATE_DIR/.claude/agents/"* .claude/agents/ 2>/dev/null || true
    echo "✓ Copied template agents"
fi

# Copy rules if template exists
if [ -d "$TEMPLATE_DIR/.claude/rules" ]; then
    cp -r "$TEMPLATE_DIR/.claude/rules/"* .claude/rules/ 2>/dev/null || true
    echo "✓ Copied template rules"
fi

# Copy commands if template exists
if [ -d "$TEMPLATE_DIR/.claude/commands" ]; then
    cp -r "$TEMPLATE_DIR/.claude/commands/"* .claude/commands/ 2>/dev/null || true
    echo "✓ Copied template commands"
fi
```

---

## STEP 5: DISPLAY COMPLETION

```
╔════════════════════════════════════════════════════════════════════════════════╗
║                    INITIALIZATION COMPLETE                                      ║
╠════════════════════════════════════════════════════════════════════════════════╣
║                                                                                ║
║   ✓ .specify/ directory created                                                ║
║   ✓ .claude/ directory created                                                 ║
║   ✓ Workflow state initialized                                                 ║
║   ✓ Template files copied (if available)                                       ║
║                                                                                ║
║   NEXT STEPS:                                                                  ║
║   ─────────────────────────────────────────────────────────────────────────── ║
║                                                                                ║
║   1. Create a requirements file (requirements.md) describing your project     ║
║                                                                                ║
║   2. Run the autonomous builder:                                               ║
║      /sp.autonomous requirements.md                                            ║
║                                                                                ║
║   OR manually:                                                                 ║
║      /plan [describe your feature]                                             ║
║      /tdd                                                                      ║
║      /code-review                                                              ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

---

## ALTERNATIVE: ONE-LINE COPY FROM TEMPLATE

If you want to copy the ENTIRE template configuration:

```bash
# From your new project directory:
TEMPLATE="/mnt/c/Users/HP/Documents/code/claude-code-autonomous-agent-workflow"

cp -r "$TEMPLATE/.claude" ./ && \
cp -r "$TEMPLATE/.specify" ./ && \
cp "$TEMPLATE/CLAUDE.md" ./ && \
cp "$TEMPLATE/.mcp.json" ./ 2>/dev/null || true

echo "✓ Full template copied"
```

---

## TROUBLESHOOTING

**Q: sp.autonomous didn't create directories?**
A: Run `/q-init` first, then `/sp.autonomous`

**Q: Skills not loading?**
A: Ensure `.claude/skills/` exists with SKILL.md files

**Q: Workflow state corrupted?**
A: Run `/q-reset` to clear and restart
