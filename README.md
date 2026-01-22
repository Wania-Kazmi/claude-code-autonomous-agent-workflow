# Autonomous Agent Boilerplate for Claude Code

> **Build entire projects from a single requirements file.** This boilerplate doesn't just provide pre-configured agents — it **autonomously generates** the skills, agents, hooks, and code your project needs using the Spec-Kit-Plus workflow.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Ready-blue)](https://claude.ai/claude-code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Autonomous](https://img.shields.io/badge/Autonomous-Spec--Kit--Plus-purple)](.)
[![Validated](https://img.shields.io/badge/Components-51%2F51-brightgreen)](.)

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

1. **Creates feature branch** automatically (if on main/master)
2. **Analyzes** your requirements file
3. **Detects** technologies (Node.js, Express, PostgreSQL, Prisma, Jest)
4. **Generates** custom skills for your stack
5. **Generates** specialized agents for your project
6. **Generates** quality hooks for your workflow
7. **Creates** specification, plan, and task breakdown
8. **Implements** each feature using TDD
9. **Reviews** code for security and quality
10. **Delivers** complete project with tests

**Result:** A production-ready project with 80%+ test coverage, security-reviewed code, proper documentation, and all work done on a feature branch ready for PR.

### Automatic Branch Creation

When you start a new autonomous build:

- **Checks** if you're on `main` or `master` branch
- **Automatically creates** `feature/{project-name}` branch
- **Switches** to the new branch for all work
- **Sets up remote tracking** if origin exists
- **Preserves** your main/master branch untouched

This ensures best practices: all development happens on feature branches, keeping your main branch clean.

### Session Recovery - TODO Persistence + Multi-User Collaboration

> **Note for new users:** This boilerplate starts with a clean slate. Your first session will create the initial TODO state, which then persists across future sessions.

**Problem Solved:** TODOs are now saved across conversation sessions **AND support multiple developers working on the same project!**

When you start a **new conversation** (days/weeks later):

1. Run: `bash .claude/scripts/resume-work.sh`
2. See all saved TODOs from previous sessions (yours and your teammates')
3. Ask Claude to restore them to your new session

**Multi-User Support:**
- **Intelligent Merge**: When multiple people work on the project, their TODOs are merged automatically
- **Conflict Resolution**: Status priority (completed > in_progress > pending)
- **Contributor Tracking**: See who created and contributed to each TODO
- **History Snapshots**: Every session saves a historical snapshot

**How It Works:**
- TODOs automatically save to `.specify/todos.json` when session ends
- Merges with existing TODOs from other sessions
- Tracks contributors and maintains history in `.specify/todo-history/`
- No more lost context when starting fresh conversations

**Quick Commands:**
```bash
# Resume work and see saved TODOs (with collaboration info)
bash .claude/scripts/resume-work.sh

# See who contributed what
python3 .claude/scripts/sync-todos.py contributors

# View historical snapshots
python3 .claude/scripts/sync-todos.py history

# Check TODO status
python3 .claude/scripts/sync-todos.py status

# Manually save TODOs
python3 .claude/scripts/sync-todos.py save
```

**Example Multi-User Flow:**
```
Developer A → Creates 5 TODOs → Session ends → Auto-saves
Developer B → Resumes work → Sees A's TODOs → Adds 3 more → Marks 2 as completed → Auto-merges
Developer A → Returns → Sees combined work from both sessions
```

See [`.claude/docs/SESSION-RECOVERY.md`](.claude/docs/SESSION-RECOVERY.md) for full documentation.

---

## 🚀 Quick Start

### First-Time Setup

1. **Clone this boilerplate:**
   ```bash
   git clone https://github.com/your-username/claude-code-autonomous-agent-workflow.git
   cd claude-code-autonomous-agent-workflow
   ```

2. **Your first session will be clean** - no pre-existing TODOs or session state
   - `.specify/todos.json` will be created when you first use TODOs
   - Historical snapshots save to `.specify/todo-history/` automatically
   - See `.specify/todos.example.json` for the data structure

3. **Start working:**
   ```bash
   # Create your requirements file
   cp requirements/example.md requirements/my-app.md
   # Edit requirements/my-app.md

   # Run autonomous build
   claude "/sp.autonomous requirements/my-app.md"
   ```

### Prerequisites

```bash
# Claude Code CLI
claude --version

# Node.js 18+ (if building Node.js projects)
node --version

# Python 3.8+ (for TODO sync scripts)
python3 --version

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

**PREREQUISITE**: Spec-Kit-Plus must be pre-installed (`.claude/` and `.specify/` directories with templates and scripts).

When you run `/sp.autonomous`, this workflow executes:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SPEC-KIT-PLUS WORKFLOW                              │
│                       (Assumes Pre-Installed Framework)                     │
│                                                                             │
│  VERIFY → ANALYZE PROJECT → ANALYZE REQUIREMENTS → GAP ANALYSIS            │
│                                                       ↓                     │
│                                          GENERATE → TEST → VERIFY           │
│                                                            ↓                │
│                                               CONSTITUTION (ONE)            │
│                                                       ↓                     │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │  SIMPLE (1-3 features):     COMPLEX (4+ features):                     │ │
│  │  SPEC → PLAN → TASKS →      For EACH feature:                          │ │
│  │  IMPLEMENT → QA             SPEC → PLAN → TASKS → IMPLEMENT →          │ │
│  │                             UNIT TESTS → INTER-FEATURE TESTS           │ │
│  │                                         ↓                              │ │
│  │                             INTEGRATION QA (All features)              │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                       ↓                                     │
│                                   DELIVER                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### SIMPLE vs COMPLEX Mode

The workflow automatically detects project complexity:

| Mode | Feature Count | Workflow |
|------|---------------|----------|
| **SIMPLE** | 1-3 features | Single spec/plan/tasks cycle |
| **COMPLEX** | 4+ features | Per-feature iteration with inter-feature testing |

**COMPLEX Mode** ensures:
- ONE constitution for the whole project
- Each feature gets its own spec → plan → tasks → implement cycle
- Unit tests run after each feature
- Inter-feature regression tests after feature 2+
- Full integration testing at the end

### Phase Details

| Phase | What Happens | Output |
|-------|--------------|--------|
| **1. INIT** | Create `.specify/` and `.claude/` directories, setup git | Project structure |
| **2. ANALYZE PROJECT** | Inventory existing skills, agents, hooks | `project-analysis.json` |
| **3. ANALYZE REQUIREMENTS** | Parse requirements file, detect technologies | `requirements-analysis.json` |
| **4. GAP ANALYSIS** | Compare required vs existing, identify gaps | `gap-analysis.json` |
| **5. GENERATE** | Create missing skills, agents, hooks | Custom infrastructure |
| **6. TEST** | Validate components execute without errors | Functional test report |
| **6.5. QUALITY VALIDATION** | Score components against quality criteria | Quality validation report |
| **7. CONSTITUTION** | Define project rules and standards | `.specify/constitution.md` |
| **7.5. FEATURE BREAKDOWN** | (COMPLEX only) Break project into features | Feature list with dependencies |
| **8-10. SPEC/PLAN/TASKS** | Per-feature (COMPLEX) or whole project (SIMPLE) | `.specify/spec.md`, `plan.md`, `tasks.md` |
| **11. IMPLEMENT** | Build using TDD (write tests first) | Source code + unit tests |
| **11.5. FEATURE QA** | Verify feature's unit tests pass | Test report |
| **11.6. INTER-FEATURE TESTS** | (COMPLEX, 2+ features) Run ALL unit tests | Regression check |
| **12. INTEGRATION QA** | Full test suite: unit + integration + E2E | Complete quality report |
| **13. DELIVER** | Commit, generate final report | Complete project |

### Testing Strategy

The workflow enforces a comprehensive testing strategy:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            TESTING PYRAMID                                  │
│                                                                             │
│    Phase 11    │  Feature N unit tests (TDD - write first, then implement)  │
│    Phase 11.5  │  Feature N unit tests (verify implementation passes)       │
│    Phase 11.6  │  ALL unit tests (Feature 1 → N) - catch regressions       │
│    Phase 12    │  ALL unit + integration + E2E tests                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Coverage Requirements:**
- **80% minimum** for all code
- **100% required** for financial, auth, and security code
- All features must pass inter-feature regression tests

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
| **Quality Gate Teacher** | Grades each phase A/B/C/D/F with APPROVED/REJECTED |

### Quality Gate Teacher

Every phase is validated by the Quality Gate Teacher before proceeding:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        QUALITY GATE TEACHER                                  │
│                                                                             │
│   ┌─────────────┐      ┌─────────────┐      ┌─────────────┐                │
│   │  Phase N    │ ───▶ │   TEACHER   │ ───▶ │  Grade +    │                │
│   │  Output     │      │   Evaluate  │      │  Decision   │                │
│   └─────────────┘      └─────────────┘      └─────────────┘                │
│                                                    │                        │
│                        ┌───────────────────────────┼──────────────────┐     │
│                        ▼                           ▼                  ▼     │
│                   A (90-100%)                B/C (70-89%)        D/F (<70%) │
│                   APPROVED                   APPROVED            REJECTED   │
│                   Continue                   Continue            Self-Heal  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Grading Criteria (varies by phase):**
- Constitution: Clarity, completeness, enforceability
- Spec: Feature coverage, acceptance criteria, technical accuracy
- Plan: Architecture quality, risk assessment, dependency mapping
- Tasks: Granularity, skill mapping, dependency order
- Implementation: Code quality, test coverage, security
- Testing: Pass rate, coverage percentage, regression status

### Component Quality Validation (Phase 6.5)

Generated skills, agents, and hooks are validated for **production-readiness** before use:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              COMPONENT QUALITY VALIDATION                                    │
│                                                                             │
│  WHO validates?  → component-quality-validator skill                        │
│  HOW validated?  → Automated quality criteria scoring                       │
│                                                                             │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                       │
│  │   SKILL     │   │   AGENT     │   │   HOOK      │                       │
│  ├─────────────┤   ├─────────────┤   ├─────────────┤                       │
│  │ ✓ Triggers  │   │ ✓ Model fit │   │ ✓ JSON valid│                       │
│  │ ✓ Workflow  │   │ ✓ Min tools │   │ ✓ Bash valid│                       │
│  │ ✓ Templates │   │ ✓ Clear ins │   │ ✓ Targeted  │                       │
│  │ ✓ Validation│   │ ✓ Fail plan │   │ ✓ No conflict│                      │
│  └─────────────┘   └─────────────┘   └─────────────┘                       │
│         ↓                 ↓                 ↓                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  SCORE: 0-100  →  GRADE: A/B/C/D/F  →  APPROVED or REJECTED         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Rejected Components Regeneration:**
- Attempt 1: Apply specific fixes from validation report
- Attempt 2: Simplify scope, focus on core functionality
- Attempt 3: Use template from similar working component
- Attempt 4+: Mark MANUAL_REQUIRED, continue with others

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
| 7.5 FEATURE BREAKDOWN | `features.json` | `[ -f ".specify/features.json" ]` (COMPLEX only) |
| 8. SPEC | `spec.md` or `features/N/spec.md` | Spec file exists |
| 9. PLAN | `plan.md` or `features/N/plan.md` | Plan file exists |
| 10. TASKS | `tasks.md` or `features/N/tasks.md` | Tasks file exists |
| 11. IMPLEMENT | Tasks marked `[X]` | `grep -c "\[X\]" tasks.md` |
| 11.5 FEATURE QA | Unit tests pass | Test exit code 0 |
| 11.6 INTER-FEATURE | All unit tests pass | Combined test exit code 0 |
| 12. INTEGRATION QA | Full test suite pass | Unit + Integration + E2E pass |
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

## 🏗️ Complex Projects: Feature Iteration

For complex projects (4+ features), the workflow uses a sophisticated iteration pattern:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COMPLEX PROJECT FEATURE ITERATION                         │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  CONSTITUTION (ONE for entire project - Phase 7)                        ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                    ↓                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  FEATURE BREAKDOWN (Phase 7.5)                                          ││
│  │  → Extract features from requirements                                   ││
│  │  → Map dependencies between features                                    ││
│  │  → Order features by dependency graph                                   ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                    ↓                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  FOR EACH FEATURE (in dependency order):                                ││
│  │  ┌─────────────────────────────────────────────────────────────────────┐││
│  │  │  8. SPEC (feature-specific)                                         │││
│  │  │  9. PLAN (feature-specific)                                         │││
│  │  │ 10. TASKS (feature-specific)                                        │││
│  │  │ 11. IMPLEMENT (TDD: tests first, then code)                         │││
│  │  │ 11.5 FEATURE QA (unit tests for this feature)                       │││
│  │  │ 11.6 INTER-FEATURE TESTS (all unit tests, if feature 2+)            │││
│  │  └─────────────────────────────────────────────────────────────────────┘││
│  │                              ↓ (next feature)                           ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                    ↓                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  12. INTEGRATION QA (Full test suite across all features)               ││
│  │      → Unit tests (all features)                                        ││
│  │      → Integration tests (feature interactions)                         ││
│  │      → E2E tests (user journeys)                                        ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                    ↓                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  13. DELIVER                                                            ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Example: E-Commerce Platform (5 Features)

```
Feature 1: User Auth     → Spec → Plan → Tasks → Implement → Unit Tests ✓
Feature 2: Products      → Spec → Plan → Tasks → Implement → Unit Tests → Inter-Feature Tests ✓
Feature 3: Cart          → Spec → Plan → Tasks → Implement → Unit Tests → Inter-Feature Tests ✓
Feature 4: Orders        → Spec → Plan → Tasks → Implement → Unit Tests → Inter-Feature Tests ✓
Feature 5: Payments      → Spec → Plan → Tasks → Implement → Unit Tests → Inter-Feature Tests ✓
                                                    ↓
                         INTEGRATION QA (All features together)
                                                    ↓
                                    DELIVER
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

### Agents (13) - With Dynamic Model Selection

| Agent | Model | Purpose |
|-------|-------|---------|
| **architect** | Opus | System design decisions |
| **planner** | Opus | Creates implementation plans |
| **security-reviewer** | Opus | OWASP Top 10 checks |
| **tdd-guide** | Opus | Test-driven development |
| **code-reviewer** | Sonnet | Quality & security review |
| **build-error-resolver** | Sonnet | Fix build errors |
| **e2e-runner** | Sonnet | Playwright E2E tests |
| **refactor-cleaner** | Sonnet | Remove dead code |
| **doc-updater** | Sonnet | Update documentation |
| **test-runner** | Sonnet | Run tests |
| **git-ops** | Haiku | Git commits, pushes, status |
| **file-ops** | Haiku | File listing, searching, moving |
| **format-checker** | Haiku | Prettier, ESLint, formatting |

### Model Selection Strategy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DYNAMIC MODEL SELECTION                                   │
│                                                                             │
│   OPUS (Complex)          SONNET (Medium)         HAIKU (Light)            │
│   ──────────────          ───────────────         ─────────────            │
│   • Architecture          • Code writing          • Git operations         │
│   • Security analysis     • Code review           • File operations        │
│   • Multi-phase planning  • Test writing          • Formatting             │
│   • Constitution          • Build fixes           • Simple validations     │
│                                                                             │
│   Cost: $$$$$             Cost: $$$$              Cost: $$$                │
│   ~10 calls/project       ~100 calls/project      ~50 calls/project        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Skills (10)

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
| **component-quality-validator** | Validate generated components are production-ready |

### Commands (15)

| Command | What It Does |
|---------|--------------|
| `/sp.autonomous` | **Full autonomous build** from requirements |
| `/q-status` | Check workflow state - which phase you're at |
| `/q-validate` | Validate workflow order, detect violations, check component utilization |
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
| `/validate-workflow` | Run full workflow validation |
| `/validate-components` | Check component quality (A-F grading) |

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
├── CLAUDE.md                      # Instructions for Claude (Golden Rules)
├── README.md                      # This documentation
├── .mcp.json                      # MCP server configuration (6 servers)
│
├── .claude/                       # Claude Code configuration
│   ├── settings.json              # Permissions + environment variables
│   ├── hooks.json                 # Automation hooks (PreToolUse/PostToolUse/Stop)
│   ├── skill-rules.json           # Dynamic skill activation rules (18 patterns)
│   │
│   ├── agents/                    # 13 specialized agents
│   │   ├── architect.md           # (opus) System design
│   │   ├── planner.md             # (opus) Implementation planning
│   │   ├── security-reviewer.md   # (opus) OWASP security analysis
│   │   ├── tdd-guide.md           # (opus) Test-driven development
│   │   ├── code-reviewer.md       # (sonnet) Code quality review
│   │   ├── build-error-resolver.md# (sonnet) Fix build errors
│   │   ├── e2e-runner.md          # (sonnet) Playwright E2E tests
│   │   ├── refactor-cleaner.md    # (sonnet) Dead code removal
│   │   ├── doc-updater.md         # (sonnet) Documentation sync
│   │   ├── test-runner.md         # (sonnet) Test execution
│   │   ├── git-ops.md             # (haiku) Git operations
│   │   ├── file-ops.md            # (haiku) File operations
│   │   └── format-checker.md      # (haiku) Prettier/ESLint
│   │
│   ├── commands/                  # 15 slash commands
│   │   ├── sp.autonomous.md       # Full autonomous build (57KB)
│   │   ├── q-status.md            # Workflow status
│   │   ├── q-validate.md          # Workflow validation
│   │   ├── q-reset.md             # Reset workflow
│   │   ├── plan.md                # Implementation planning
│   │   ├── tdd.md                 # Test-driven development
│   │   ├── code-review.md         # Code review
│   │   ├── build-fix.md           # Build error fixing
│   │   ├── e2e.md                 # E2E testing
│   │   ├── refactor-clean.md      # Dead code cleanup
│   │   ├── test-coverage.md       # Coverage analysis
│   │   ├── update-codemaps.md     # Architecture docs
│   │   ├── update-docs.md         # Documentation sync
│   │   ├── validate-workflow.md   # Workflow validation
│   │   └── validate-components.md # Component quality check
│   │
│   ├── skills/                    # 10 reusable skills
│   │   ├── api-patterns/          # REST/GraphQL patterns
│   │   ├── backend-patterns/      # Backend architecture
│   │   ├── coding-standards/      # Code quality patterns
│   │   ├── database-patterns/     # Database/ORM patterns
│   │   ├── testing-patterns/      # Testing patterns
│   │   ├── claudeception/         # Session learning
│   │   ├── mcp-code-execution-template/  # MCP integration
│   │   ├── skill-gap-analyzer/    # Gap analysis
│   │   ├── workflow-validator/    # Quality gate + component utilization
│   │   └── component-quality-validator/  # Production-readiness check
│   │
│   ├── rules/                     # 8 governance rules
│   │   ├── agents.md              # Agent orchestration
│   │   ├── coding-style.md        # Immutability, file organization
│   │   ├── git-workflow.md        # Conventional commits
│   │   ├── hooks.md               # Hook system docs
│   │   ├── patterns.md            # API/service patterns
│   │   ├── performance.md         # Model selection
│   │   ├── security.md            # OWASP Top 10
│   │   └── testing.md             # 80% coverage, TDD
│   │
│   ├── hooks/                     # Hook scripts
│   │   ├── skill-activator.sh     # Dynamic skill activation
│   │   ├── skill-enforcement-stop.sh  # End-of-session enforcement
│   │   └── claudeception-activator.sh # Session learning
│   │
│   └── logs/                      # Activity logs
│       ├── agent-usage.log        # Task tool invocations
│       ├── skill-invocations.log  # Skill() calls
│       ├── skill-activations.log  # Skill activator output
│       ├── skill-enforcement.log  # Enforcement decisions
│       ├── tool-usage.log         # Write/Edit operations
│       └── file-changes.log       # File modifications
│
├── .specify/                      # Spec-Kit-Plus workflow artifacts
│   ├── project-analysis.json      # Existing project analysis
│   ├── requirements-analysis.json # Requirements parsing
│   ├── gap-analysis.json          # Missing components
│   ├── constitution.md            # Project rules
│   ├── spec.md                    # Specification
│   ├── plan.md                    # Implementation plan
│   ├── tasks.md                   # Task checklist
│   ├── templates/                 # Feature templates
│   └── validations/               # Phase validation reports
│
└── requirements/                  # Your requirements files
    └── my-app.md                  # Example requirements
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

## 📊 Monitoring & Observability

The boilerplate includes comprehensive logging to track what's happening during autonomous builds.

### Log Files

All logs are stored in `.claude/logs/`:

| Log File | What It Tracks | Example Entry |
|----------|----------------|---------------|
| `agent-usage.log` | Task tool invocations (agent spawning) | `[2024-01-21T10:30:00] Agent task invoked` |
| `skill-invocations.log` | Skill() tool calls | `[2024-01-21T10:31:00] Skill invoked: coding-standards` |
| `skill-activations.log` | Skill activator hook output | `Prompt: "build api" \| Matched: api-patterns` |
| `skill-enforcement.log` | Enforcement decisions | `MANDATORY skill not used: testing-patterns` |
| `tool-usage.log` | Write/Edit tool calls | `[2024-01-21T10:32:00] Tool: Edit \| File: src/api.ts` |
| `file-changes.log` | File modifications | `[2024-01-21T10:32:00] File modified: src/api.ts` |

### Viewing Logs

```bash
# View recent skill invocations
tail -20 .claude/logs/skill-invocations.log

# Watch agent usage in real-time
tail -f .claude/logs/agent-usage.log

# Check which skills were activated
cat .claude/logs/skill-activations.log | grep "DETECTED MATCHES"

# See enforcement decisions
cat .claude/logs/skill-enforcement.log

# Count skill usage
wc -l .claude/logs/skill-invocations.log
```

### Component Utilization Check

The `workflow-validator` skill tracks if custom components are being used:

```bash
# Check component utilization during a build
claude "/q-validate"
```

This shows:
- **Skills Used**: Which skills were invoked via `Skill(name)`
- **Agents Used**: Which agents were spawned via `Task(subagent_type)`
- **Utilization %**: Percentage of available components that were used
- **Bypass Detection**: Warning if general agent did work without using custom components

### Phase Validation Reports

After each phase, validation reports are generated in `.specify/validations/`:

```bash
# List validation reports
ls .specify/validations/

# View a specific phase report
cat .specify/validations/phase-11-report.md
```

Example report structure:
```markdown
# Phase 11 Validation Report

## Summary
| Field | Value |
|-------|-------|
| Phase | 11: IMPLEMENT |
| Grade | B |
| Score | 85/100 |
| Status | APPROVED |

## Component Utilization
| Category | Available | Used | Percentage |
|----------|-----------|------|------------|
| Skills | 10 | 4 | 40% |
| Agents | 13 | 3 | 23% |

## Issues Found
- Missing skill invocation: testing-patterns

## Decision
✅ APPROVED - Proceeding to Phase 12
```

### Reset Detection

If a phase is reset due to component bypass:

```bash
# Check reset counter
cat .specify/validations/reset-counter.json

# View bypass log
cat .specify/validations/bypass-log.json
```

### Environment Variables

The following environment variables control workflow behavior:

| Variable | Value | Purpose |
|----------|-------|---------|
| `AUTONOMOUS_MODE` | `true` | Enable full autonomous execution |
| `MAX_SELF_HEAL_RETRIES` | `3` | Max retry attempts per phase |
| `SKILL_ENFORCEMENT` | `strict` | Enforce skill usage (strict/warn/off) |

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
