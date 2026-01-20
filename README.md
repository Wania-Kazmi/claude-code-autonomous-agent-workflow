# Autonomous Agent Boilerplate for Claude Code

> **Build entire projects from a single requirements file.** This boilerplate doesn't just provide pre-configured agents — it **autonomously generates** the skills, agents, hooks, and code your project needs using the Spec-Kit-Plus workflow.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Ready-blue)](https://claude.ai/claude-code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Autonomous](https://img.shields.io/badge/Autonomous-Spec--Kit--Plus-purple)](.)
[![Validated](https://img.shields.io/badge/Components-50%2F50-brightgreen)](.)

---

## 🚀 The Core Idea

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   YOU WRITE:                        BOILERPLATE GENERATES:                  │
│   ───────────                       ──────────────────────                  │
│                                                                             │
│   requirements/my-app.md    →→→     ✓ Skills for YOUR tech stack           │
│                                     ✓ Agents for YOUR project needs        │
│                                     ✓ Hooks for YOUR workflow              │
│                                     ✓ Complete project with tests          │
│                                     ✓ 80%+ code coverage                   │
│                                     ✓ Security-reviewed code               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**One command. Full project. No manual setup.**

```bash
claude "/sp.autonomous requirements/my-app.md"
```

---

## 📋 Table of Contents

- [How It Works](#-how-it-works)
- [Quick Start](#-quick-start)
- [The Spec-Kit-Plus Workflow](#-the-spec-kit-plus-workflow)
  - [Phase Details](#phase-details)
  - [What Gets Generated](#what-gets-generated)
  - [Architecture: Autonomous Enforcement](#architecture-how-autonomous-enforcement-works)
  - [Workflow Status Commands](#workflow-status-commands)
- [Writing Requirements](#-writing-requirements)
- [Pre-Loaded Components](#-pre-loaded-components)
- [Manual Mode (Optional)](#-manual-mode-optional)
- [Understanding the Structure](#-understanding-the-structure)
- [Customization](#-customization)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)

---

## 🎯 How It Works

### Step 1: You Write Requirements

Create a simple markdown file describing what you want to build:

```markdown
# My E-Commerce API

## Features
- User authentication (JWT)
- Product catalog with search
- Shopping cart
- Order processing

## Technical
- Backend: Node.js + Express
- Database: PostgreSQL + Prisma
- Testing: Jest
```

### Step 2: Run One Command

```bash
claude "/sp.autonomous requirements/my-app.md"
```

### Step 3: Boilerplate Takes Over

The autonomous workflow:

1. **Analyzes** your requirements file
2. **Detects** technologies (Node.js, Express, PostgreSQL, Prisma, Jest)
3. **Generates** custom skills for your stack
4. **Generates** specialized agents for your project
5. **Generates** quality hooks for your workflow
6. **Creates** specification, plan, and task breakdown
7. **Implements** each feature using TDD
8. **Reviews** code for security and quality
9. **Delivers** complete project with tests

**Result:** A production-ready project with 80%+ test coverage, security-reviewed code, and proper documentation.

---

## 🚀 Quick Start

### Prerequisites

```bash
# Claude Code CLI
claude --version

# Node.js 18+
node --version

# Git
git --version
```

### Installation

```bash
# Clone the boilerplate
git clone https://github.com/your-username/autonomous-agent-boilerplate.git my-project
cd my-project

# Start Claude Code
claude
```

### Your First Autonomous Build

```bash
# Create requirements file
mkdir requirements
cat > requirements/my-app.md << 'EOF'
# My Todo App

## Features
- User registration and login
- Create, edit, delete todos
- Mark todos as complete

## Technical
- Frontend: React
- Backend: Express
- Database: SQLite
EOF

# Run autonomous mode
claude "/sp.autonomous requirements/my-app.md"

# Watch it build your entire project!
```

---

## ⚙️ The Spec-Kit-Plus Workflow

When you run `/sp.autonomous`, this workflow executes:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SPEC-KIT-PLUS WORKFLOW                              │
│                                                                             │
│  INIT → ANALYZE PROJECT → ANALYZE REQUIREMENTS → GAP ANALYSIS              │
│                                                       ↓                     │
│                                          GENERATE → TEST → VERIFY           │
│                                                            ↓                │
│           IMPLEMENT ← TASKS ← PLAN ← SPEC ← CONSTITUTION                    │
│                ↓                                                            │
│           QA → DELIVER                                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phase Details

| Phase | What Happens | Output |
|-------|--------------|--------|
| **1. INIT** | Create `.specify/` and `.claude/` directories, setup git | Project structure |
| **2. ANALYZE PROJECT** | Inventory existing skills, agents, hooks | `project-analysis.json` |
| **3. ANALYZE REQUIREMENTS** | Parse requirements file, detect technologies | `requirements-analysis.json` |
| **4. GAP ANALYSIS** | Compare required vs existing, identify gaps | `gap-analysis.json` |
| **5. GENERATE** | Create missing skills, agents, hooks | Custom infrastructure |
| **6. TEST** | Validate all generated components work | Verification report |
| **7. CONSTITUTION** | Define project rules and standards | `.specify/constitution.md` |
| **8. SPEC** | Generate detailed specification | `.specify/spec.md` |
| **9. PLAN** | Create implementation plan with architecture | `.specify/plan.md` |
| **10. TASKS** | Break down into actionable items with skill mappings | `.specify/tasks.md` |
| **11. IMPLEMENT** | Build each feature using TDD cycle | Source code + tests |
| **12. QA** | Code review, security review, coverage check | Quality report |
| **13. DELIVER** | Commit, generate final report | Complete project |

### What Gets Generated

```
your-project/
│
├── .specify/                      # Spec-Kit-Plus artifacts
│   ├── project-analysis.json      # Analysis of existing project
│   ├── requirements-analysis.json # Parsed requirements
│   ├── gap-analysis.json          # Missing skills/agents/hooks
│   ├── constitution.md            # Project rules and standards
│   ├── spec.md                    # Detailed specification
│   ├── plan.md                    # Implementation plan
│   ├── data-model.md              # Database schema
│   └── tasks.md                   # Task checklist [X] marked
│
├── .claude/
│   ├── skills/                    # GENERATED for your tech stack
│   │   ├── express-patterns/      # (if Express detected)
│   │   ├── prisma-patterns/       # (if Prisma detected)
│   │   └── react-patterns/        # (if React detected)
│   │
│   ├── agents/                    # GENERATED for your project
│   │   ├── api-builder.md         # (if API project)
│   │   └── frontend-builder.md    # (if frontend project)
│   │
│   ├── hooks/                     # GENERATED for your workflow
│   │   ├── pre-commit.sh
│   │   └── quality-gate.py
│   │
│   ├── logs/autonomous.log        # Build log
│   └── build-reports/             # Final report
│
└── src/                           # YOUR PROJECT CODE
    ├── (generated source files)
    └── (generated test files)
```

### Architecture: How Autonomous Enforcement Works

The workflow is **completely self-enforcing** with zero human intervention required during execution.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AUTONOMOUS ENFORCEMENT ARCHITECTURE                     │
│                                                                             │
│  ┌─────────────┐                                                            │
│  │   START     │                                                            │
│  └──────┬──────┘                                                            │
│         ▼                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  PHASE 0: PRE-CHECK (Always runs first)                             │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ • Invoke workflow-validator skill                           │   │   │
│  │  │ • Check all phase artifacts                                 │   │   │
│  │  │ • Detect current state (which phase completed)              │   │   │
│  │  │ • Decision: FRESH START or RESUME                           │   │   │
│  │  │ • Fix any skipped phases (violations)                       │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│         ▼                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  PHASE N: Execute Phase                                             │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ • Run phase logic                                           │   │   │
│  │  │ • Create phase artifact                                     │   │   │
│  │  │ • Log progress                                              │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│         ▼                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  AUTO-VALIDATE (Runs after EVERY phase)                             │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │ • Check artifact exists                                     │   │   │
│  │  │ • Validate content integrity                                │   │   │
│  │  │         │                                                   │   │   │
│  │  │    ┌────┴────┐                                              │   │   │
│  │  │    ▼         ▼                                              │   │   │
│  │  │  PASS      FAIL                                             │   │   │
│  │  │    │         │                                              │   │   │
│  │  │    │    ┌────┴────────────────────┐                         │   │   │
│  │  │    │    │  SELF-HEAL (max 3x)     │                         │   │   │
│  │  │    │    │  • Re-run phase         │                         │   │   │
│  │  │    │    │  • Check again          │                         │   │   │
│  │  │    │    │  • If still fail: STOP  │                         │   │   │
│  │  │    │    └─────────────────────────┘                         │   │   │
│  │  │    ▼                                                        │   │   │
│  │  │  Proceed to Phase N+1                                       │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│         ▼                                                                   │
│  ┌─────────────┐                                                            │
│  │  COMPLETE   │                                                            │
│  └─────────────┘                                                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Features of Autonomous Enforcement

| Feature | How It Works |
|---------|--------------|
| **Auto-Detection** | Phase 0 checks all artifacts to know current state |
| **Smart Resume** | If interrupted, resumes from last completed phase |
| **Self-Healing** | Failed phases retry automatically (max 3 attempts) |
| **Violation Detection** | Skipped phases are detected and executed |
| **Zero Intervention** | No human input needed during execution |

### Phase Artifact Detection

Each phase creates a specific artifact. The validator checks these to determine state:

| Phase | Artifact | Detection Command |
|-------|----------|-------------------|
| 1. INIT | `.specify/` directory | `[ -d ".specify" ]` |
| 2. ANALYZE PROJECT | `project-analysis.json` | `[ -f ".specify/project-analysis.json" ]` |
| 3. ANALYZE REQUIREMENTS | `requirements-analysis.json` | `[ -f ".specify/requirements-analysis.json" ]` |
| 4. GAP ANALYSIS | `gap-analysis.json` | `[ -f ".specify/gap-analysis.json" ]` |
| 5. GENERATE | New skills created | Skill count > baseline |
| 6. TEST | Validation logs | `grep "validated" logs` |
| 7. CONSTITUTION | `constitution.md` | `[ -f ".specify/constitution.md" ]` |
| 8. SPEC | `spec.md` | `[ -f ".specify/spec.md" ]` |
| 9. PLAN | `plan.md` | `[ -f ".specify/plan.md" ]` |
| 10. TASKS | `tasks.md` | `[ -f ".specify/tasks.md" ]` |
| 11. IMPLEMENT | Tasks marked `[X]` | `grep -c "\[X\]" tasks.md` |
| 12. QA | Build report | Report file exists |
| 13. DELIVER | Git commit | Commit message contains "autonomous" |

### Workflow Status Commands

Check workflow state anytime:

```bash
# Quick status check - see which phase you're at
claude "/q-status"

# Full validation - check for violations
claude "/q-validate"

# Reset workflow - start fresh
claude "/q-reset"
```

Example `/q-status` output:

```
╔════════════════════════════════════════════════════════════════╗
║                    WORKFLOW STATUS REPORT                       ║
╠════════════════════════════════════════════════════════════════╣
║  [✓] 1. INIT                                                   ║
║  [✓] 2. ANALYZE PROJECT                                        ║
║  [✓] 3. ANALYZE REQUIREMENTS                                   ║
║  [✓] 4. GAP ANALYSIS                                           ║
║  [→] 5. GENERATE                    ← CURRENT                  ║
║  [ ] 6. TEST                                                   ║
║  [ ] 7. CONSTITUTION                                           ║
║  [ ] 8. SPEC                                                   ║
║  [ ] 9. PLAN                                                   ║
║  [ ] 10. TASKS                                                 ║
║  [ ] 11. IMPLEMENT                                             ║
║  [ ] 12. QA                                                    ║
║  [ ] 13. DELIVER                                               ║
╠════════════════════════════════════════════════════════════════╣
║  Violations: NONE                                              ║
║  Next: Generate missing skills (express-patterns, etc.)        ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 📝 Writing Requirements

### Minimal Requirements File

```markdown
# Project Name

## Features
- Feature 1
- Feature 2

## Technical
- Stack item 1
- Stack item 2
```

### Comprehensive Requirements File

```markdown
# E-Commerce Platform

## Overview
A full-featured e-commerce platform for small businesses.

## Features

### User Management
- User registration with email verification
- Login with JWT authentication
- Password reset flow
- User profile management

### Product Catalog
- Product CRUD operations
- Category management
- Search with filters
- Image upload

### Shopping Cart
- Add/remove items
- Quantity management
- Persistent cart (database)

### Orders
- Checkout flow
- Order history
- Order status tracking

## Technical

### Backend
- Runtime: Node.js 20
- Framework: Express
- Database: PostgreSQL
- ORM: Prisma
- Auth: JWT + bcrypt

### Frontend
- Framework: Next.js 14
- Styling: Tailwind CSS
- State: Zustand

### Testing
- Unit: Jest
- E2E: Playwright

### Deployment
- Docker
- Railway/Vercel

## Constraints
- Must be mobile-responsive
- Must support 1000 concurrent users
- Must have 80%+ test coverage
```

---

## 📦 Pre-Loaded Components

The boilerplate comes with pre-loaded components that work out of the box:

### Agents (10)

| Agent | Purpose |
|-------|---------|
| **planner** | Creates implementation plans |
| **architect** | System design decisions |
| **tdd-guide** | Test-driven development |
| **code-reviewer** | Quality & security review |
| **security-reviewer** | OWASP Top 10 checks |
| **build-error-resolver** | Fix build errors |
| **e2e-runner** | Playwright E2E tests |
| **refactor-cleaner** | Remove dead code |
| **doc-updater** | Update documentation |
| **test-runner** | Run tests |

### Skills (9)

| Skill | What It Contains |
|-------|------------------|
| **coding-standards** | TypeScript/JS/React patterns |
| **backend-patterns** | API design, services |
| **testing-patterns** | Jest/Vitest/Playwright |
| **api-patterns** | REST/GraphQL design |
| **database-patterns** | Prisma/SQL/migrations |
| **claudeception** | Session learning |
| **mcp-code-execution** | MCP integration |
| **skill-gap-analyzer** | Detect missing skills |
| **workflow-validator** | Check workflow state, detect violations |

### Commands (13)

| Command | What It Does |
|---------|--------------|
| `/sp.autonomous` | **Full autonomous build** from requirements |
| `/q-status` | Check workflow state - which phase you're at |
| `/q-validate` | Validate workflow order, detect violations |
| `/q-reset` | Reset workflow state for fresh start |
| `/plan` | Create implementation plan |
| `/tdd` | Test-driven development |
| `/code-review` | Security + quality review |
| `/build-fix` | Fix build errors |
| `/e2e` | E2E testing |
| `/refactor-clean` | Remove dead code |
| `/test-coverage` | Check coverage |
| `/update-codemaps` | Update architecture docs |
| `/update-docs` | Sync documentation |

---

## 🔧 Manual Mode (Optional)

Don't want full autonomous mode? Use individual commands:

### Planning Workflow

```bash
# Start with a plan
> /plan I want to add user authentication

# Claude creates plan, WAITS for approval
> looks good, proceed

# Claude implements with TDD
# Then review
> /code-review

# Fix any issues
> /build-fix

# Commit
> commit these changes
```

### TDD Workflow

```bash
> /tdd

# Claude:
# 1. Writes failing test (RED)
# 2. Implements code (GREEN)
# 3. Refactors (IMPROVE)
# 4. Verifies 80%+ coverage
```

---

## 📁 Understanding the Structure

```
autonomous-agent-boilerplate/
│
├── CLAUDE.md                      # Instructions for Claude
├── .mcp.json                      # MCP server configuration
│
└── .claude/
    ├── settings.json              # Permissions
    ├── hooks.json                 # 10 automation hooks
    │
    ├── agents/                    # 10 pre-loaded agents
    ├── commands/                  # 10 slash commands
    ├── rules/                     # 8 governance rules
    └── skills/                    # 8 pre-loaded skills
```

### Rules Enforced

| Rule | Enforcement |
|------|-------------|
| **Immutability** | No direct mutation allowed |
| **File Size** | Max 800 lines per file |
| **Test Coverage** | Minimum 80% |
| **Security** | OWASP Top 10 checked |
| **Code Quality** | Auto-formatted, reviewed |

---

## 🎨 Customization

### Add Your Own Skills

Create `.claude/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: Description of what this skill does
allowed-tools: Read, Write, Edit, Bash
---

# My Custom Skill

## Patterns
...
```

### Add Your Own Agents

Create `.claude/agents/my-agent.md`:

```markdown
---
name: my-agent
description: What this agent does
tools: Read, Write, Edit, Bash
model: sonnet
---

Instructions for the agent...
```

### Add Your Own Commands

Create `.claude/commands/my-command.md`:

```markdown
---
description: What this command does
---

Instructions executed when /my-command is called...
```

---

## 🔧 Troubleshooting

### "Command not found"

```bash
ls .claude/commands/
# Should show plan.md, tdd.md, sp.autonomous.md, etc.
```

**Fix:** Ensure `.claude/` folder is in your project.

### "Build fails repeatedly"

```bash
> /build-fix
```

Self-heals up to 3 times, then asks for help.

### "MCP server error"

Check `.mcp.json` has correct API keys:

```json
{
  "mcpServers": {
    "github": {
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token"
      }
    }
  }
}
```

---

## ❓ FAQ

### Q: What's the difference between this and a normal template?

**Normal template:** Pre-made files you adapt to your project.
**This boilerplate:** Generates custom infrastructure for YOUR specific requirements.

### Q: Do I need to write detailed requirements?

Minimal requirements work, but more detail = better results. The boilerplate extracts technologies, features, and constraints from your requirements file.

### Q: Can I use this for existing projects?

Yes! Copy `.claude/`, `CLAUDE.md`, and `.mcp.json` to your project. Then use `/plan` for new features.

### Q: What if autonomous mode fails?

It self-heals up to 3 times. If still failing, it stops and reports what went wrong. You can then use manual commands (`/plan`, `/tdd`, `/build-fix`) to continue.

### Q: Can I customize the generated code style?

Yes! Edit `.claude/rules/coding-style.md` to change patterns, file size limits, naming conventions, etc.

---

## 📄 License

MIT License - use freely in personal and commercial projects.

---

## 🙏 Acknowledgments

- Inspired by [everything-claude-code](https://github.com/affaan-m/everything-claude-code) by [@affaan-m](https://github.com/affaan-m)
- Built for [Claude Code](https://claude.ai/claude-code) by Anthropic

---

<p align="center">
  <b>Write requirements. Run one command. Ship code.</b><br><br>
  <code>claude "/sp.autonomous requirements/my-app.md"</code>
</p>
