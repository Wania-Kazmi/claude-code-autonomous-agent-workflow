---
description: Fully autonomous project builder - analyzes current project, generates missing skills/agents/hooks, tests them, then builds using Spec-Kit-Plus workflow. Supports both simple and complex multi-feature projects.
---

# /sp.autonomous

**Input**: `$ARGUMENTS` (path to requirements file)

---

## AUTONOMOUS MODE - FULL SPEC-KIT-PLUS WORKFLOW

This command executes the complete Spec-Kit-Plus workflow with support for **complex multi-feature projects**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SPEC-KIT-PLUS WORKFLOW v2.0                              │
│                                                                             │
│   ╔═══════════════════════════════════════════════════════════════════╗    │
│   ║            PROJECT LEVEL (ONE TIME)                               ║    │
│   ╟───────────────────────────────────────────────────────────────────╢    │
│   ║  INIT → ANALYZE → GAP → GENERATE → TEST → CONSTITUTION            ║    │
│   ║                                          ↓                        ║    │
│   ║                              FEATURE BREAKDOWN                     ║    │
│   ╚═══════════════════════════════════════════════════════════════════╝    │
│                                      │                                      │
│               ┌──────────────────────┼──────────────────────┐              │
│               ▼                      ▼                      ▼              │
│   ╔═════════════════════╗ ╔═════════════════════╗ ╔═════════════════════╗  │
│   ║     FEATURE 1       ║ ║     FEATURE 2       ║ ║     FEATURE N       ║  │
│   ╟─────────────────────╢ ╟─────────────────────╢ ╟─────────────────────╢  │
│   ║  Spec → Plan        ║ ║  Spec → Plan        ║ ║  Spec → Plan        ║  │
│   ║  Tasks → Implement  ║ ║  Tasks → Implement  ║ ║  Tasks → Implement  ║  │
│   ║  Feature QA         ║ ║  Feature QA         ║ ║  Feature QA         ║  │
│   ╚═════════════════════╝ ╚═════════════════════╝ ╚═════════════════════╝  │
│                                      │                                      │
│                              ┌───────┴───────┐                              │
│                              ▼               ▼                              │
│   ╔═══════════════════════════════════════════════════════════════════╗    │
│   ║                    INTEGRATION (ONE TIME)                          ║    │
│   ╟───────────────────────────────────────────────────────────────────╢    │
│   ║  Integration QA → Final Commit → Build Report → DELIVER            ║    │
│   ╚═══════════════════════════════════════════════════════════════════╝    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**DO NOT SKIP ANY PHASE. Each phase has automatic validation.**

---

## PROJECT COMPLEXITY DETECTION

After Phase 3 (Requirements Analysis), determine project complexity:

```python
def determine_complexity(requirements_analysis):
    """Determine if project is SIMPLE or COMPLEX based on features."""

    features = requirements_analysis.get("features", [])

    # Complexity factors
    feature_count = len(features)
    has_auth = any("auth" in f.lower() for f in features)
    has_multiple_domains = len(set(get_domain(f) for f in features)) > 2

    # COMPLEX if:
    # - More than 3 features
    # - Has authentication + other features
    # - Features span multiple domains (users, products, orders, etc.)

    if feature_count > 3 or (has_auth and feature_count > 2) or has_multiple_domains:
        return "COMPLEX"
    else:
        return "SIMPLE"
```

**SIMPLE Project Flow:**
```
Constitution → Spec → Plan → Tasks → Implement → QA → Deliver
```

**COMPLEX Project Flow:**
```
Constitution → Feature Breakdown → [Feature 1: Spec→Plan→Tasks→Implement→QA]
                                 → [Feature 2: Spec→Plan→Tasks→Implement→QA]
                                 → [Feature N: ...]
                                 → Integration QA → Deliver
```

---

## PHASE 0: PRE-CHECK (ALWAYS RUNS)

> **Detects current state, determines complexity, decides whether to start fresh or resume.**

### Step 0.1: Invoke Workflow Validator

```bash
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              SPEC-KIT-PLUS PRE-CHECK v2.0                      ║"
echo "╠════════════════════════════════════════════════════════════════╣"
```

### Step 0.2: Detect Current Phase

