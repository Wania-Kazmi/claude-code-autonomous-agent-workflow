# Production-Ready Claude Code Configuration

> Battle-tested configuration from hackathon winner. Agents, commands, hooks, and rules for high-quality software development.

---

## Quick Reference: Available Commands

### Autonomous Workflow
| Command | What It Does |
|---------|--------------|
| `/sp.autonomous` | **Full autonomous build** from requirements file - **Supports session recovery** |
| `/q-status` | Check workflow state - which phase you're at |
| `/q-validate` | Validate workflow order, detect skipped phases, **check component utilization** |
| `/q-reset` | Reset workflow state (clear .specify/) |
| `/q-init` | Initialize workflow structure (runs automatically) |
| `/validate-workflow` | Run workflow-validator skill with full quality gate check |
| `/validate-components` | Check if skills/agents/hooks are production-ready |

### Spec-Kit-Plus Commands (Feature Workflow)
| Command | What It Does |
|---------|--------------|
| `/sp.specify` | Create feature specification from natural language description |
| `/sp.plan` | Generate technical implementation plan from spec |
| `/sp.tasks` | Break down plan into actionable tasks |
| `/sp.implement` | Execute implementation following tasks |
| `/sp.clarify` | Ask clarifying questions about requirements |
| `/sp.checklist` | Generate quality checklist for feature |
| `/sp.constitution` | Create/update project constitution (coding standards, architecture decisions) |
| `/sp.adr` | Create Architecture Decision Record for significant decisions |
| `/sp.phr` | Record Prompt History Record (automatic after each interaction) |
| `/sp.analyze` | Analyze existing codebase structure |
| `/sp.reverse-engineer` | Generate documentation from existing code |
| `/sp.git.commit_pr` | Commit changes and create pull request |
| `/sp.taskstoissues` | Convert tasks to GitHub issues |

### Development Commands
| Command | What It Does |
|---------|--------------|
| `/plan` | Create implementation plan, WAIT for approval |
| `/tdd` | Test-driven development (RED→GREEN→REFACTOR) |
| `/code-review` | Security and quality review of changes |
| `/build-fix` | Fix TypeScript/build errors incrementally |
| `/e2e` | Generate and run Playwright E2E tests |
| `/refactor-clean` | Remove dead code safely |
| `/test-coverage` | Analyze and improve test coverage |
| `/update-codemaps` | Regenerate architecture documentation |
| `/update-docs` | Sync documentation from source |

---

## Workflow: How to Build Features

### 1. Plan First (Recommended)

```
User: I want to add user authentication
Agent: Uses /plan → Creates detailed plan → WAITS for approval
User: Looks good, proceed
Agent: Uses /tdd → Writes tests first → Implements → Reviews
```

### 2. After Writing Code

**ALWAYS** run `/code-review` after writing or modifying code.

### 3. If Build Fails

Use `/build-fix` to incrementally fix errors (one at a time, max 3 attempts).

---

## Available Agents

Located in `.claude/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **planner** | Implementation planning | Complex features, refactoring |
| **architect** | System design, ADRs | Architectural decisions |
| **tdd-guide** | Test-driven development | New features, bug fixes |
| **code-reviewer** | Code review | After writing code |
| **security-reviewer** | Security analysis | Handling user input, auth |
| **build-error-resolver** | Fix build errors | When build fails |
| **e2e-runner** | E2E testing | Critical user flows |
| **refactor-cleaner** | Dead code cleanup | Code maintenance |
| **doc-updater** | Documentation | Updating docs |

---

## Available Skills (MUST USE)

Located in `.claude/skills/`:

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **workflow-validator** | Quality gate + component utilization | After EVERY phase, validates quality AND checks if skills/agents were used |
| **workflow-state-manager** | Session recovery & progress tracking | **AUTOMATICALLY USED** - Enables resume after interruption |
| **component-quality-validator** | Validate generated components | After generating skills/agents/hooks (Phase 6.5) |
| **skill-gap-analyzer** | Find missing skills | During project analysis |
| **coding-standards** | Code quality patterns | When writing any code |
| **testing-patterns** | Test patterns | When writing tests |
| **api-patterns** | REST/GraphQL patterns | When building APIs |
| **database-patterns** | DB design patterns | When working with databases |

### Component Utilization Enforcement (CRITICAL)

**The workflow-validator now checks if you're using custom components or bypassing them.**

```
IF skill/agent exists for task BUT wasn't used:
    → Phase is REJECTED
    → Phase is RESET
    → Must re-do using proper components
