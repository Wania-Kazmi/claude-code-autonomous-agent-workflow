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
