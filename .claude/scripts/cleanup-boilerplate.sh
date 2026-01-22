#!/bin/bash
# cleanup-boilerplate.sh - Clean up example files and prepare boilerplate
# Usage: ./cleanup-boilerplate.sh

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           BOILERPLATE CLEANUP - PREPARING TEMPLATE             ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo ""

# 1. Delete validation reports (keep structure)
echo "🗑️  Cleaning validation reports..."
rm -f .specify/validations/*.md
rm -f .specify/validations/*.json
echo "   ✓ Removed validation reports"

# 2. Keep validation scripts but create empty validations directory
mkdir -p .specify/validations
touch .specify/validations/.gitkeep
echo "   ✓ Reset validations directory"

# 3. Create .specify/templates if not exists
mkdir -p .specify/templates
touch .specify/templates/.gitkeep
echo "   ✓ Ensured templates directory exists"

# 4. Clean up any temporary analysis files
rm -f /tmp/analyze_score.py 2>/dev/null
echo "   ✓ Removed temporary files"

# 5. Create a boilerplate README in .specify
cat > .specify/README.md <<'EOF'
# .specify Directory

This directory contains workflow state and validation artifacts.

## Structure

```
.specify/
├── validations/        # Quality gate validation reports
├── templates/          # Reusable file templates
└── README.md          # This file
```

## Usage

This directory is managed by the autonomous workflow system. Reports and
state files are generated automatically during workflow execution.

## Cleanup

To reset for a new project:
```bash
rm -rf .specify/validations/*
```
EOF
echo "   ✓ Created .specify/README.md"

# 6. Create example project structure documentation
cat > .claude/SETUP.md <<'EOF'
# Claude Code Autonomous Workflow - Setup Guide

## Quick Start

1. **Initialize for a new project:**
   ```bash
   git init
   git add .
   git commit -m "chore: initialize Claude Code workflow"
   ```

2. **Start autonomous build:**
   - Create `requirements.md` with your project requirements
   - Run: Use `/sp.autonomous` command

3. **The workflow will:**
   - Analyze your requirements
   - Detect missing skills/agents
   - Create a feature branch automatically
   - Build your project following best practices
   - Run quality gates at each phase

## Automatic Branch Creation

When you start a new project, the workflow will:
1. Check if you're on `main`/`master`
2. Automatically create a feature branch: `feature/{project-name}`
3. All work happens on the feature branch
4. Create PR when complete

## Features

- ✅ Test-driven development (TDD)
- ✅ Security review (OWASP Top 10)
- ✅ Code quality validation
- ✅ Component utilization tracking
- ✅ Automatic branch management

## Directory Structure

```
.claude/
├── agents/           # Specialized agents (planner, security-reviewer, etc.)
├── commands/         # Slash commands (/plan, /tdd, /code-review, etc.)
├── rules/            # Governance rules (security, testing, patterns)
├── skills/           # Reusable knowledge (coding-standards, testing-patterns)
├── scripts/          # Validation and utility scripts
└── settings.json     # Configuration and hooks

.specify/
├── validations/      # Quality gate reports
└── templates/        # Reusable templates
```

## Documentation

- `README.md` - Main documentation
- `CLAUDE.md` - Quick reference for agents and commands
- `.claude/rules/` - Detailed governance rules

## Support

For issues or questions, see:
- `/help` - Get help with Claude Code
- GitHub Issues: https://github.com/anthropics/claude-code/issues
EOF
echo "   ✓ Created .claude/SETUP.md"

# 7. Update README to remove project-specific content
echo ""
echo "📝 README.md should be manually updated to remove project-specific content"
echo "   Keep: General workflow documentation"
echo "   Remove: Specific validation results, scores, etc."

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    CLEANUP COMPLETE                             ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  ✓ Validation reports cleared                                  ║"
echo "║  ✓ Temporary files removed                                     ║"
echo "║  ✓ Boilerplate structure ready                                 ║"
echo "║  ✓ Documentation created                                       ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Next Steps:                                                    ║"
echo "║  1. Review and update README.md (remove specifics)             ║"
echo "║  2. Test with: /sp.autonomous                                  ║"
echo "║  3. Commit clean boilerplate                                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