Check artifacts to determine current phase:

```bash
CURRENT_PHASE=0
PROJECT_TYPE="unknown"

# Project-level phases
[ -d ".specify" ] && [ -d ".claude" ] && CURRENT_PHASE=1
[ -f ".specify/project-analysis.json" ] && CURRENT_PHASE=2
[ -f ".specify/requirements-analysis.json" ] && CURRENT_PHASE=3
[ -f ".specify/gap-analysis.json" ] && CURRENT_PHASE=4
[ "$(find .claude/skills -name 'SKILL.md' 2>/dev/null | wc -l)" -gt 9 ] && CURRENT_PHASE=5
[ -f ".specify/constitution.md" ] && CURRENT_PHASE=7

# Check for feature breakdown (COMPLEX project indicator)
if [ -f ".specify/feature-breakdown.json" ]; then
    PROJECT_TYPE="COMPLEX"
    CURRENT_PHASE=8  # In feature implementation
else
    [ -f ".specify/spec.md" ] && CURRENT_PHASE=8
    [ -f ".specify/plan.md" ] && CURRENT_PHASE=9
    [ -f ".specify/tasks.md" ] && CURRENT_PHASE=10
fi
```

### Step 0.3: Resume or Start Fresh

**→ Continue to appropriate phase based on state.**

---

## PHASES 1-7: PROJECT LEVEL (ONE TIME)

> These phases establish the foundation. They run **ONCE** regardless of project complexity.

### Phase 1-5: Foundation Phases
(INIT, ANALYZE PROJECT, ANALYZE REQUIREMENTS, GAP-ANALYSIS, GENERATE)

### Phase 6: COMPONENT TESTING (Functional Validation)

Validate that generated components execute without errors.

### Phase 6.5: COMPONENT QUALITY VALIDATION (NEW - Production Readiness)

> **WHO validates? The component-quality-validator skill.**
> **HOW? Automated quality criteria scoring.**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PHASE 6.5: COMPONENT QUALITY VALIDATION                   │
│                                                                             │
│  FOR EACH generated component (skill, agent, hook):                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  1. VALIDATE structure (frontmatter, sections, syntax)                  ││
│  │  2. SCORE against quality criteria (0-100)                              ││
│  │  3. GRADE: A (90+), B (80-89), C (70-79), D (60-69), F (<60)           ││
│  │  4. DECISION:                                                           ││
│  │     - A/B/C: APPROVED → Continue                                        ││
│  │     - D/F: REJECTED → Regenerate (max 3 attempts)                       ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  OUTPUT: .specify/component-validation-report.json                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Quality Criteria by Component Type:**

| Component | Key Criteria |
|-----------|--------------|
| **Skill** | Triggers in description, code templates valid, has workflow, has validation checklist |
| **Agent** | Model appropriate for task, tools minimal, has failure handling, unambiguous instructions |
| **Hook** | Valid JSON, valid bash syntax, has description, no conflicts |

**Regeneration Protocol:**
- Attempt 1: Apply specific fixes from validation report
- Attempt 2: Simplify scope, focus on core functionality
- Attempt 3: Use template from similar working component
- Attempt 4+: Mark as MANUAL_REQUIRED, continue with others

**Validation Report Format:**
```json
{
  "phase": "6.5",
  "components_validated": 5,
  "results": [
    {
      "type": "skill",
      "name": "express-patterns",
      "score": 85,
      "grade": "B",
      "decision": "APPROVED",
      "warnings": ["Missing validation section"],
      "suggestions": ["Add ## Validation section"]
    }
  ],
  "summary": {
    "approved": 4,
    "rejected": 1,
    "regeneration_required": true
  }
}
```

### Phase 7: CONSTITUTION (Project Ground Rules)

Create `.specify/constitution.md` - applies to **ALL features**:

