---
description: Enforce test-driven development workflow. Write tests FIRST, then implement minimal code to pass. Ensure 80%+ coverage.
---

# TDD Command

This command invokes the **tdd-guide** agent to enforce test-driven development methodology.

## What This Command Does

1. **Scaffold Interfaces** - Define types/interfaces first
2. **Generate Tests First** - Write failing tests (RED)
3. **Implement Minimal Code** - Write just enough to pass (GREEN)
4. **Refactor** - Improve code while keeping tests green (REFACTOR)
5. **Verify Coverage** - Ensure 80%+ test coverage

## TDD Cycle

```
RED → GREEN → REFACTOR → REPEAT

RED:      Write a failing test
GREEN:    Write minimal code to pass
REFACTOR: Improve code, keep tests passing
REPEAT:   Next feature/scenario
```

## When to Use

Use `/tdd` when:
- Implementing new features
- Adding new functions/components
- Fixing bugs (write test that reproduces bug first)
- Refactoring existing code
- Building critical business logic

## Example Workflow

```typescript
// Step 1: Write Test First (RED)
describe('calculateTotal', () => {
  it('returns sum with tax', () => {
    expect(calculateTotal([10, 20], 0.1)).toBe(33)
  })
})

// Step 2: Run Test - Verify FAIL
// npm test → FAIL (function doesn't exist)

// Step 3: Implement (GREEN)
function calculateTotal(items: number[], tax: number): number {
  const subtotal = items.reduce((sum, i) => sum + i, 0)
  return subtotal * (1 + tax)
}

// Step 4: Run Test - Verify PASS
// npm test → PASS

// Step 5: Refactor if needed
// Step 6: Check coverage (80%+)
```

## Test Types to Include

**Unit Tests** (Function-level):
- Happy path scenarios
- Edge cases (empty, null, max values)
- Error conditions
- Boundary values

**Integration Tests** (Component-level):
- API endpoints
- Database operations
- React components with hooks

## Coverage Requirements

- **80% minimum** for all code
- **100% required** for:
  - Financial calculations
  - Authentication logic
  - Security-critical code

## TDD Best Practices

**DO:**
- Write the test FIRST, before any implementation
- Run tests and verify they FAIL before implementing
- Write minimal code to make tests pass
- Refactor only after tests are green

**DON'T:**
- Write implementation before tests
- Skip running tests after each change
- Write too much code at once
- Test implementation details (test behavior)

## Related Agents

This command invokes the `tdd-guide` agent located at:
`.claude/agents/tdd-guide.md`
