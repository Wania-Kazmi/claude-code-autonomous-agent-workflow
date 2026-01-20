---
description: Fully autonomous project builder - generates skills, subagents, hooks, and builds entire project from requirements
---

# /sp.autonomous

**Input**: `$ARGUMENTS` (path to requirements file)

---

## AUTONOMOUS MODE - NO HUMAN INTERVENTION

Read CLAUDE.md for complete instructions. Execute all phases automatically.

---

## Execution Steps

### 1. BOOTSTRAP

```bash
# Initialize Spec-Kit-Plus
mkdir -p .specify/{templates,scripts/bash,contracts}
mkdir -p .claude/{skills,subagents,hooks,logs,build-reports}

# Initialize git if needed
[ ! -d ".git" ] && git init

# Create feature branch
PROJECT_NAME=$(grep -m1 "^#" "$REQUIREMENTS_FILE" | sed 's/^# *//' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
git checkout -b "feature/${PROJECT_NAME}" 2>/dev/null || git checkout "feature/${PROJECT_NAME}"

# Log start
echo "[$(date -Iseconds)] [BOOTSTRAP] Starting autonomous build: $REQUIREMENTS_FILE" >> .claude/logs/autonomous.log
```

### 2. ANALYZE REQUIREMENTS

Parse `$ARGUMENTS` file and extract:
- Project name
- Project type (api, web-app, cli, microservice, full-stack)
- Technologies mentioned
- Features required
- Constraints

### 3. GENERATE INFRASTRUCTURE

Based on analysis, generate:

**Skills** (in `.claude/skills/`):
- Core: spec-creator, plan-creator, task-creator
- Tech-specific: Based on detected technologies
- Quality: code-reviewer, test-runner

**Subagents** (in `.claude/agents/`):
- code-reviewer-agent
- test-runner-agent
- Others as needed

**Hooks** (in `.claude/hooks/`):
- pre-commit.sh
- quality-gate.py
- self-heal.py

### 4. SPEC → PLAN → TASKS

Using generated skills:
1. Generate `.specify/spec.md`
2. Generate `.specify/plan.md` and `data-model.md`
3. Generate `.specify/tasks.md`

### 5. IMPLEMENT

For each task in tasks.md:
1. Select appropriate skill
2. Execute
3. Validate
4. Self-heal if needed
5. Mark complete [X]

### 6. QUALITY ASSURANCE

Run all quality gates:
- Code review (must pass)
- Tests (must pass, 80%+ coverage)
- App verification (if applicable)

Self-heal on failures (max 3 retries).

### 7. DELIVER

```bash
git add -A
git commit -m "feat(${PROJECT_NAME}): autonomous build complete

Co-Authored-By: Claude <noreply@anthropic.com>"

echo "[$(date -Iseconds)] [COMPLETE] Build finished" >> .claude/logs/autonomous.log
```

Generate report in `.claude/build-reports/`.

Signal: `<promise>AUTONOMOUS_BUILD_COMPLETE</promise>`

---

## Reference

See CLAUDE.md for:
- Skill generation templates
- Subagent generation templates
- Hook generation templates
- Technology detection rules
- Self-healing protocols
- Default configurations