```markdown
# ${PROJECT_NAME} Constitution

> Ground rules and principles for the ENTIRE project.
> All features must follow these standards.

## Core Principles
1. **Test-First Development**: Write tests before implementation
2. **Immutability**: Never mutate state directly
3. **Type Safety**: Full TypeScript strict mode
4. **Security First**: Validate all inputs

## Code Standards
- Maximum file size: 400 lines
- Test coverage minimum: 80%
- No console.log in production

## Technology Decisions
- Backend: ${BACKEND}
- Database: ${DATABASE}
- Testing: ${TEST_FRAMEWORK}

## Quality Gates (Every Feature)
- [ ] All tests pass
- [ ] Coverage >= 80%
- [ ] No TypeScript errors
- [ ] Security review passed

## Feature Integration Rules
- Each feature must have own spec, plan, tasks
- Features must not break existing features
- Integration tests required when features interact
```

**→ After Phase 7, check complexity to decide next phase.**

---

## PHASE 7.5: FEATURE BREAKDOWN (COMPLEX PROJECTS ONLY)

> **This phase ONLY runs for COMPLEX projects.**

### Step 7.5.1: Analyze Features

Read requirements and break into discrete, implementable features:

```python
def breakdown_features(requirements_analysis):
    """Break project into discrete features for iterative implementation."""

    features = requirements_analysis.get("features", [])

    feature_specs = []
    for i, feature in enumerate(features, 1):
        feature_specs.append({
            "id": f"F-{i:02d}",
            "name": feature,
            "status": "pending",
            "dependencies": [],  # Will be filled
            "priority": determine_priority(feature)
        })

    # Determine dependencies
    # Auth features should come first
    # CRUD on entities depends on entity creation
    # Reports depend on data being present

    return sort_by_dependencies(feature_specs)
```

### Step 7.5.2: Generate Feature Breakdown

Create `.specify/feature-breakdown.json`:

```json
{
  "project_type": "COMPLEX",
  "total_features": 5,
  "features": [
    {
      "id": "F-01",
      "name": "User Authentication",
      "status": "pending",
      "dependencies": [],
      "priority": "P0",
      "directory": ".specify/features/F-01-auth"
    },
    {
      "id": "F-02",
      "name": "Todo CRUD Operations",
      "status": "pending",
      "dependencies": ["F-01"],
      "priority": "P0",
      "directory": ".specify/features/F-02-todos"
    },
    {
      "id": "F-03",
      "name": "Category Management",
      "status": "pending",
      "dependencies": ["F-01"],
      "priority": "P1",
      "directory": ".specify/features/F-03-categories"
    },
    {
      "id": "F-04",
      "name": "Todo Filtering & Search",
      "status": "pending",
      "dependencies": ["F-02"],
      "priority": "P1",
      "directory": ".specify/features/F-04-filtering"
    },
    {
      "id": "F-05",
      "name": "Reports & Analytics",
      "status": "pending",
      "dependencies": ["F-02", "F-03"],
      "priority": "P2",
      "directory": ".specify/features/F-05-reports"
    }
  ],
  "current_feature": null,
  "completed_features": []
}
```

### Step 7.5.3: Create Feature Directories

```bash
mkdir -p .specify/features/F-01-auth
mkdir -p .specify/features/F-02-todos
# ... for each feature
```

### Quality Gate - Phase 7.5

Validate:
- [25%] feature-breakdown.json exists and valid
- [25%] All features have ID, name, priority
- [25%] Dependencies are logical (no circular deps)
- [25%] Feature directories created

**→ Proceed to Feature Iteration Loop.**

---

## PHASE 8-11: FEATURE ITERATION LOOP (COMPLEX PROJECTS)

