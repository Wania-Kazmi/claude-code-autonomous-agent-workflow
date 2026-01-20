---
`description: Fully autonomous project builder - analyzes current project, generates missing skills/agents/hooks, tests them, then builds using Spec-Kit-Plus workflow
---

# /sp.autonomous

**Input**: `$ARGUMENTS` (path to requirements file)

---

## AUTONOMOUS MODE - FULL SPEC-KIT-PLUS WORKFLOW

This command executes the complete Spec-Kit-Plus workflow:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SPEC-KIT-PLUS WORKFLOW                              │
│                                                                             │
│  [PRE-CHECK] → INIT → ANALYZE → GAP-ANALYSIS → GENERATE → TEST → VERIFY    │
│                                                               ↓             │
│                     IMPLEMENT ← TASKS ← PLAN ← SPEC ← CONSTITUTION          │
│                          ↓                                                  │
│                     [VALIDATE] → QA → DELIVER                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**DO NOT SKIP ANY PHASE. Each phase has automatic verification.**

---

## PHASE 0: PRE-CHECK (AUTOMATIC - ALWAYS RUNS FIRST)

> **THIS PHASE IS MANDATORY AND AUTOMATIC. It determines whether to start fresh or resume.**

### Step 0.1: Invoke Workflow Validator

**EXECUTE IMMEDIATELY**: Call the `workflow-validator` skill to check current state.

```bash
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              SPEC-KIT-PLUS PRE-CHECK                           ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Checking workflow state...                                    ║"
```

### Step 0.2: Detect Current Phase

Check which artifacts exist to determine current phase:

```bash
CURRENT_PHASE=0

# Check each phase artifact
[ -d ".specify" ] && [ -d ".claude" ] && CURRENT_PHASE=1
[ -f ".specify/project-analysis.json" ] && CURRENT_PHASE=2
[ -f ".specify/requirements-analysis.json" ] && CURRENT_PHASE=3
[ -f ".specify/gap-analysis.json" ] && CURRENT_PHASE=4
[ "$(find .claude/skills -name 'SKILL.md' 2>/dev/null | wc -l)" -gt 9 ] && CURRENT_PHASE=5
[ -f ".specify/constitution.md" ] && CURRENT_PHASE=7
[ -f ".specify/spec.md" ] && CURRENT_PHASE=8
[ -f ".specify/plan.md" ] && CURRENT_PHASE=9
[ -f ".specify/tasks.md" ] && CURRENT_PHASE=10

echo "║  Current Phase: $CURRENT_PHASE                                          ║"
```

### Step 0.3: Decision - Start Fresh or Resume

**IF** `CURRENT_PHASE == 0`:
```
║  Status: FRESH START                                             ║
║  Action: Beginning from Phase 1                                  ║
╚════════════════════════════════════════════════════════════════╝

→ PROCEED TO PHASE 1
```

**IF** `CURRENT_PHASE > 0`:
```
║  Status: RESUMING                                                ║
║  Last Completed: Phase {CURRENT_PHASE}                           ║
║  Action: Resuming from Phase {CURRENT_PHASE + 1}                 ║
╚════════════════════════════════════════════════════════════════╝

→ SKIP TO PHASE {CURRENT_PHASE + 1}
```

### Step 0.4: Validate No Violations

Check for skipped phases (violations):

```python
def check_violations():
    """Ensure no phases were skipped."""
    artifacts = {
        1: exists(".specify/"),
        2: exists(".specify/project-analysis.json"),
        3: exists(".specify/requirements-analysis.json"),
        4: exists(".specify/gap-analysis.json"),
        # ... etc
    }

    violations = []
    highest_complete = max([k for k, v in artifacts.items() if v], default=0)

    for phase in range(1, highest_complete):
        if not artifacts.get(phase, False):
            violations.append(f"Phase {phase} was skipped!")

    return violations
```

**IF violations found**:
```
⚠️  WORKFLOW VIOLATION DETECTED

Skipped phases: {list}

Action: Will execute skipped phases before continuing.
```

→ Execute missing phases in order, then resume.

### Step 0.5: Log Pre-Check Result

```bash
echo "[$(date -Iseconds)] [PRE-CHECK] Current phase: $CURRENT_PHASE" >> .claude/logs/autonomous.log
echo "[$(date -Iseconds)] [PRE-CHECK] Violations: $VIOLATIONS" >> .claude/logs/autonomous.log
echo "[$(date -Iseconds)] [PRE-CHECK] Action: $ACTION" >> .claude/logs/autonomous.log
```

---

## VALIDATION PROTOCOL - QUALITY GATE TEACHER (RUNS AFTER EVERY PHASE)

After completing ANY phase, **INVOKE the workflow-validator skill** to perform Quality Gate review:

```
┌──────────────────┐
│  Phase N Done    │
└────────┬─────────┘
         ▼