```

**What Gets Checked:**
- Skills invoked via `Skill(skill-name)` tool
- Agents invoked via `Task(subagent_type="agent-name")` tool
- Hooks executing on events

**Bypass = Automatic Phase Reset:**
```
Phase 11 (IMPLEMENT) completes
         ↓
workflow-validator checks:
  - Did you use coding-standards skill?
  - Did you use tdd-guide agent?
  - Did you use code-reviewer agent?
         ↓
    Any bypass detected?
         ↓
    YES → RESET phase, start over with proper components
    NO  → APPROVED, continue
```

---

## Coding Standards (CRITICAL)

### Immutability - ALWAYS Use

```typescript
// GOOD: Immutable patterns
const updatedUser = { ...user, name: 'New Name' }
const newArray = [...array, item]

// BAD: Direct mutation (NEVER do this)
user.name = 'New Name'
array.push(item)
```

### File Organization

- **200-400 lines** typical per file
- **800 lines** maximum
- High cohesion, low coupling
- Single responsibility per file

### Error Handling

```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('User-friendly message')
}
```

---

## Security Checklist

Before ANY commit:
- [ ] No hardcoded secrets (API keys, passwords)
- [ ] All user inputs validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized HTML)
- [ ] Authentication/authorization verified

---

## Testing Requirements

- **80% minimum** coverage for all code
- **100% required** for financial, auth, and security code

### TDD Workflow (Mandatory for New Features)

```
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)
```

---

## Directory Structure

```
.claude/
├── agents/           # 13 specialized agents
├── commands/         # 29 slash commands
├── rules/            # 8 governance files
├── skills/           # 15 reusable skills
├── hooks.json        # Automation hooks
└── settings.json     # Permissions and config

.specify/             # Spec-Kit-Plus (pre-installed)
├── memory/           # Project constitution
├── scripts/          # Utility scripts (7 scripts)
└── templates/        # Workflow templates (7 templates)