> For COMPLEX projects, phases 8-11 run **FOR EACH FEATURE** in dependency order.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FEATURE ITERATION LOOP                                   │
│                                                                             │
│  for each FEATURE in feature-breakdown.json (sorted by dependencies):       │
│                                                                             │
│    ┌─────────────────────────────────────────────────────────────────┐     │
│    │  Feature: ${FEATURE_ID} - ${FEATURE_NAME}                       │     │
│    │                                                                 │     │
│    │  Phase 8: FEATURE SPEC                                          │     │
│    │    → .specify/features/${FEATURE_ID}/spec.md                    │     │
│    │    → Quality Gate: Grade must be C or higher                    │     │
│    │                                                                 │     │
│    │  Phase 9: FEATURE PLAN                                          │     │
│    │    → .specify/features/${FEATURE_ID}/plan.md                    │     │
│    │    → Quality Gate: Grade must be C or higher                    │     │
│    │                                                                 │     │
│    │  Phase 10: FEATURE TASKS                                        │     │
│    │    → .specify/features/${FEATURE_ID}/tasks.md                   │     │
│    │    → Quality Gate: Grade must be C or higher                    │     │
│    │                                                                 │     │
│    │  Phase 11: FEATURE IMPLEMENT                                    │     │
│    │    → Execute tasks in dependency order                          │     │
│    │    → TDD cycle: RED → GREEN → REFACTOR                          │     │
│    │    → Quality Gate: Tests pass, coverage >= 80%                  │     │
│    │                                                                 │     │
│    │  Phase 11.5: FEATURE QA                                         │     │
│    │    → Code review for this feature                               │     │
│    │    → Security review if auth-related                            │     │
│    │    → Feature-level tests pass                                   │     │
│    │    → Quality Gate: All checks pass                              │     │
│    │                                                                 │     │
│    │  Phase 11.6: INTER-FEATURE UNIT TESTING (if Feature >= 2)       │     │
│    │    → Run ALL unit tests from Feature 1 to current               │     │
│    │    → Verify no regressions (previous features still work)       │     │
│    │    → Check combined coverage >= 80%                             │     │
│    │    → Quality Gate: All features' tests pass together            │     │
│    │                                                                 │     │
│    │  Mark feature COMPLETE in feature-breakdown.json                │     │
│    └─────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  end for                                                                    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  FINAL: INTEGRATION QA (Phase 12)                                   │   │
│  │    → Full unit test suite across ALL features                       │   │
│  │    → Integration tests (cross-feature flows)                        │   │
│  │    → E2E tests (critical user journeys)                             │   │
│  │    → Regression verification                                        │   │
│  │    → Security audit                                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Feature Spec (Phase 8 per feature)

Create `.specify/features/${FEATURE_ID}/spec.md`:

```markdown
# Feature Spec: ${FEATURE_NAME}

**Feature ID**: ${FEATURE_ID}
**Dependencies**: ${DEPENDENCIES}
**Priority**: ${PRIORITY}

## User Stories

### US-${FEATURE_ID}-001: ${Story Title}
As a ${user}, I want to ${action} so that ${benefit}.

**Acceptance Criteria:**
- [ ] ${Criterion 1}
- [ ] ${Criterion 2}

## Functional Requirements

### FR-${FEATURE_ID}-001: ${Requirement}
${Description}

## API Endpoints (if applicable)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/${resource} | Create ${resource} |
| GET | /api/${resource} | List ${resources} |

## Data Model (if new entities)

${Entity definitions}
```

### Feature Plan (Phase 9 per feature)

Create `.specify/features/${FEATURE_ID}/plan.md`:

```markdown
# Feature Plan: ${FEATURE_NAME}

## Architecture Impact

${How this feature fits into overall architecture}

## Implementation Approach

### Component 1: ${Name}
${Description}

### Component 2: ${Name}
${Description}

## Integration Points

- Depends on: ${Dependencies}
- Will be used by: ${Dependents}

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| ${Risk 1} | ${Mitigation} |
```

### Feature Tasks (Phase 10 per feature)

Create `.specify/features/${FEATURE_ID}/tasks.md`:

```markdown
# Feature Tasks: ${FEATURE_NAME}

## Task List

- [ ] T-${FEATURE_ID}-001: Set up ${component}
  - Skill: ${skill-to-use}
  - Priority: P0

- [ ] T-${FEATURE_ID}-002: Write tests for ${component}
  - Skill: testing-patterns
  - Priority: P0
  - Note: TDD - write BEFORE implementation

- [ ] T-${FEATURE_ID}-003: Implement ${component}
  - Skill: ${skill-to-use}
  - Depends: T-${FEATURE_ID}-002
  - Priority: P0
```

### Feature Implementation (Phase 11 per feature)

Execute tasks with TDD:
1. Load skill for task
2. Write failing test (RED)
3. Implement to pass (GREEN)
4. Refactor (IMPROVE)
5. Mark task complete

### Feature QA (Phase 11.5 per feature)

Run quality checks for THIS feature only:
- Code review
- Security review (if auth-related)
- Tests pass
- Coverage check (80%+ for this feature)

