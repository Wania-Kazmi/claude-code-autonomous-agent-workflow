# Production-Ready Claude Code Template

> **Production-ready configuration for Claude Code.** Pre-configured agents, commands, hooks, skills, and rules for high-quality software development.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Ready-blue)](https://claude.ai/claude-code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Validated](https://img.shields.io/badge/Validated-46%2F46%20Components-brightgreen)](.)
[![Download](https://img.shields.io/badge/Download-Ready%20to%20Use-orange)](.)

### ✅ Validation Status: 46/46 Components (100%)

| Component | Count | Status |
|-----------|-------|--------|
| Agents | 10 | ✅ Complete |
| Commands | 10 | ✅ Complete |
| Skills | 8 | ✅ Complete |
| Rules | 8 | ✅ Complete |
| Hooks | 10 | ✅ Complete |
| MCP Servers | 6 | ✅ Complete |

---

## 📋 Table of Contents

- [What is This?](#-what-is-this)
- [Quick Start (5 Minutes)](#-quick-start-5-minutes)
- [For Absolute Beginners](#-for-absolute-beginners)
- [Available Commands](#-available-commands)
- [The Recommended Workflow](#-the-recommended-workflow)
- [Understanding the Structure](#-understanding-the-structure)
- [Agents Explained](#-agents-explained)
- [Skills Explained](#-skills-explained)
- [Rules & Best Practices](#-rules--best-practices)
- [Hooks (Automation)](#-hooks-automation)
- [MCP Servers](#-mcp-servers)
- [Step-by-Step Examples](#-step-by-step-examples)
- [Autonomous Mode](#-autonomous-mode)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [Contributing](#-contributing)

---

## 🎯 What is This?

This is a **pre-configured template** for [Claude Code](https://claude.ai/claude-code) that gives you:

| Feature | What It Does | Count |
|---------|--------------|-------|
| **Agents** | Specialized AI assistants for different tasks | 10 |
| **Commands** | Slash commands like `/plan`, `/tdd`, `/code-review` | 10 |
| **Rules** | Coding standards automatically enforced | 8 |
| **Hooks** | Auto-format, warn about issues, block mistakes | 10 |
| **Skills** | Reusable patterns (testing, API, database, coding) | 8 |
| **MCP Servers** | Extended capabilities (GitHub, memory, web scraping) | 6 |

### Why Use This Template?

| Without Template | With Template |
|------------------|---------------|
| Claude writes code immediately | Claude creates a plan first, waits for approval |
| No code review | Automatic security and quality checks |
| Inconsistent coding style | Enforced standards (immutability, file size limits) |
| Manual formatting | Auto-format on every save |
| Hope tests work | Test-driven development enforced |
| Debug in production | Catch bugs before commit |

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites

Before you begin, make sure you have:

1. **Claude Code CLI** - [Install here](https://docs.anthropic.com/en/docs/claude-code)
   ```bash
   # Check if installed
   claude --version
   ```

2. **Node.js 18+** - [Install here](https://nodejs.org/)
   ```bash
   # Check version
   node --version  # Should be v18 or higher
   ```

3. **Git** - [Install here](https://git-scm.com/)
   ```bash
   # Check if installed
   git --version
   ```

### Step 1: Get the Template

**Option A: Clone for a new project**
```bash
git clone https://github.com/your-username/production-ready-claude-code.git my-project
cd my-project
```

**Option B: Add to existing project**
```bash
# Copy these folders/files to your project
cp -r production-ready-claude-code/.claude your-project/
cp production-ready-claude-code/CLAUDE.md your-project/
cp production-ready-claude-code/.mcp.json your-project/
```

### Step 2: Configure API Keys (Optional)

If you want GitHub integration or web scraping, edit `.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

### Step 3: Start Using It!

```bash
cd my-project
claude
```

Then try your first command:
```
> /plan I want to add a user login feature
```

**That's it!** Claude will create a detailed plan and wait for your approval.

---

## 👶 For Absolute Beginners

### What is Claude Code?

Claude Code is an AI coding assistant that runs in your **terminal** (command line). Unlike ChatGPT where you copy-paste code, Claude Code:

- ✅ **Reads** your actual project files
- ✅ **Understands** your project structure
- ✅ **Edits** files directly (with your permission)
- ✅ **Runs** commands for you
- ✅ **Creates** new files when needed

### What Does This Template Add?

Think of this template as **training wheels + safety rails** for Claude Code:

```
Without Template:
  You: "Add a login feature"
  Claude: *immediately writes code*
  You: *hopes it works*

With Template:
  You: "/plan Add a login feature"
  Claude: "Here's my plan:
           1. Create User model
           2. Add auth routes
           3. Create login form
           ...
           Do you approve?"
  You: "Yes"
  Claude: *writes tests first*
  Claude: *implements code*
  Claude: *runs tests*
  Claude: *reviews for security*
  You: *confident it works*
```

### Your First 10 Minutes

#### 1. Open your terminal and navigate to your project:
```bash
cd my-project
```

#### 2. Start Claude Code:
```bash
claude
```

You'll see a prompt like:
```
Claude Code v1.x.x
Type your message or use /help for commands
>
```

#### 3. Try the `/plan` command:
```
> /plan I want to add a contact form that sends emails
```

#### 4. Read Claude's plan:
Claude will show you:
- What files will be created
- What dependencies are needed
- Potential risks
- Step-by-step implementation

#### 5. Approve or modify:
```
> Looks good, proceed
```
OR
```
> Can you also add form validation?
```

#### 6. Watch Claude work:
Claude will:
1. Write tests first (TDD)
2. Implement the feature
3. Run the tests
4. Review for security issues

#### 7. Review the code:
```
> /code-review
```

#### 8. Commit when ready:
```
> commit these changes
```

---

## 📝 Available Commands

Type these in Claude Code to trigger specialized workflows:

### 🎯 Planning Commands

| Command | What It Does | Example |
|---------|--------------|---------|
| `/plan` | Creates implementation plan, waits for approval | `/plan Add dark mode` |
| `/update-codemaps` | Generates architecture docs | `/update-codemaps` |
| `/update-docs` | Syncs README and guides | `/update-docs` |

### 💻 Development Commands

| Command | What It Does | Example |
|---------|--------------|---------|
| `/tdd` | Test-driven development | `/tdd` |
| `/build-fix` | Fixes build errors one at a time | `/build-fix` |
| `/refactor-clean` | Removes unused code safely | `/refactor-clean` |

### ✅ Quality Commands

| Command | What It Does | Example |
|---------|--------------|---------|
| `/code-review` | Security + quality check | `/code-review` |
| `/test-coverage` | Checks and improves coverage | `/test-coverage` |
| `/e2e` | Creates Playwright E2E tests | `/e2e test login flow` |

### 🤖 Autonomous Command (Spec-Kit-Plus)

| Command | What It Does | Example |
|---------|--------------|---------|
| `/sp.autonomous` | Builds entire project using Spec-Kit-Plus workflow | `/sp.autonomous requirements/app.md` |

> **Spec-Kit-Plus**: A structured workflow that generates specs, plans, tasks, then implements with full TDD and quality gates. See [Autonomous Mode](#-autonomous-mode-spec-kit-plus-workflow) for details.

---

## 🔄 The Recommended Workflow

Follow this workflow for best results:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   STEP 1: PLAN                                                  │
│   ─────────────────                                             │
│   > /plan I want to add [your feature]                          │
│                                                                 │
│   Claude will:                                                  │
│   • Analyze what's needed                                       │
│   • List files to create/modify                                 │
│   • Identify risks                                              │
│   • WAIT for your approval                                      │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   STEP 2: APPROVE                                               │
│   ─────────────────                                             │
│   > looks good, proceed                                         │
│   OR                                                            │
│   > modify: also add input validation                           │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   STEP 3: TDD IMPLEMENTATION                                    │
│   ─────────────────                                             │
│   Claude automatically:                                         │
│   1. Writes failing tests (RED)                                 │
│   2. Implements code to pass (GREEN)                            │
│   3. Refactors for quality (REFACTOR)                           │
│   4. Ensures 80%+ coverage                                      │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   STEP 4: CODE REVIEW                                           │
│   ─────────────────                                             │
│   > /code-review                                                │
│                                                                 │
│   Claude checks:                                                │
│   • Security vulnerabilities                                    │
│   • Code quality issues                                         │
│   • Best practice violations                                    │
│   • Performance problems                                        │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   STEP 5: FIX (if needed)                                       │
│   ─────────────────                                             │
│   > /build-fix     (if build fails)                             │
│   > fix the security issues found                               │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   STEP 6: COMMIT                                                │
│   ─────────────────                                             │
│   > commit with message "feat: add contact form"                │
│                                                                 │
│   Hooks automatically:                                          │
│   • Check for console.log statements                            │
│   • Pause for final review                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Understanding the Structure

```
your-project/
│
├── CLAUDE.md                    # Instructions for Claude (READ THIS)
├── .mcp.json                    # MCP server configuration
│
└── .claude/                     # All Claude Code configuration
    │
    ├── settings.json            # Permissions and environment
    ├── hooks.json               # Automation hooks
    │
    ├── agents/                  # 10 Specialized AI Assistants
    │   ├── planner.md           # Creates implementation plans
    │   ├── architect.md         # System design decisions
    │   ├── tdd-guide.md         # Test-driven development
    │   ├── code-reviewer.md     # Quality & security review
    │   ├── security-reviewer.md # Deep security analysis
    │   ├── build-error-resolver.md # Fix build errors
    │   ├── e2e-runner.md        # Playwright E2E tests
    │   ├── refactor-cleaner.md  # Remove dead code
    │   ├── doc-updater.md       # Update documentation
    │   └── test-runner.md       # Run tests
    │
    ├── commands/                # 10 Slash Commands
    │   ├── plan.md              # /plan
    │   ├── tdd.md               # /tdd
    │   ├── code-review.md       # /code-review
    │   ├── build-fix.md         # /build-fix
    │   ├── e2e.md               # /e2e
    │   ├── refactor-clean.md    # /refactor-clean
    │   ├── test-coverage.md     # /test-coverage
    │   ├── update-codemaps.md   # /update-codemaps
    │   ├── update-docs.md       # /update-docs
    │   └── sp.autonomous.md     # /sp.autonomous
    │
    ├── rules/                   # 8 Governance Files
    │   ├── security.md          # Security requirements
    │   ├── testing.md           # Testing requirements
    │   ├── coding-style.md      # Code style rules
    │   ├── git-workflow.md      # Git conventions
    │   ├── agents.md            # Agent usage rules
    │   ├── patterns.md          # Code patterns
    │   ├── performance.md       # Performance rules
    │   └── hooks.md             # Hook documentation
    │
    └── skills/                  # Reusable Knowledge (8 Skills)
        ├── coding-standards/    # TypeScript/JS/React standards
        ├── backend-patterns/    # API design, services
        ├── testing-patterns/    # Jest/Vitest/Playwright patterns
        ├── api-patterns/        # REST/GraphQL design
        ├── database-patterns/   # Prisma/SQL/migrations
        ├── claudeception/       # Session learning extraction
        ├── mcp-code-execution/  # MCP integration pattern
        └── skill-gap-analyzer/  # Auto-detect missing skills
```

---

## 🤖 Agents Explained

Agents are specialized AI assistants. Each one has a specific job:

### Planning & Design

| Agent | Trigger | What It Does |
|-------|---------|--------------|
| **planner** | `/plan` | Creates step-by-step implementation plans |
| **architect** | Complex design | System architecture, ADRs, scalability |

### Development

| Agent | Trigger | What It Does |
|-------|---------|--------------|
| **tdd-guide** | `/tdd` | Enforces test-first development |
| **build-error-resolver** | `/build-fix` | Fixes errors one at a time |
| **refactor-cleaner** | `/refactor-clean` | Removes unused code safely |

### Quality Assurance

| Agent | Trigger | What It Does |
|-------|---------|--------------|
| **code-reviewer** | `/code-review` | Security + quality checks |
| **security-reviewer** | Sensitive code | OWASP Top 10 checks |
| **test-runner** | After code | Runs tests, reports coverage |
| **e2e-runner** | `/e2e` | Playwright browser tests |

### Documentation

| Agent | Trigger | What It Does |
|-------|---------|--------------|
| **doc-updater** | `/update-docs` | Keeps docs in sync with code |

---

## 🧠 Skills Explained

Skills are **reusable knowledge libraries** that Claude consults when working on specific types of tasks. They contain patterns, best practices, and code examples.

### Development Skills

| Skill | What It Contains | When Used |
|-------|------------------|-----------|
| **coding-standards** | TypeScript/JS/React patterns, naming conventions, immutability | All code writing |
| **backend-patterns** | API design, services, repository pattern | Backend development |
| **api-patterns** | REST/GraphQL design, authentication, rate limiting | Building APIs |
| **database-patterns** | Prisma ORM, SQL, migrations, N+1 prevention | Database work |

### Testing Skills

| Skill | What It Contains | When Used |
|-------|------------------|-----------|
| **testing-patterns** | Jest/Vitest/Playwright patterns, mocking, AAA pattern | Writing tests |

### Meta Skills

| Skill | What It Contains | When Used |
|-------|------------------|-----------|
| **claudeception** | Extract learnings from sessions | After complex debugging |
| **mcp-code-execution** | MCP integration patterns | Building MCP tools |
| **skill-gap-analyzer** | Detect missing skills for project | Project setup |

### How Skills Work

1. **Automatic Detection**: When you start a task, Claude checks which skills apply
2. **Pattern Loading**: Relevant patterns are loaded into context
3. **Consistent Code**: Claude follows the loaded patterns for consistency

### Example: Building an API

```
> /plan Create a REST API for user management

# Claude detects:
# - api-patterns (REST design)
# - database-patterns (Prisma ORM)
# - coding-standards (TypeScript)
# - testing-patterns (for tests)

# All patterns are loaded, ensuring:
# - Proper HTTP status codes
# - Zod validation
# - Cursor-based pagination
# - 80% test coverage
```

---

## 📏 Rules & Best Practices

The template enforces these standards **automatically**:

### Rule 1: Immutability (CRITICAL)

**Always create new objects, never modify existing ones.**

```typescript
// ❌ WRONG - Direct mutation (BLOCKED)
user.name = 'New Name'
array.push(item)
object.property = value

// ✅ CORRECT - Immutable patterns (REQUIRED)
const updatedUser = { ...user, name: 'New Name' }
const newArray = [...array, item]
const newObject = { ...object, property: value }
```

**Why?** Prevents bugs, enables undo/redo, better for React.

### Rule 2: File Size Limits

| Metric | Guideline | Maximum |
|--------|-----------|---------|
| Lines per file | 200-400 | 800 |
| Function length | 20-30 | 50 |
| Nesting depth | 2-3 | 4 |

**Why?** Easier to read, test, and maintain.

### Rule 3: Test Coverage

| Code Type | Minimum Coverage |
|-----------|------------------|
| Regular code | 80% |
| Financial code | 100% |
| Authentication code | 100% |
| Security-critical code | 100% |

### Rule 4: Security Checklist

Every commit is checked for:
- ❌ Hardcoded secrets (API keys, passwords)
- ❌ SQL injection vulnerabilities
- ❌ XSS (Cross-Site Scripting) vulnerabilities
- ❌ Missing input validation
- ❌ Outdated dependencies with known vulnerabilities

---

## ⚡ Hooks (Automation)

Hooks run automatically to prevent mistakes and maintain quality:

### Prevention Hooks (Before Actions)

| Hook | What It Does | Why |
|------|--------------|-----|
| Dev Server Blocker | Blocks `npm run dev` outside tmux | Ensures you can see logs |
| Doc File Blocker | Blocks random .md file creation | Keeps docs organized |
| Git Push Review | Pauses before push | Final review chance |

### Auto-Fix Hooks (After Actions)

| Hook | What It Does | Why |
|------|--------------|-----|
| Prettier | Auto-formats JS/TS files | Consistent code style |
| TypeScript Check | Type-checks after edits | Catch errors early |
| Console.log Warning | Warns about debug logs | Clean production code |

### Audit Hooks (Session End)

| Hook | What It Does | Why |
|------|--------------|-----|
| Console.log Audit | Final check for debug logs | Last safety net |
| PR Logger | Shows PR URL after creation | Easy access |

---

## 🔌 MCP Servers

MCP (Model Context Protocol) gives Claude extra capabilities:

| Server | What It Does | How to Use |
|--------|--------------|------------|
| **filesystem** | Read/write files | Built-in, always available |
| **github** | GitHub API (PRs, issues) | Set `GITHUB_PERSONAL_ACCESS_TOKEN` |
| **memory** | Remember across sessions | Automatic |
| **sequential-thinking** | Better reasoning | Automatic |
| **firecrawl** | Web scraping | Set `FIRECRAWL_API_KEY` |
| **context7** | Live documentation | Automatic |

### Setting Up API Keys

Edit `.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxx"
      }
    },
    "firecrawl": {
      "env": {
        "FIRECRAWL_API_KEY": "fc_xxxxxxxxxxxx"
      }
    }
  }
}
```

---

## 💡 Step-by-Step Examples

### Example 1: Adding a New Feature

```bash
# Start Claude Code
$ claude

# Plan the feature
> /plan I want to add a dark mode toggle to my React app

# Claude outputs:
# Implementation Plan: Dark Mode Toggle
#
# Files to create:
# - src/hooks/useDarkMode.ts
# - src/components/DarkModeToggle.tsx
#
# Files to modify:
# - src/app/layout.tsx
# - tailwind.config.js
#
# Dependencies: none
#
# Risks: LOW
#
# Do you approve this plan?

> yes, proceed

# Claude writes tests first...
# Claude implements the feature...
# Claude runs tests...

# Review the code
> /code-review

# Claude checks for issues...
# No CRITICAL or HIGH issues found.

# Commit
> commit with message "feat: add dark mode toggle"
```

### Example 2: Fixing a Bug

```bash
$ claude

> /plan Fix the login form - it doesn't submit when pressing Enter

# Claude analyzes the issue and creates a plan...

> proceed

# Claude writes a test that reproduces the bug
# Test fails (proving the bug exists)
# Claude implements the fix
# Test passes (proving the fix works)

> /code-review

# All checks pass

> commit with message "fix: login form submits on Enter key"
```

### Example 3: Building an Entire Project

```bash
$ claude

> /sp.autonomous requirements/my-app.md

# Claude reads your requirements file
# Creates all necessary files
# Writes tests
# Implements features
# Reviews code
# Commits everything
# All without asking questions!
```

---

## 🤖 Autonomous Mode (Spec-Kit-Plus Workflow)

For fully autonomous project building, use `/sp.autonomous`. This command follows the **Spec-Kit-Plus** workflow - a structured approach to building complete projects from requirements.

### The Spec-Kit-Plus Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    SPEC-KIT-PLUS WORKFLOW                       │
│                                                                 │
│  BOOTSTRAP → ANALYZE → GENERATE → SPEC → PLAN → TASKS →       │
│  IMPLEMENT → QA → DELIVER                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

1. BOOTSTRAP
   └── Create .specify/ and .claude/ directories
   └── Initialize git, create feature branch

2. ANALYZE REQUIREMENTS
   └── Parse requirements file
   └── Detect project type, technologies, features

3. GENERATE INFRASTRUCTURE
   └── Generate skills for detected technologies
   └── Generate subagents (code-reviewer, test-runner)
   └── Generate hooks (pre-commit, quality-gate)

4. SPEC → PLAN → TASKS
   └── .specify/spec.md (detailed specification)
   └── .specify/plan.md (implementation plan)
   └── .specify/data-model.md (database schema)
   └── .specify/tasks.md (checklist of tasks)

5. IMPLEMENT
   └── Execute each task using appropriate skill
   └── Validate after each task
   └── Self-heal on failures (max 3 retries)

6. QUALITY ASSURANCE
   └── Code review (must pass)
   └── Tests (80%+ coverage required)
   └── App verification

7. DELIVER
   └── Git commit with comprehensive message
   └── Generate build report in .claude/build-reports/
```

### Directory Structure Created

```
your-project/
├── .specify/                    # Spec-Kit-Plus artifacts
│   ├── templates/               # Specification templates
│   ├── scripts/bash/            # Build scripts
│   ├── contracts/               # API contracts
│   ├── spec.md                  # Generated specification
│   ├── plan.md                  # Implementation plan
│   ├── data-model.md            # Database schema
│   └── tasks.md                 # Task checklist
│
└── .claude/
    ├── skills/                  # Generated skills
    ├── agents/                  # Generated subagents
    ├── hooks/                   # Generated hooks
    ├── logs/autonomous.log      # Build log
    └── build-reports/           # Final reports
```

### Create a Requirements File

Create `requirements/my-app.md`:

```markdown
# My Todo App

## Overview
A simple todo list application with user accounts.

## Features
- User registration and login
- Create, edit, delete todos
- Mark todos as complete
- Filter by status (all, active, completed)

## Technical
- Frontend: Next.js
- Backend: Express
- Database: PostgreSQL
```

### Run Autonomous Mode

```bash
$ claude "/sp.autonomous requirements/my-app.md"
```

Claude will execute the full Spec-Kit-Plus workflow:
1. **Bootstrap** - Set up project structure
2. **Analyze** - Parse requirements, detect technologies
3. **Generate** - Create skills, agents, hooks for your stack
4. **Spec** - Generate detailed specification
5. **Plan** - Create implementation plan
6. **Tasks** - Break down into actionable items
7. **Implement** - Build each feature with TDD
8. **QA** - Review code, run tests (80%+ coverage)
9. **Deliver** - Commit and generate report

**No human intervention needed!**

---

## 🔧 Troubleshooting

### Common Issues

#### "Command not found: /plan"

```bash
# Check if commands folder exists
ls .claude/commands/
# Should show: plan.md, tdd.md, etc.
```

**Fix:** Copy the `.claude` folder from this template to your project.

#### "Agent not responding"

```bash
# Check if agents folder exists
ls .claude/agents/
# Should show: planner.md, tdd-guide.md, etc.
```

**Fix:** Copy the `.claude` folder from this template to your project.

#### "Hooks not running"

```bash
# Validate hooks.json
cat .claude/hooks.json | python -m json.tool
```

**Fix:** Check for JSON syntax errors in `.claude/hooks.json`.

#### "Build fails repeatedly"

```bash
> /build-fix
```

If it fails 3 times on the same error, Claude will stop and ask for help.

#### "MCP server connection failed"

1. Check your API key is set in `.mcp.json`
2. Try running the server manually:
   ```bash
   npx -y @modelcontextprotocol/server-github
   ```

---

## ❓ FAQ

### Q: Do I need to pay for Claude Code?

A: Claude Code requires a Claude API key or Claude Pro subscription. Check [Anthropic's pricing](https://anthropic.com/pricing).

### Q: Can I customize the rules?

A: Yes! Edit files in `.claude/rules/`. For example, to change the file size limit, edit `.claude/rules/coding-style.md`.

### Q: Can I add my own commands?

A: Yes! Create a new `.md` file in `.claude/commands/`. Follow the format of existing commands.

### Q: Can I use this with JavaScript instead of TypeScript?

A: Yes! The rules apply to both. TypeScript is recommended but not required.

### Q: Why does Claude wait for approval after /plan?

A: This prevents wasted effort. If the plan is wrong, it's easier to fix before coding starts.

### Q: Can I skip the planning step?

A: Yes, just ask Claude directly: "Add a login feature". But you'll miss the safety benefits.

### Q: How do I update this template?

A: Pull the latest changes:
```bash
git pull origin main
```

---

## 🎓 Tips for Success

### Do's ✅

1. **Always start with `/plan`** for non-trivial features
2. **Trust the TDD process** - tests first, then code
3. **Run `/code-review`** before every commit
4. **Use immutable patterns** - spread operator always
5. **Keep files small** - 200-400 lines is ideal
6. **Read the plan carefully** before approving

### Don'ts ❌

1. **Don't skip planning** - it saves time overall
2. **Don't ignore code review** - security issues hide here
3. **Don't mutate state** - always create new objects
4. **Don't write huge files** - split into modules
5. **Don't leave console.log** - hooks will catch you
6. **Don't approve without reading** - plans can be wrong

---

## 🤝 Contributing

We welcome contributions! Here's how:

1. **Fork** this repository
2. **Create** a feature branch
3. **Use** `/plan` to document your changes
4. **Run** `/code-review` before submitting
5. **Create** a PR with clear description

### Areas for Contribution

- New agents for specific use cases
- Additional rules for frameworks
- Hook improvements
- Documentation improvements
- Bug fixes

---

## 📄 License

MIT License - feel free to use this template in your projects, personal or commercial.

---

## 🙏 Acknowledgments

- Inspired by [everything-claude-code](https://github.com/affaan-m/everything-claude-code) by [@affaan-m](https://github.com/affaan-m)
- Built for [Claude Code](https://claude.ai/claude-code) by Anthropic
- Community feedback and contributions welcome

---

<p align="center">
  <b>Happy Coding! 🚀</b><br><br>
  <i>Let Claude handle the complexity while you focus on creativity.</i><br><br>
  <a href="https://github.com/your-username/production-ready-claude-code/issues">Report Bug</a>
  ·
  <a href="https://github.com/your-username/production-ready-claude-code/issues">Request Feature</a>
</p>