.mcp.json             # MCP server configuration
```

---

## Hooks (Automatic Enforcement)

### Prevention (PreToolUse)
- Blocks `npm run dev` outside tmux
- Blocks unnecessary .md file creation
- Pauses before `git push` for review

### Auto-Actions (PostToolUse)
- Auto-formats JS/TS with Prettier
- Warns about console.log statements
- Logs PR URL after creation

### Final Check (Stop)
- Audits for console.log in modified files

---

## Model Selection Strategy

| Model | When to Use |
|-------|-------------|
| **Haiku** | Simple tasks, frequent invocation |
| **Sonnet** | Main development, most agents |
| **Opus** | Complex architecture, deep reasoning |

---

## Rules Reference

Located in `.claude/rules/`:

| Rule File | What It Enforces |
|-----------|------------------|
| `security.md` | OWASP Top 10, secrets management |
| `testing.md` | 80% coverage, TDD workflow |
| `coding-style.md` | Immutability, file organization |
| `git-workflow.md` | Conventional commits, PR workflow |
| `agents.md` | When to use each agent |
| `patterns.md` | API format, repository pattern |
| `performance.md` | Model selection, optimization |
| `hooks.md` | Hook system documentation |

---

## Golden Rules

1. **Plan before code** - Use `/plan` for complex features
2. **Test first** - Use `/tdd` for new functionality
3. **Review always** - Use `/code-review` after changes
4. **Never mutate** - Always use spread operator
5. **Small files** - 200-400 lines typical, 800 max
6. **80% coverage** - Minimum test coverage
7. **No secrets in code** - Use environment variables
8. **Fix incrementally** - One error at a time
9. **Use existing skills** - ALWAYS use `Skill(name)` for matching tasks
10. **Use existing agents** - ALWAYS use `Task(subagent_type)` for specialized work
11. **Validate after phases** - Run `/q-validate` to check component utilization

## CRITICAL ENFORCEMENT (READ THIS)

### Forbidden Directories - NEVER CREATE

❌ **NEVER create these directories:**
- `skill-lab/` - Skills go in `.claude/skills/` ONLY
- `workspace/` - Use project root or `.specify/`
- `temp/` - Use system temp or clean up immediately
- `output/` - Output goes to `dist/` or `build/`
- Any nested `.claude/.claude/` or `.specify/.specify/`

✅ **ONLY create these directories:**
- `.claude/` and its subdirectories (if they don't exist)
- `.specify/` and its subdirectories (if they don't exist)
- Standard project dirs: `src/`, `lib/`, `tests/`, `docs/`

### Skill Creation Limits

- **Max 15 skills per project** - Consolidate before creating new
- **Max 3 skills per session** - Focus on optimization
- **Update existing > Create new** - Always prefer updating

### Skill Usage Enforcement

**BEFORE writing ANY code:**
```
1. Check .claude/skills/ for relevant skills
2. Load applicable skills via Skill() or Read()
3. Apply patterns from loaded skills
4. ONLY THEN write code
```

**sp.autonomous MUST:**
- Load technology-specific skills from `.claude/skills/`
- Apply skill patterns during implementation
- NEVER code manually if matching skill exists

### Hooks Enforce These Rules

Hooks will **automatically block**:
- Creation of forbidden directories
- Writing files to forbidden locations
- Excessive skill creation (warning at 15+)

See `.claude/rules/CRITICAL-ENFORCEMENT.md` for full details.

---

## Session Recovery (NEW)

**If you close your laptop during `/sp.autonomous`, the workflow can resume where it left off.**

### How It Works

1. **Automatic State Tracking**: Every phase completion is logged to `.specify/workflow-state.json`
2. **Progress Logging**: All steps logged to `.specify/workflow-progress.log`
3. **Smart Resume**: On restart, Claude detects where work stopped and continues

### Resume After Interruption

```bash
# Session was interrupted (laptop closed, process killed, etc.)
# Just run the same command again:
/sp.autonomous requirements.md

# Claude will:
# 1. Detect existing workflow state
# 2. Show resume report with current progress
# 3. Ask if you want to resume or start fresh
# 4. Continue from the exact step where it stopped
```

### What Gets Saved

| Data | Location | Purpose |
|------|----------|---------|
| Current phase | `.specify/workflow-state.json` | Which phase (1-13) |
| Feature progress | `.specify/workflow-state.json` | Which feature for COMPLEX projects |
| Task progress | `.specify/workflow-state.json` | Which task within a feature |
| Progress log | `.specify/workflow-progress.log` | Complete step-by-step history |
| Validation results | `.specify/validations/` | Quality gate grades |

### Resume Report Example

```
╔════════════════════════════════════════════════════════════════════════════╗
║                    WORKFLOW RESUME REPORT                                   ║
╠════════════════════════════════════════════════════════════════════════════╣

Project Type: COMPLEX
Current Phase: 11
Phases Completed: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

Features:
  Total: 3
  Completed: F-01
  Current: F-02
  Pending: F-03

Resume Point:
  Phase 11: Feature F-02 Implementation - Task 5 of 12

Instructions:
  Continue implementing F-02 starting from task T-F-02-005

Last Updated: 2026-01-22T10:30:00Z
Last Validation: Phase 10 - Grade B

╚════════════════════════════════════════════════════════════════════════════╝
```

### Manual State Check

```bash
# Check current workflow state at any time:
/q-status

# Validate state integrity:
/q-validate

# Reset state (start fresh):
/q-reset
```

### State Files Reference

```
.specify/
├── workflow-state.json        # Current state (phase, features, artifacts)
├── workflow-progress.log      # Timestamped event log
├── validations/               # Quality gate reports
│   ├── phase-1-report.md
│   ├── phase-2-report.md
│   └── ...
└── features/                  # Feature-specific artifacts (COMPLEX projects)
    ├── F-01-auth/
    │   ├── spec.md
    │   ├── plan.md
    │   └── tasks.md
    └── F-02-todos/
        └── ...