### INTER-FEATURE UNIT TESTING (Phase 11.6 - MANDATORY when 2+ features exist)

> **CRITICAL: After completing Feature 2 and beyond, run unit tests to verify feature boundaries.**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              INTER-FEATURE UNIT TESTING (After Feature N, N >= 2)           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. RUN ALL UNIT TESTS                                                      │
│     npm test -- --testPathPattern="unit"                                    │
│     → All unit tests from Feature 1 to Feature N must pass                  │
│                                                                             │
│  2. CHECK NO REGRESSIONS                                                    │
│     → Feature N did NOT break Feature 1..N-1                                │
│     → All previous feature tests still pass                                 │
│                                                                             │
│  3. VERIFY FEATURE ISOLATION                                                │
│     → Each feature's tests are independent                                  │
│     → No test depends on another feature's implementation details           │
│                                                                             │
│  4. CHECK SHARED DEPENDENCIES                                               │
│     → Verify mocks are consistent across features                           │
│     → Shared utilities work for all features                                │
│                                                                             │
│  5. COVERAGE CHECK                                                          │
│     npm test -- --coverage                                                  │
│     → Combined coverage must remain >= 80%                                  │
│     → No feature drops below 80% individual coverage                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Inter-Feature Test Report** (`.specify/features/${FEATURE_ID}/inter-feature-test-report.md`):

```markdown
# Inter-Feature Unit Test Report

**After Feature**: ${FEATURE_ID} - ${FEATURE_NAME}
**Completed Features**: ${COMPLETED_FEATURES}
**Timestamp**: ${TIMESTAMP}

## Unit Test Results

| Feature | Tests | Passed | Failed | Coverage |
|---------|-------|--------|--------|----------|
| F-01    | 25    | 25     | 0      | 92%      |
| F-02    | 30    | 30     | 0      | 88%      |
| F-03    | 20    | 20     | 0      | 85%      |
| **Total** | **75** | **75** | **0** | **88%** |

## Regression Check
- [x] F-01 tests still pass after F-02
- [x] F-01, F-02 tests still pass after F-03

## Feature Isolation
- [x] No cross-feature test dependencies
- [x] Mocks are properly isolated

## Status: PASS / FAIL
```

