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
├── agents/           # 9 specialized agents
├── commands/         # 9 slash commands
├── rules/            # 8 governance files
├── skills/           # Reusable capabilities
├── hooks.json        # Automation hooks
└── settings.json     # Permissions and config

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

## Quick Start

```bash
# For a new feature:
/plan I want to add [feature description]

# Wait for approval, then:
/tdd

# After implementation:
/code-review

# If build fails:
/build-fix

# For autonomous build with session recovery:
/sp.autonomous requirements.md
# (Can resume after interruption)
```
