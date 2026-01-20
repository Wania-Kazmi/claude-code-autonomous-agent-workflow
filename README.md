# Autonomous Agent Boilerplate for Claude Code

> **Build entire projects from a single requirements file.** This boilerplate doesn't just provide pre-configured agents — it **autonomously generates** the skills, agents, hooks, and code your project needs using the Spec-Kit-Plus workflow.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Ready-blue)](https://claude.ai/claude-code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Autonomous](https://img.shields.io/badge/Autonomous-Spec--Kit--Plus-purple)](.)
[![Validated](https://img.shields.io/badge/Components-46%2F46-brightgreen)](.)

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
┌───────────────────────────────────────────────────────────────────┐
│                     SPEC-KIT-PLUS WORKFLOW                        │
│                                                                   │
│  BOOTSTRAP → ANALYZE → GENERATE → SPEC → PLAN → TASKS            │
│                                                    ↓              │
│                              DELIVER ← QA ← IMPLEMENT             │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

### Phase Details

| Phase | What Happens | Output |
|-------|--------------|--------|
| **BOOTSTRAP** | Create directories, init git, create branch | `.specify/`, `.claude/` |
| **ANALYZE** | Parse requirements, detect tech stack | Technology map |
| **GENERATE** | Create skills, agents, hooks for YOUR stack | Custom infrastructure |
| **SPEC** | Generate detailed specification | `.specify/spec.md` |
| **PLAN** | Create implementation plan | `.specify/plan.md` |
| **TASKS** | Break down into actionable items | `.specify/tasks.md` |
| **IMPLEMENT** | Build each feature with TDD | Source code + tests |
| **QA** | Code review, test coverage, security check | Quality report |
| **DELIVER** | Commit, generate report | Complete project |

### What Gets Generated

```
your-project/
│
├── .specify/                      # Spec-Kit-Plus artifacts
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
│   │   ├── api-builder/           # (if API project)
│   │   └── frontend-builder/      # (if frontend project)
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

### Skills (8)

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

### Commands (10)

| Command | What It Does |
|---------|--------------|
| `/sp.autonomous` | **Full autonomous build** |
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