**Quality Gate - Inter-Feature Testing:**
- [30%] All unit tests pass (100% pass rate)
- [25%] No regressions (previous features' tests still pass)
- [25%] Coverage >= 80% combined
- [20%] Feature isolation verified (no cross-dependencies)

**If FAIL:** Fix failing tests before proceeding to next feature.

### Update Feature Status

After feature QA passes:

```json
{
  "features": [
    {
      "id": "F-01",
      "name": "User Authentication",
      "status": "complete",  // ← Updated
      "completed_at": "2025-01-20T..."
    }
  ],
  "current_feature": "F-02",  // ← Next feature
  "completed_features": ["F-01"]  // ← Tracking
}
```

**→ Loop continues until all features complete.**

---

## PHASE 8-11: SIMPLE PROJECT (Original Flow)

> For SIMPLE projects, run phases 8-11 once for entire project.

- Phase 8: `.specify/spec.md` (entire project)
- Phase 9: `.specify/plan.md` (entire project)
- Phase 10: `.specify/tasks.md` (entire project)
- Phase 11: Implement all tasks

(Same as original workflow)

---

## PHASE 12: INTEGRATION QA (All Projects)

> **This phase runs AFTER all features are complete. It verifies the system works as a whole.**

### For COMPLEX Projects (2+ Features)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INTEGRATION TESTING PROTOCOL                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  STEP 1: FULL UNIT TEST SUITE                                               │
│  ───────────────────────────────────────────────────────────────────────────│
│  npm test -- --testPathPattern="unit" --coverage                           │
│                                                                             │
│  Requirements:                                                              │
│  - ALL unit tests pass (100% pass rate)                                     │
│  - Combined coverage >= 80%                                                 │
│  - Each feature maintains >= 80% coverage                                   │
│                                                                             │
│  STEP 2: INTEGRATION TESTS                                                  │
│  ───────────────────────────────────────────────────────────────────────────│
│  npm test -- --testPathPattern="integration"                               │
│                                                                             │
│  Test scenarios:                                                            │
│  - Cross-feature API flows (e.g., auth → create todo → assign category)    │
│  - Shared state management                                                  │
│  - Database transactions spanning features                                  │
│  - Error propagation across feature boundaries                              │
│                                                                             │
│  STEP 3: END-TO-END TESTS (If Applicable)                                   │
│  ───────────────────────────────────────────────────────────────────────────│
│  npm run test:e2e                                                          │
│                                                                             │
│  Test critical user journeys:                                               │
│  - Complete user registration → login → use feature → logout               │
│  - Full CRUD cycles                                                         │
│  - Error recovery flows                                                     │
│                                                                             │
│  STEP 4: REGRESSION VERIFICATION                                            │
│  ───────────────────────────────────────────────────────────────────────────│
│  - Verify no feature broke another                                          │
│  - Check all API contracts still valid                                      │
│  - Confirm database migrations work together                                │
│                                                                             │
│  STEP 5: PERFORMANCE CHECK (Optional)                                       │
│  ───────────────────────────────────────────────────────────────────────────│
│  - Response times < 200ms                                                   │
│  - No memory leaks                                                          │
│  - Database queries optimized                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Integration Test Report** (`.specify/integration-test-report.md`):

```markdown
# Integration Test Report

**Project**: ${PROJECT_NAME}
**Features Tested**: ${FEATURE_COUNT}
**Timestamp**: ${TIMESTAMP}

## Test Summary

| Test Type | Total | Passed | Failed | Skipped |
|-----------|-------|--------|--------|---------|
| Unit      | 150   | 150    | 0      | 0       |
| Integration | 25  | 25     | 0      | 0       |
| E2E       | 10    | 10     | 0      | 0       |
| **Total** | **185** | **185** | **0** | **0** |

## Coverage Report

| Feature | Statements | Branches | Functions | Lines |
|---------|------------|----------|-----------|-------|
| F-01 Auth | 92% | 88% | 95% | 91% |
| F-02 Todos | 88% | 82% | 90% | 87% |
| F-03 Categories | 85% | 80% | 88% | 84% |
| **Overall** | **88%** | **83%** | **91%** | **87%** |

## Cross-Feature Flows Tested

- [x] User registration → Login → Create Todo → Assign Category
- [x] Auth token refresh during active session
- [x] Cascade delete: User → Todos → Category assignments
- [x] Concurrent operations across features

## Regression Check

- [x] All F-01 tests pass with F-02, F-03, F-04, F-05 code present
- [x] No API contract changes broke existing features
- [x] Database schema compatible across all features

## Security Verification

- [x] Auth required on all protected endpoints
- [x] User isolation verified (can't access other users' data)
- [x] Rate limiting active

## Status: PASS
```

**Quality Gate - Integration QA:**
- [25%] All unit tests pass (100%)
- [25%] All integration tests pass (100%)
- [20%] Coverage >= 80% overall
- [15%] No regressions detected
- [15%] Security checks pass

### For SIMPLE Projects

Standard QA (same tests, but single feature scope):
- Code review
- Security review
- Full unit test suite
- Build verification

```bash
npm test -- --coverage
npm run build
```

---

## PHASE 13: DELIVER

### Step 13.1: Final Commit

```bash
git add -A
git commit -m "feat(${PROJECT_NAME}): complete autonomous build

$(if [ "$PROJECT_TYPE" = "COMPLEX" ]; then
    echo "Features implemented:"
    for f in ${COMPLETED_FEATURES}; do
        echo "  - $f"
    done
fi)

- Generated ${SKILL_COUNT} custom skills
- Test coverage: ${COVERAGE}%

Spec-Kit-Plus workflow v2.0 complete.

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 13.2: Build Report

Create `.claude/build-reports/report-$(date +%Y%m%d).md`:

```markdown
# Autonomous Build Report

## Project: ${PROJECT_NAME}
## Type: ${SIMPLE|COMPLEX}
## Features: ${FEATURE_COUNT}

## Feature Implementation Summary

| Feature | Status | Tests | Coverage |
|---------|--------|-------|----------|
$(for each feature...)

## Quality Gate Results

| Phase | Feature | Grade | Status |
|-------|---------|-------|--------|
$(validation summary)
```

---

## RESUME CAPABILITY (Complex Projects)

When resuming a COMPLEX project:

1. Read `feature-breakdown.json`
2. Find first feature with status != "complete"
3. Check feature's internal phase (spec? plan? tasks? implement?)
4. Resume from that point

```
╔════════════════════════════════════════════════════════════════════════════╗
║  RESUMING COMPLEX PROJECT                                                   ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  Project: Todo API (COMPLEX)                                                ║
║  Total Features: 5                                                          ║
║                                                                             ║
║  Feature Status:                                                            ║
║  ├── F-01 Auth        [COMPLETE] Grade A                                    ║
║  ├── F-02 Todos       [COMPLETE] Grade B                                    ║
║  ├── F-03 Categories  [IN PROGRESS] → Phase 11 (Implement)                  ║
║  ├── F-04 Filtering   [PENDING]                                             ║
║  └── F-05 Reports     [PENDING]                                             ║
║                                                                             ║
║  Action: Resuming F-03 Categories at Phase 11 (Implement)                   ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

---

## SUMMARY: WHEN TO USE EACH MODE

| Criteria | SIMPLE Mode | COMPLEX Mode |
|----------|-------------|--------------|
| Feature count | 1-3 | 4+ |
| Has auth + other features | No | Yes |
| Multiple domains | No | Yes |
| Constitution | Once | Once |
| Spec/Plan/Tasks | Once (project) | Per feature |
| Implementation | All at once | Iterative |
| **Unit Testing** | Once at end | **Per feature + Inter-feature** |
| **Integration Testing** | With QA | **After ALL features** |
| QA | Once at end | Per feature + Final Integration |
| Resume granularity | Phase level | Feature + Phase level |

---

## TESTING STRATEGY SUMMARY

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        TESTING PYRAMID                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                           ┌─────────┐                                       │
│                          /   E2E    \           ← Phase 12 (Final)          │
│                         /   Tests    \             Cross-feature journeys   │
│                        ───────────────                                      │
│                       /  Integration  \         ← Phase 12 (Final)          │
│                      /     Tests       \           Feature interactions     │
│                     ─────────────────────                                   │
│                    /    Unit Tests       \      ← Phase 11.6 (After each    │
│                   /   (Inter-Feature)     \        feature 2+)              │
│                  ───────────────────────────       All features together    │
│                 /      Unit Tests          \    ← Phase 11 (Per feature)    │
│                /    (Feature-Specific)      \      TDD: RED→GREEN→REFACTOR  │
│               ───────────────────────────────                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

WHEN TESTS RUN:
┌────────────┬──────────────────────────────────────────────────────────────┐
│ Phase      │ What Tests Run                                               │
├────────────┼──────────────────────────────────────────────────────────────┤
│ 11         │ Feature N unit tests (TDD - write first, then implement)     │
│ 11.5       │ Feature N unit tests (verify implementation)                 │
│ 11.6       │ ALL unit tests (Feature 1 → N) - catch regressions          │
│ 12         │ ALL unit + integration + E2E tests                           │
└────────────┴──────────────────────────────────────────────────────────────┘
```

---

## KEY IMPROVEMENT: Feature-Level Iteration

**Before (v1.0):**
```
Constitution → Spec (all) → Plan (all) → Tasks (all) → Implement (all) → QA
```

**After (v2.0 for COMPLEX projects):**
```
Constitution → Feature Breakdown →
  [Feature 1: Spec → Plan → Tasks → Implement → QA] ←── Ship incrementally
  [Feature 2: Spec → Plan → Tasks → Implement → QA]
  [Feature N: ...]
→ Integration QA → Deliver
```

**Benefits:**
1. Each feature is fully specified before implementation
2. Can ship features incrementally
3. Better progress visibility
4. Easier to resume
5. Integration issues caught early
6. Single constitution governs all features

---

## QUALITY GATE TEACHER (Same as before)

After EVERY phase (project-level OR feature-level):
- Invoke workflow-validator skill
- Grade: A/B/C (APPROVED) or D/F (REJECTED)
- Generate validation report
- Retry up to 3 times if rejected
