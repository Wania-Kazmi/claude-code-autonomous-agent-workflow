# Agent Orchestration

## Available Agents

Located in `.claude/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| tdd-guide | Test-driven development | New features, bug fixes |
| code-reviewer | Code review | After writing code |
| security-reviewer | Security analysis | Before commits |
| build-error-resolver | Fix build errors | When build fails |
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation | Updating docs |

## Immediate Agent Usage

No user prompt needed:
1. Complex feature requests → Use **planner** agent
2. Code just written/modified → Use **code-reviewer** agent
3. Bug fix or new feature → Use **tdd-guide** agent
4. Architectural decision → Use **architect** agent
5. Security-sensitive code → Use **security-reviewer** agent
6. Build fails → Use **build-error-resolver** agent

## Model Selection Strategy

**Haiku** (lightweight, fast):
- Simple file operations
- Straightforward tasks
- Frequent invocation agents

**Sonnet** (best coding):
- Main development work
- Code review
- Build error resolution
- Most agents default to this

**Opus** (deepest reasoning):
- Complex architectural decisions
- Planning multi-phase features
- Security analysis
- Maximum reasoning requirements

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch 3 agents in parallel:
1. Agent 1: Security analysis of auth.ts
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utils.ts

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker

## Workflow Integration

```
/plan → planner agent → WAIT → user confirms
/tdd → tdd-guide agent → RED → GREEN → REFACTOR
/code-review → code-reviewer agent → issues found
/build-fix → build-error-resolver agent → fix errors
/e2e → e2e-runner agent → test user flows
```
