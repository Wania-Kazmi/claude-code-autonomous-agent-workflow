---
description: Analyze test coverage and generate missing tests. Ensure 80%+ overall coverage.
---

# Test Coverage Command

Analyze test coverage and generate missing tests.

## What This Command Does

1. Run tests with coverage: `npm test -- --coverage`

2. Analyze coverage report (coverage/coverage-summary.json)

3. Identify files below 80% coverage threshold

4. For each under-covered file:
   - Analyze untested code paths
   - Generate unit tests for functions
   - Generate integration tests for APIs
   - Generate E2E tests for critical flows

5. Verify new tests pass

6. Show before/after coverage metrics

7. Ensure project reaches 80%+ overall coverage

## Coverage Requirements

- **80% minimum** for all code
- **100% required** for:
  - Financial calculations
  - Authentication logic
  - Security-critical code
  - Core business logic

## Focus Areas

- Happy path scenarios
- Error handling
- Edge cases (null, undefined, empty)
- Boundary conditions

## Coverage Report

```bash
# Run tests with coverage
npm test -- --coverage

# View HTML report
open coverage/lcov-report/index.html
```

## Required Thresholds

```
File           | % Stmts | % Branch | % Funcs | % Lines
---------------|---------|----------|---------|--------
All files      |   80+   |   80+    |   80+   |   80+
```

## Test Types to Generate

**Unit Tests:**
- Individual functions
- Edge cases
- Error conditions

**Integration Tests:**
- API endpoints
- Database operations

**E2E Tests:**
- Critical user flows

## Related Agents

This command invokes the `tdd-guide` agent located at:
`.claude/agents/tdd-guide.md`
