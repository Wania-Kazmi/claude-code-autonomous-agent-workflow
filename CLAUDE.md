# Production-Ready Claude Code Configuration

> Battle-tested configuration from hackathon winner. Agents, commands, hooks, and rules for high-quality software development.

---

## Quick Reference: Available Commands

### Autonomous Workflow
| Command | What It Does |
|---------|--------------|
| `/sp.autonomous` | **Full autonomous build** from requirements file |
| `/q-status` | Check workflow state - which phase you're at |
| `/q-validate` | Validate workflow order, detect skipped phases |
| `/q-reset` | Reset workflow state (clear .specify/) |

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
```