┌──────────────────────────────────────────────────────────────┐
│  QUALITY GATE TEACHER VALIDATION                             │
│                                                              │
│  1. Invoke workflow-validator skill with phase number        │
│  2. Validator READS output artifacts                         │
│  3. Validator EVALUATES against quality criteria             │
│  4. Validator GRADES: A / B / C / D / F                      │
│  5. Validator GENERATES: .specify/validations/phase-N.md     │
│  6. Validator DECIDES: APPROVED (A/B/C) or REJECTED (D/F)    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
         │
    ┌────┴────┐
    ▼         ▼
APPROVED   REJECTED
(Grade     (Grade
 A/B/C)     D/F)
    │         │
    │         ▼
    │    ┌────────────────────────┐
    │    │ Review feedback        │
    │    │ Fix identified issues  │
    │    │ Re-do phase            │
    │    │ Max 3 attempts         │
    │    └────────────────────────┘
    ▼
┌──────────────────┐
│  Phase N+1       │
└──────────────────┘
```

### Quality Gate Execution (DO NOT SKIP)

```bash
# After EVERY phase completes, run Quality Gate
quality_gate() {
    PHASE=$1
    ATTEMPT=1
    MAX_ATTEMPTS=3

    # Create validations directory
    mkdir -p .specify/validations

    while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
        echo "[$(date -Iseconds)] [QUALITY-GATE] Phase $PHASE validation (attempt $ATTEMPT)" >> .claude/logs/autonomous.log

        # INVOKE workflow-validator skill
        # This evaluates QUALITY, not just file existence
        # Returns: GRADE (A/B/C/D/F) and DECISION (APPROVED/REJECTED)

        # The validator will:
        # - Read artifacts
        # - Score against phase-specific criteria
        # - Generate .specify/validations/phase-$PHASE-report.md
        # - Return APPROVED or REJECTED

        if [ "$DECISION" == "APPROVED" ]; then
            echo "[$(date -Iseconds)] [QUALITY-GATE] Phase $PHASE: GRADE=$GRADE APPROVED" >> .claude/logs/autonomous.log
            return 0
        else
            echo "[$(date -Iseconds)] [QUALITY-GATE] Phase $PHASE: GRADE=$GRADE REJECTED (attempt $ATTEMPT)" >> .claude/logs/autonomous.log

            # Read feedback from validation report
            # Fix identified issues
            # Re-execute phase

            ATTEMPT=$((ATTEMPT+1))
        fi
    done

    echo "[$(date -Iseconds)] [QUALITY-GATE] Phase $PHASE FAILED after $MAX_ATTEMPTS attempts" >> .claude/logs/autonomous.log
    return 1
}
```

### Grading System

| Grade | Score | Meaning | Decision |
|-------|-------|---------|----------|
| A | 90-100 | Excellent - exceeds standards | APPROVED |
| B | 80-89 | Good - meets all standards | APPROVED |
| C | 70-79 | Acceptable - meets minimum | APPROVED |
| D | 50-69 | Needs Work - below standards | REJECTED |
| F | 0-49 | Fail - significantly deficient | REJECTED |

**Quality Gate is MANDATORY. No phase proceeds without APPROVAL.**

---

## PHASE 1: INITIALIZE SPEC-KIT-PLUS

### Step 1.1: Initialize Project Structure

```bash
# Create Spec-Kit-Plus directories
mkdir -p .specify/{templates,scripts,contracts}
mkdir -p .claude/{skills,agents,hooks,logs,build-reports}

# Log start
echo "[$(date -Iseconds)] [INIT] Starting Spec-Kit-Plus autonomous build" >> .claude/logs/autonomous.log
echo "[$(date -Iseconds)] [INIT] Requirements file: $ARGUMENTS" >> .claude/logs/autonomous.log
```

### Step 1.2: Git Setup (if needed)

```bash
# Initialize git if not present
[ ! -d ".git" ] && git init