```

### Session Best Practices

1. **Let it run**: `/sp.autonomous` saves state automatically - no action needed
2. **Safe to interrupt**: Close laptop anytime - state is saved after each phase
3. **Resume anytime**: Run same command again to continue
4. **Check progress**: Use `/q-status` to see where you are
5. **Fresh start**: Use `/q-reset` if you want to start over

---

## Spec-Kit-Plus Pre-Installation

**IMPORTANT**: This boilerplate assumes Spec-Kit-Plus is pre-installed.

### What This Means

- `.claude/` and `.specify/` directories already exist with all necessary files
- `/sp.autonomous` **verifies** installation, doesn't create it
- No more "initialization failed" errors
- Faster startup - skips directory creation phase

### Verification

Before running `/sp.autonomous`, verify:

```bash
# Check directories exist
ls -la .claude/
ls -la .specify/

# Verify scripts are available
ls -la .specify/scripts/bash/

# Verify templates exist
ls -la .specify/templates/
```

If these don't exist, the boilerplate wasn't installed correctly.

---

## Spec-Kit-Plus Workflow System

### The Spec-Driven Development Process

Spec-Kit-Plus enforces a **spec-first** approach where every feature starts with clear requirements before any code is written.

```
┌─────────────────────────────────────────────────────────────────┐
│                  SPEC-KIT-PLUS FEATURE WORKFLOW                 │
└─────────────────────────────────────────────────────────────────┘

1. /sp.specify [feature description]
   ↓
   Creates: specs/NNN-feature-name/spec.md
   Branch: NNN-feature-name

2. /sp.clarify (if needed)
   ↓
   Asks clarifying questions
   Updates spec with answers

3. /sp.constitution (first feature only)
   ↓
   Creates: .specify/memory/constitution.md
   Defines: Coding standards, architecture decisions, constraints

4. /sp.plan
   ↓
   Creates: specs/NNN-feature-name/plan.md
   Includes: Architecture, components, implementation phases

5. /sp.adr (when making significant decisions)
   ↓
   Creates: history/adr/ADR-NNN-decision-title.md
   Documents: Context, decision, consequences, alternatives

6. /sp.tasks
   ↓
   Creates: specs/NNN-feature-name/tasks.md
   Breaks down plan into actionable tasks

7. /sp.implement
   ↓
   Executes tasks following:
   - Constitution rules
   - Plan architecture
   - ADR decisions
   - TDD approach (tests first)

8. /sp.git.commit_pr
   ↓
   Commits changes and creates PR
   Links spec, plan, tasks in PR description

9. /sp.phr (automatic)
   ↓
   Creates: history/prompts/[stage]/PHR-NNN-title.prompt.md
   Records: User prompt, AI response, outcomes, learnings
```

### Knowledge Capture Systems

#### 1. Prompt History Records (PHR)

**Purpose**: Capture every user interaction for learning, traceability, and team knowledge sharing.

**Automatic Creation**: After EVERY user interaction, a PHR is created with:
- Complete user prompt (verbatim)
- AI response snapshot
- Files modified
- Tests added
- Outcome and impact
- Reflections and learnings

**Storage**:
```
history/prompts/
├── constitution/         # Constitution creation sessions
├── general/             # General discussions
├── [feature-name]/      # Feature-specific work
│   ├── PHR-001-initial-spec.prompt.md
│   ├── PHR-002-clarify-auth.prompt.md
│   └── PHR-003-implement-login.prompt.md
```

**PHR Template Fields**:
```yaml
---
id: PHR-001
title: "Initial User Auth Spec"
stage: spec  # constitution|spec|plan|tasks|red|green|refactor|explainer|misc
date: 2026-01-22
surface: cli  # cli|api|web
model: sonnet-4.5
feature: user-auth
branch: 001-user-auth
command: /sp.specify
labels: [authentication, security]
links:
  spec: specs/001-user-auth/spec.md
  adr: history/adr/ADR-001-oauth-choice.md