# Create feature branch from requirements
PROJECT_NAME=$(grep -m1 "^#" "$ARGUMENTS" | sed 's/^# *//' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
git checkout -b "feature/${PROJECT_NAME}" 2>/dev/null || echo "Branch exists, continuing"
```

### Step 1.3: QUALITY GATE - Phase 1 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 1**

The Quality Gate Teacher will evaluate:
- [20%] `.specify/` directory exists
- [20%] `.specify/templates/` exists
- [30%] `.claude/` structure complete (skills, agents, logs, build-reports)
- [15%] Git initialized
- [15%] Feature branch created (not on main/master)

```
╔════════════════════════════════════════════════════════════════╗
║           QUALITY GATE - PHASE 1 (INIT)                        ║
╠════════════════════════════════════════════════════════════════╣
║  Evaluating...                                                 ║
║                                                                ║
║  [✓] .specify/ created                    (+20)                ║
║  [✓] .specify/templates/ created          (+20)                ║
║  [✓] .claude/ structure complete          (+30)                ║
║  [✓] Git initialized                      (+15)                ║
║  [✓] Feature branch created               (+15)                ║
║                                                                ║
║  Score: 100/100                                                ║
║  Grade: A                                                      ║
║  Decision: APPROVED                                            ║
╚════════════════════════════════════════════════════════════════╝
```

**Output:** `.specify/validations/phase-1-report.md`

**→ Only proceed to Phase 2 after APPROVED (Grade A/B/C). If REJECTED, fix issues and retry.**

---

## PHASE 2: ANALYZE CURRENT PROJECT

### Step 2.1: Inventory Existing Infrastructure

**List what already exists:**

```bash
echo "=== EXISTING SKILLS ===" >> .claude/logs/autonomous.log
ls -la .claude/skills/ 2>/dev/null >> .claude/logs/autonomous.log

echo "=== EXISTING AGENTS ===" >> .claude/logs/autonomous.log
ls -la .claude/agents/ 2>/dev/null >> .claude/logs/autonomous.log

echo "=== EXISTING HOOKS ===" >> .claude/logs/autonomous.log
ls -la .claude/hooks/ 2>/dev/null >> .claude/logs/autonomous.log
```

**Record existing components:**

| Component Type | Location | Count |
|----------------|----------|-------|
| Skills | `.claude/skills/*/SKILL.md` | Count them |
| Agents | `.claude/agents/*.md` | Count them |
| Hooks | `.claude/hooks/*` | Count them |
| Commands | `.claude/commands/*.md` | Count them |

### Step 2.2: Analyze Project Type

Determine from existing files:
- Is there `package.json`? → Node.js project
- Is there `requirements.txt` or `pyproject.toml`? → Python project
- Is there `Cargo.toml`? → Rust project
- Is there `go.mod`? → Go project
- Is there `src/` directory? → Has source code
- Is there `tests/` or `__tests__/`? → Has tests

**Output**: Create `.specify/project-analysis.json`:

```json
{
  "project_type": "detected-type",
  "existing_skills": ["skill1", "skill2"],
  "existing_agents": ["agent1", "agent2"],
  "existing_hooks": ["hook1"],
  "has_source_code": true/false,
  "has_tests": true/false,
  "language": "typescript/python/etc"
}
```

### Step 2.3: QUALITY GATE - Phase 2 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 2**

The Quality Gate Teacher will evaluate:
- [20%] Valid JSON (parses without error)
- [20%] existing_skills listed (array with actual skills found)
- [20%] existing_agents listed (array with actual agents found)
- [20%] project_type detected (not empty/unknown)
- [20%] language detected (matches actual project)

**Output:** `.specify/validations/phase-2-report.md`

**→ Proceed to Phase 3 only after APPROVED.**

---

## PHASE 3: ANALYZE REQUIREMENTS FILE

### Step 3.1: Read Requirements

Read `$ARGUMENTS` and extract:

| Extract | Method |
|---------|--------|
| Project name | First `#` heading |
| Features | Items under "## Features" |
| Technologies | Keywords: React, Express, PostgreSQL, etc. |
| Constraints | Items under "## Constraints" |
| API endpoints | Code blocks with HTTP methods |

### Step 3.2: Technology Detection

Scan requirements for these keywords:

| Technology | Keywords |
|------------|----------|
| React/Next.js | "react", "next.js", "nextjs", "frontend", "component" |
| Express/Node | "express", "node", "nodejs", "backend api" |
| FastAPI | "fastapi", "python api", "uvicorn" |
| PostgreSQL | "postgresql", "postgres", "pg", "sql" |
| MongoDB | "mongodb", "mongo", "mongoose", "nosql" |
| Prisma | "prisma", "orm" |
| TypeScript | "typescript", "ts", ".tsx" |
| Docker | "docker", "container", "dockerfile" |
| Jest | "jest", "test", "testing" |
| Playwright | "playwright", "e2e", "end-to-end" |
| GraphQL | "graphql", "apollo", "query language" |
| Redis | "redis", "cache", "session store" |
| JWT | "jwt", "token", "authentication" |

**Output**: Create `.specify/requirements-analysis.json`:

```json
{
  "project_name": "extracted-name",
  "technologies_required": ["express", "postgresql", "prisma", "typescript", "jest"],
  "features": ["feature1", "feature2"],
  "constraints": ["constraint1"],
  "api_endpoints": ["/api/users", "/api/todos"]
}
```

### Step 3.3: QUALITY GATE - Phase 3 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 3**

The Quality Gate Teacher will evaluate:
- [15%] Valid JSON
- [15%] project_name extracted
- [25%] technologies_required populated (at least 1, better 3+)
- [25%] features extracted (at least 2)
- [20%] Cross-reference: detected techs match requirements file

**Output:** `.specify/validations/phase-3-report.md`

**→ Proceed to Phase 4 only after APPROVED.**

---

## PHASE 4: GAP ANALYSIS

### Step 4.1: Compare Required vs Existing

**INVOKE the `skill-gap-analyzer` skill NOW.**

For each required technology, check if corresponding skill exists:

| Required Tech | Required Skill | Exists? |
|---------------|----------------|---------|
| Express | `express-patterns` | Check `.claude/skills/express-patterns/` |
| PostgreSQL | `postgresql-patterns` | Check `.claude/skills/postgresql-patterns/` |
| Prisma | `prisma-patterns` | Check `.claude/skills/prisma-patterns/` |
| TypeScript | Already in `coding-standards` | ✓ |
| Jest | Already in `testing-patterns` | ✓ |

### Step 4.2: Identify Gaps

**Output**: Create `.specify/gap-analysis.json`:

```json
{
  "skills_existing": ["coding-standards", "testing-patterns", "api-patterns"],
  "skills_missing": ["express-patterns", "postgresql-patterns", "prisma-patterns"],
  "agents_existing": ["code-reviewer", "tdd-guide"],
  "agents_missing": ["api-builder", "schema-designer"],
  "hooks_missing": ["pre-commit.sh", "test-runner.sh"]
}
```

### Step 4.3: QUALITY GATE - Phase 4 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 4**

The Quality Gate Teacher will evaluate:
- [15%] Valid JSON
- [20%] skills_existing matches Phase 2 data (consistency)
- [25%] skills_missing identified based on technologies
- [20%] agents_missing identified based on project type
- [20%] Logical consistency: missing ∩ existing = ∅

**Output:** `.specify/validations/phase-4-report.md`

**→ Proceed to Phase 5 only after APPROVED.**

---

## PHASE 5: GENERATE MISSING COMPONENTS

### Step 5.1: Generate Missing Skills

For EACH skill in `skills_missing`, create `.claude/skills/{skill-name}/SKILL.md`:

**Skill Template:**

```markdown
---
name: {skill-name}
description: |
  Patterns and best practices for {technology} development.
  Triggers: {technology}, {related-keywords}
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

# {Technology} Patterns

## Overview
{Brief description of what this skill provides}

## Project Structure
```
{standard-directory-layout}
```

## Code Templates

### {Template 1: e.g., "Basic Setup"}
```{language}
{code template}
```

### {Template 2: e.g., "Common Pattern"}
```{language}
{code template}
```

## Best Practices
- {Practice 1}
- {Practice 2}
- {Practice 3}

## Common Commands
```bash
{useful commands for this technology}
```

## Anti-Patterns (Avoid)
- {Anti-pattern 1}
- {Anti-pattern 2}
```

### Step 5.2: Generate Missing Agents

For EACH agent in `agents_missing`, create `.claude/agents/{agent-name}.md`:

**Agent Template:**

```markdown
---
name: {agent-name}
description: {What this agent specializes in}
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# {Agent Name}

## Purpose
{Detailed description of agent's role}

## When to Use
- {Scenario 1}
- {Scenario 2}

## Workflow
1. {Step 1}
2. {Step 2}
3. {Step 3}

## Input Required
- {Input 1}
- {Input 2}

## Output Produced
- {Output 1}
- {Output 2}

## Quality Checks
- [ ] {Check 1}
- [ ] {Check 2}
```

### Step 5.3: Generate Missing Hooks

Create hooks in `.claude/hooks/`:

**pre-commit.sh:**
```bash
#!/bin/bash
# Pre-commit quality checks

set -e

echo "Running pre-commit checks..."

# Lint
npm run lint 2>/dev/null || echo "No linter configured"

# Type check
npm run typecheck 2>/dev/null || npx tsc --noEmit 2>/dev/null || echo "No type check"

# Check for debug statements
if grep -rn "console.log\|debugger" --include="*.ts" --include="*.tsx" src/ 2>/dev/null; then
    echo "Warning: Debug statements found"
fi

echo "Pre-commit checks complete"
```

**test-runner.sh:**
```bash
#!/bin/bash
# Test runner with coverage

npm test -- --coverage --coverageThreshold='{"global":{"lines":80}}'
```

### Step 5.4: QUALITY GATE - Phase 5 Validation (CRITICAL)

**THIS IS THE MOST IMPORTANT VALIDATION. Generated skills must be PRODUCTION READY.**

**MANDATORY: Invoke workflow-validator skill to grade Phase 5**

The Quality Gate Teacher will evaluate EACH generated skill:

| Criterion | Weight | Pass Condition |
|-----------|--------|----------------|
| Has valid frontmatter | 10% | name, description, version present |
| Has ## Overview section | 10% | Explains what skill does |
| Has ## Code Templates | 25% | At least 2 code examples |
| Code templates correct syntax | 15% | No syntax errors |
| Has ## Best Practices | 15% | At least 3 practices |
| Has ## Common Commands | 10% | If applicable |
| Has ## Anti-Patterns | 10% | At least 2 anti-patterns |
| Content is technology-specific | 5% | Not generic/placeholder |

**REJECTION TRIGGERS (automatic Grade F):**
- Contains TODO or PLACEHOLDER
- Generic content that doesn't mention the technology
- Missing code templates section
- Less than 50 lines

**Example Validation Output:**
```
╔════════════════════════════════════════════════════════════════╗
║           QUALITY GATE - PHASE 5 (GENERATE)                    ║
╠════════════════════════════════════════════════════════════════╣
║  Validating generated skills...                                ║
║                                                                ║
║  [1] express-patterns/SKILL.md                                 ║
║      [✓] Frontmatter valid              (+10)                  ║
║      [✓] Overview section               (+10)                  ║
║      [✓] Code Templates (3 examples)    (+25)                  ║
║      [✓] Correct syntax                 (+15)                  ║
║      [✓] Best Practices (5 items)       (+15)                  ║
║      [✓] Common Commands                (+10)                  ║
║      [✓] Anti-Patterns (3 items)        (+10)                  ║
║      [✓] Technology-specific content    (+5)                   ║
║      Score: 100/100 | Grade: A                                 ║
║                                                                ║
║  [2] postgresql-patterns/SKILL.md                              ║
║      [✓] Frontmatter valid              (+10)                  ║
║      [✓] Overview section               (+10)                  ║
║      [✓] Code Templates (2 examples)    (+25)                  ║
║      [✓] Correct syntax                 (+15)                  ║
║      [✗] Best Practices (2 items)       (+10)  -5 below min    ║
║      [✓] Common Commands                (+10)                  ║
║      [✓] Anti-Patterns (2 items)        (+10)                  ║
║      [✓] Technology-specific content    (+5)                   ║
║      Score: 95/100 | Grade: A                                  ║
║                                                                ║
║  OVERALL: Average Score 97.5/100 | Grade: A                    ║
║  Decision: APPROVED                                            ║
╚════════════════════════════════════════════════════════════════╝
```

**Output:** `.specify/validations/phase-5-report.md`

**→ Proceed to Phase 6 only after ALL generated skills are APPROVED. If any skill is REJECTED, fix that specific skill and retry.**

---

## PHASE 6: TEST GENERATED COMPONENTS

### Step 6.1: Validate Skills

For each generated skill:

```bash
# Check skill file exists and has content
if [ -f ".claude/skills/{skill-name}/SKILL.md" ]; then
    # Check it has required sections
    grep -q "## Code Templates" ".claude/skills/{skill-name}/SKILL.md" || echo "Missing templates"
    grep -q "## Best Practices" ".claude/skills/{skill-name}/SKILL.md" || echo "Missing practices"
    echo "✓ {skill-name} validated"
else
    echo "✗ {skill-name} missing!"
    exit 1
fi
```

### Step 6.2: Validate Agents

For each generated agent:

```bash
# Check agent file exists and has required frontmatter
if [ -f ".claude/agents/{agent-name}.md" ]; then
    grep -q "^name:" ".claude/agents/{agent-name}.md" || echo "Missing name"
    grep -q "^tools:" ".claude/agents/{agent-name}.md" || echo "Missing tools"
    echo "✓ {agent-name} validated"
else
    echo "✗ {agent-name} missing!"
    exit 1
fi
```

### Step 6.3: Test Hooks

```bash
# Make hooks executable
chmod +x .claude/hooks/*.sh 2>/dev/null

# Syntax check bash scripts
for hook in .claude/hooks/*.sh; do
    bash -n "$hook" && echo "✓ $hook syntax OK" || echo "✗ $hook syntax error"
done
```

### Step 6.4: QUALITY GATE - Phase 6 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 6**

The Quality Gate Teacher will evaluate:
- [35%] All generated skills validated (required sections present)
- [35%] All generated agents validated (frontmatter, workflow defined)
- [30%] All hooks syntax-checked (bash -n passes)

**Output:** `.specify/validations/phase-6-report.md`

**→ Proceed to Phase 7 only after APPROVED.**

---

## PHASE 7: CONSTITUTION

Create `.specify/constitution.md` - the project's ground rules:

```markdown
# ${PROJECT_NAME} Constitution

## Core Principles
1. **Test-First Development**: Write tests before implementation
2. **Immutability**: Never mutate state directly
3. **Type Safety**: Full TypeScript strict mode
4. **Security First**: Validate all inputs, sanitize outputs

## Code Standards
- Maximum file size: 400 lines (800 absolute max)
- Test coverage minimum: 80%
- No console.log in production code
- All functions must have return types

## Technology Decisions
- Backend: ${BACKEND_TECH}
- Database: ${DATABASE_TECH}
- Testing: ${TEST_FRAMEWORK}

## Quality Gates
- [ ] All tests pass
- [ ] Coverage >= 80%
- [ ] No TypeScript errors
- [ ] No linting errors
- [ ] Security review passed

## Out of Scope
${OUT_OF_SCOPE_ITEMS}
```

### Step 7.2: QUALITY GATE - Phase 7 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 7**

The Quality Gate Teacher will evaluate:
- [15%] File exists and >100 lines
- [20%] Has ## Core Principles (at least 3)
- [20%] Has ## Code Standards (specific rules)
- [15%] Has ## Technology Decisions (matches detected tech)
- [15%] Has ## Quality Gates (measurable criteria)
- [15%] Has ## Out of Scope (boundaries defined)

**Output:** `.specify/validations/phase-7-report.md`

**→ Proceed to Phase 8 only after APPROVED.**

---

## PHASE 8: SPECIFICATION

Generate `.specify/spec.md` using template from `.specify/templates/spec.md`:

**Must include:**
- User stories with acceptance criteria
- Functional requirements (from features)
- Non-functional requirements (performance, security)
- API contracts (if applicable)
- Data models

### Step 8.2: QUALITY GATE - Phase 8 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 8**

The Quality Gate Teacher will evaluate:
- [10%] File exists and >300 lines
- [20%] Has ## User Stories (at least 3)
- [15%] User stories have acceptance criteria
- [20%] Has ## Functional Requirements
- [15%] Has ## Non-Functional Requirements
- [10%] Has ## API Contracts (if API project)
- [10%] Has ## Data Models

**Output:** `.specify/validations/phase-8-report.md`

**→ Proceed to Phase 9 only after APPROVED.**

---

## PHASE 9: PLAN

Generate `.specify/plan.md` using template from `.specify/templates/plan.md`:

**Must include:**
- Architecture overview with diagram
- Component breakdown
- API contracts with request/response schemas
- Data model with entity relationships
- Implementation phases
- Dependencies
- Risks and mitigations

**Also generate** `.specify/data-model.md`:
- All entities
- Relationships
- Database schema SQL

### Step 9.2: QUALITY GATE - Phase 9 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 9**

The Quality Gate Teacher will evaluate:
- [15%] plan.md exists and >200 lines
- [15%] Has architecture diagram
- [20%] Has ## Components breakdown
- [20%] Has ## Implementation Phases
- [15%] Has ## Risks and Mitigations
- [15%] data-model.md exists with schema

**Output:** `.specify/validations/phase-9-report.md`

**→ Proceed to Phase 10 only after APPROVED.**

---

## PHASE 10: TASKS

Generate `.specify/tasks.md` using template from `.specify/templates/tasks.md`:

**Task format:**
```markdown
- [ ] T-XXX: Task description
  - Skill: skill-to-use
  - Depends: T-YYY (if any)
  - Priority: P0/P1/P2
```

**Must include:**
- Setup tasks (P0)
- Core implementation tasks (P0)
- Testing tasks (P1)
- Documentation tasks (P2)

**Each task must reference which skill to use.**

### Step 10.2: QUALITY GATE - Phase 10 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 10**

The Quality Gate Teacher will evaluate:
- [10%] File exists
- [20%] At least 10 tasks defined
- [20%] Each task has skill reference (Skill: field)
- [15%] Tasks have dependencies (Depends: field where needed)
- [15%] Tasks have priorities (P0/P1/P2)
- [20%] Tasks cover all features from spec (cross-reference)

**Output:** `.specify/validations/phase-10-report.md`

**→ Proceed to Phase 11 only after APPROVED.**

---

## PHASE 11: IMPLEMENT

For each task in `.specify/tasks.md` (in dependency order):

### Step 11.1: Select Task
Read next incomplete task from tasks.md

### Step 11.2: Load Skill
Invoke the skill specified in the task

### Step 11.3: TDD Cycle
1. **RED**: Write failing test first
2. **GREEN**: Write minimal code to pass
3. **REFACTOR**: Clean up, maintain coverage

### Step 11.4: Verify
- Run tests for this component
- Check coverage >= 80%
- Run linter

### Step 11.5: Mark Complete
Change `- [ ]` to `- [X]` in tasks.md

### Step 11.6: Log Progress
```bash
echo "[$(date -Iseconds)] [IMPLEMENT] Completed: T-XXX - {description}" >> .claude/logs/autonomous.log
```

**Repeat for all tasks.**

### Step 11.7: QUALITY GATE - Phase 11 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 11**

The Quality Gate Teacher will evaluate:
- [20%] Source files created
- [25%] Tests written (test files exist)
- [20%] Tests pass (npm test succeeds)
- [20%] Coverage >= 80%
- [15%] No linting errors

**Output:** `.specify/validations/phase-11-report.md`

**→ Proceed to Phase 12 only after APPROVED.**

---

## PHASE 12: QUALITY ASSURANCE

### Step 12.1: Code Review
Invoke `code-reviewer` agent on all new/modified files

### Step 12.2: Security Review
Invoke `security-reviewer` agent

### Step 12.3: Test Suite
```bash
npm test -- --coverage
```
Must pass with 80%+ coverage.

### Step 12.4: Build
```bash
npm run build
```
Must complete without errors.

### Step 12.5: QUALITY GATE - Phase 12 Validation

**MANDATORY: Invoke workflow-validator skill to grade Phase 12**

The Quality Gate Teacher will evaluate:
- [25%] Code review completed (review report exists)
- [25%] Security review completed (security report exists)
- [25%] All tests pass
- [25%] Build succeeds (npm run build passes)

If any check fails:
1. Read feedback from validation report
2. Fix using appropriate skill/agent
3. Re-run the check
4. Max 3 retries per issue

**Output:** `.specify/validations/phase-12-report.md`

**→ Proceed to Phase 13 only after APPROVED.**

---

## PHASE 13: DELIVER

### Step 13.1: Final Commit

```bash
git add -A
git commit -m "feat(${PROJECT_NAME}): complete autonomous build

- Generated ${SKILL_COUNT} custom skills
- Generated ${AGENT_COUNT} project agents
- Implemented all ${TASK_COUNT} tasks
- Test coverage: ${COVERAGE}%

Spec-Kit-Plus workflow complete.

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 13.2: Generate Report

Create `.claude/build-reports/report-$(date +%Y%m%d-%H%M%S).md`:

```markdown
# Autonomous Build Report

## Project: ${PROJECT_NAME}
## Date: ${TIMESTAMP}
## Status: SUCCESS

## Infrastructure Generated

### Skills Created
| Skill | Purpose |
|-------|---------|
| ${SKILL_1} | ${PURPOSE_1} |

### Agents Created
| Agent | Purpose |
|-------|---------|
| ${AGENT_1} | ${PURPOSE_1} |

### Hooks Created
- pre-commit.sh
- test-runner.sh

## Implementation Summary

### Tasks Completed
- Total: ${TOTAL}
- Completed: ${COMPLETED}
- Skipped: ${SKIPPED}

### Test Coverage
- Lines: ${LINE_COV}%
- Branches: ${BRANCH_COV}%
- Functions: ${FUNC_COV}%

### Files Created
${FILE_LIST}

## Quality Gates
- [X] All tests passing
- [X] Coverage >= 80%
- [X] No build errors
- [X] Code review passed
- [X] Security review passed
```

### Step 13.3: Signal Completion

```
<promise>AUTONOMOUS_BUILD_COMPLETE</promise>
```

---

## ERROR RECOVERY

If any phase fails after 3 retries:

1. Log the failure:
```bash
echo "[$(date -Iseconds)] [ERROR] Phase ${PHASE} failed: ${REASON}" >> .claude/logs/autonomous.log
```

2. Create failure report:
```markdown
# Build Failure Report

## Failed Phase: ${PHASE}
## Error: ${ERROR_MESSAGE}
## Attempted Fixes: ${FIXES_TRIED}
## Manual Action Required: ${SUGGESTIONS}
```

3. Signal failure:
```
<promise>AUTONOMOUS_BUILD_FAILED</promise>
```

---

## AUTOMATIC ENFORCEMENT - QUALITY GATE TEACHER (NO HUMAN INTERVENTION)

This workflow is **self-enforcing** with **Quality Gate Teacher** validation. The validator acts as a strict teacher who evaluates QUALITY, not just existence.

### Enforcement Points

| When | What Happens | Automatic Action |
|------|--------------|------------------|
| **Start** | Phase 0 runs | Checks state, reviews previous grades |
| **After each phase** | Quality Gate validates | Grades work (A/B/C/D/F) |
| **Grade A/B/C** | APPROVED | Proceeds to next phase |
| **Grade D/F** | REJECTED | Reviews feedback, fixes, retries (max 3x) |
| **3 failures** | STOP | Creates detailed failure report |
| **Violation detected** | Missing phase | Executes skipped phase first |

### The Quality Gate Loop

```
┌─────────────────────────────────────────────────────────────┐
│              QUALITY GATE TEACHER VALIDATION LOOP            │
│                                                             │
│   Execute Phase N                                           │
│        ↓                                                    │
│   [INVOKE] workflow-validator skill                         │
│        ↓                                                    │
│   Validator evaluates QUALITY:                              │
│   - Reads artifacts                                         │
│   - Scores against criteria                                 │
│   - Generates validation report                             │
│        ↓                                                    │
│   ┌─── GRADE? ───┐                                          │
│   │              │                                          │
│   A/B/C          D/F                                        │
│   (APPROVED)     (REJECTED)                                 │
│   ↓              ↓                                          │
│   Proceed     Read feedback from report                     │
│   to N+1      Fix specific issues identified                │
│               Re-execute phase                              │
│                  ↓                                          │
│              ┌─── Approved? ───┐                            │
│              │                 │                            │
│              YES               NO (after 3 tries)           │
│              ↓                 ↓                            │
│           Proceed           Log failure                     │
│           to N+1            Create failure report           │
│                             STOP                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Phase Quality Criteria (What the Teacher Checks)

| Phase | What's Graded | Key Quality Criteria |
|-------|---------------|----------------------|
| 1 | Project Structure | All directories created, git initialized |
| 2 | Project Analysis | Valid JSON, skills/agents detected, language identified |
| 3 | Requirements Analysis | Technologies extracted, features identified |
| 4 | Gap Analysis | Missing skills identified, logical consistency |
| 5 | **Generated Skills** | **Frontmatter, sections, code templates, no placeholders** |
| 6 | Component Tests | Skills validated, agents checked, hooks syntax OK |
| 7 | Constitution | Principles, standards, tech decisions, gates defined |
| 8 | Specification | User stories with criteria, FR/NFR, API contracts |
| 9 | Plan | Architecture diagram, phases, risks, data model |
| 10 | Tasks | 10+ tasks, skill references, dependencies, priorities |
| 11 | Implementation | Code exists, tests pass, coverage >= 80% |
| 12 | QA | Code review, security review, build passes |
| 13 | Delivery | Commit made, final report generated |

### Validation Report Location

After each phase, the Quality Gate Teacher generates:
```
.specify/validations/phase-{N}-report.md
```

Each report contains:
- Grade and score
- Criteria evaluation table
- Specific issues found
- Positive feedback
- Required fixes (if rejected)
- Decision: APPROVED or REJECTED

### Resume Capability

When `/sp.autonomous` is called and work already exists:

1. **Phase 0 detects** current state via artifact check
2. **Reads previous validation reports** in `.specify/validations/`
3. **Skips APPROVED phases** - no redundant work
4. **Resumes from next phase** - continues where left off
5. **Logs resume action** - audit trail maintained

```
Example: Project has phases 1-4 APPROVED

╔════════════════════════════════════════════════════════════════╗
║  PRE-CHECK RESULT                                              ║
║                                                                ║
║  Phase 1: INIT        → Grade A (APPROVED)                     ║
║  Phase 2: ANALYZE     → Grade B (APPROVED)                     ║
║  Phase 3: REQS        → Grade A (APPROVED)                     ║
║  Phase 4: GAP         → Grade B (APPROVED)                     ║
║  Phase 5: GENERATE    → Not started                            ║
║                                                                ║
║  Action: RESUMING from Phase 5 (GENERATE)                      ║
╚════════════════════════════════════════════════════════════════╝
```

### Why This Works Without Human Intervention

1. **Quality is measured**: Not just "does file exist" but "is it GOOD"
2. **Grading is objective**: Weighted criteria, consistent scoring
3. **Feedback is specific**: Validator tells exactly what's wrong
4. **Self-healing uses feedback**: Reads report, fixes identified issues
5. **Progress is tracked**: Validation reports show audit trail
6. **Resume is smart**: Reads previous grades, skips approved work

**The human only needs to run ONE command:**
```bash
claude "/sp.autonomous requirements/my-app.md"
```

The Quality Gate Teacher handles everything else:
- Validates quality at every step
- Rejects poor work with specific feedback
- Approves good work and proceeds
- Creates detailed validation reports