files:
  - src/auth/login.ts
  - tests/auth/login.test.ts
tests:
  - ✅ Login with valid credentials
  - ✅ Reject invalid credentials
---

## Prompt
[User's exact input - never truncated]

## Response snapshot
[AI's response - key points]

## Outcome
- ✅ Impact: Created auth spec with OAuth2 integration
- 🧪 Tests: 5 test scenarios defined
- 📁 Files: spec.md created
- 🔁 Next prompts: /sp.plan to create implementation plan
- 🧠 Reflection: User wanted social login - clarified OAuth2 vs custom
```

#### 2. Architecture Decision Records (ADR)

**Purpose**: Document significant architectural and technical decisions.

**When to Create**:
- Technology/framework selection (e.g., choosing Next.js over Remix)
- Architecture patterns (e.g., microservices vs monolith)
- Database decisions (e.g., PostgreSQL vs MongoDB)
- Authentication strategies (e.g., JWT vs sessions)
- Security approaches
- Performance optimizations
- Any decision that:
  - Impacts how engineers write code
  - Has notable tradeoffs
  - Will likely be questioned later

**Storage**:
```
history/adr/
├── ADR-001-frontend-stack.md
├── ADR-002-auth-strategy.md
├── ADR-003-state-management.md
└── README.md  # Index of all ADRs
```

**ADR Template**:
```markdown
# ADR-001: Choose Frontend Technology Stack

## Status
Proposed | Accepted | Deprecated | Superseded

## Context
[What is the issue we're addressing? What constraints exist?]

We need to choose a frontend framework for the new web application.
Constraints:
- Team has React experience
- Need server-side rendering for SEO
- Deploy to Vercel
- TypeScript required

## Decision
[What decision did we make?]

We will use **Next.js 14** with:
- Framework: Next.js 14 (App Router)
- Styling: Tailwind CSS v3
- Deployment: Vercel
- State: React Context + SWR for data fetching

## Consequences
[What outcomes result from this decision?]

**Positive**:
- Built-in SSR/SSG support
- Great developer experience
- Vercel integration is seamless
- Strong TypeScript support

**Negative**:
- Locked into React ecosystem
- App Router is relatively new (learning curve)
- Vercel vendor lock-in

**Neutral**:
- File-based routing (team needs to learn conventions)

## Alternatives Considered
[What other options did we evaluate?]

1. **Remix + Cloudflare**
   - Pros: Modern patterns, edge deployment
   - Cons: Smaller ecosystem, team unfamiliar

2. **Astro + React islands**
   - Pros: Performance, flexibility
   - Cons: Less mature, overkill for our needs

## References
- Next.js 14 Documentation: https://nextjs.org/docs
- Related spec: specs/001-web-app/spec.md
- Related plan: specs/001-web-app/plan.md
```

**Automatic ADR Suggestion**: When `/sp.plan` completes, Claude analyzes the plan and suggests ADRs for any architecturally significant decisions detected.

### Constitution System

**Purpose**: Define project-wide rules, standards, and constraints that ALL features must follow.

**Created**: Before first feature implementation (automatically via `/sp.constitution`)

**Location**: `.specify/memory/constitution.md`

**What It Contains**:
```markdown
# Project Constitution

## Core Principles
1. Security-first development
2. Test-driven development (80%+ coverage)
3. Immutable data patterns
4. Progressive enhancement

## Coding Standards
- TypeScript strict mode enabled
- ESLint + Prettier enforced
- 200-400 lines per file (800 max)
- Functional components only (React)

## Architecture Decisions
- Monorepo structure (Turborepo)
- PostgreSQL for persistence
- Redis for caching
- Next.js for frontend
- tRPC for API layer

## Technology Constraints
### Required
- Node.js 20+
- TypeScript 5+
- React 18+

### Forbidden
- Class components
- Any DB other than PostgreSQL
- Direct DOM manipulation

## Quality Gates
- 80% test coverage minimum
- Zero TypeScript errors
- Zero ESLint errors
- All PRs require code review
- Security review for auth/payment code

## Out of Scope
- Mobile apps (web-only for now)
- Real-time features (future phase)
- Multi-tenancy (single tenant v1)
```

**Usage**: Every `/sp.implement` phase reads the constitution and enforces its rules during implementation.

### Directory Structure for Features

```
project-root/
├── .claude/                    # Claude Code config (pre-installed)
├── .specify/                   # Spec-Kit-Plus (pre-installed)
│   ├── memory/
│   │   └── constitution.md    # Project-wide rules
│   ├── scripts/               # Utility bash scripts
│   └── templates/             # Templates for spec/plan/tasks
│
├── specs/                     # Feature specifications
│   ├── 001-user-auth/
│   │   ├── spec.md           # Requirements
│   │   ├── plan.md           # Technical plan
│   │   ├── tasks.md          # Implementation tasks
│   │   └── prompts/          # Feature-specific PHRs
│   │       ├── PHR-001-initial-spec.prompt.md
│   │       └── PHR-002-clarify-oauth.prompt.md
│   │
│   └── 002-dashboard/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
│
├── history/
│   ├── adr/                   # Architecture Decision Records
│   │   ├── ADR-001-frontend-stack.md
│   │   ├── ADR-002-auth-strategy.md
│   │   └── README.md
│   │
│   └── prompts/               # Cross-cutting PHRs
│       ├── constitution/
│       ├── general/
│       └── [feature-name]/
│
└── src/                       # Actual implementation
    ├── auth/
    ├── dashboard/
    └── ...
```

### Best Practices

#### Starting a New Feature
```bash
# 1. Create spec from natural language
/sp.specify I want to add user authentication with OAuth2 and email/password

# 2. If anything unclear, clarify
/sp.clarify

# 3. Create constitution (first feature only)
/sp.constitution

# 4. Generate implementation plan
/sp.plan

# 5. Document significant decisions
/sp.adr

# 6. Break into tasks
/sp.tasks

# 7. Implement with TDD
/sp.implement

# 8. Commit and create PR
/sp.git.commit_pr
```

#### Resuming Interrupted Work
```bash
# Check current state
/q-status

# Validate workflow integrity
/q-validate

# Continue autonomous build (resumes automatically)
/sp.autonomous requirements.md
```

#### Knowledge Retrieval
```bash
# Find relevant PHRs
grep -r "authentication" history/prompts/

# Review ADRs
cat history/adr/README.md

# Check constitution
cat .specify/memory/constitution.md
```

---

## Quick Start

### Option 1: Spec-Kit-Plus Feature Workflow (Recommended)
```bash
# Create feature spec
/sp.specify Add user authentication with OAuth2 and email/password

# Generate implementation plan
/sp.plan

# Break into tasks
/sp.tasks

# Implement with TDD
/sp.implement

# Commit and create PR
/sp.git.commit_pr
```

### Option 2: Direct Development Workflow
```bash
# Plan first
/plan I want to add [feature description]

# Wait for approval, then implement with TDD
/tdd

# Review code
/code-review

# Fix any build errors
/build-fix
```

### Option 3: Full Autonomous Build
```bash
# From requirements file (supports session recovery)
/sp.autonomous requirements.md

# Can resume after interruption - just run again
/sp.autonomous requirements.md
```

---

## Key Differences: Spec-Kit-Plus vs Direct Development

| Aspect | Spec-Kit-Plus (`/sp.*`) | Direct Development |
|--------|-------------------------|-------------------|
| **Approach** | Spec-first, structured workflow | Ad-hoc, immediate coding |
| **Documentation** | Automatic (spec, plan, tasks, PHRs, ADRs) | Manual (if at all) |
| **Knowledge Capture** | Every interaction recorded | Nothing captured |
| **Team Collaboration** | Full traceability, shared context | Tribal knowledge |
| **Session Recovery** | Built-in via workflow state | Not supported |
| **Quality Gates** | Enforced at every phase | Manual |
| **Best For** | Complex features, team projects | Quick fixes, experiments |

**Recommendation**: Use Spec-Kit-Plus (`/sp.*` commands) for all production features. Use direct development only for quick experiments or one-off scripts.
