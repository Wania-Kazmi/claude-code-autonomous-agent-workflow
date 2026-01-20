---
description: Generate and run end-to-end tests with Playwright. Creates test journeys, runs tests, captures screenshots/videos/traces.
---

# E2E Command

This command invokes the **e2e-runner** agent to generate, maintain, and execute end-to-end tests using Playwright.

## What This Command Does

1. **Generate Test Journeys** - Create Playwright tests for user flows
2. **Run E2E Tests** - Execute tests across browsers
3. **Capture Artifacts** - Screenshots, videos, traces on failures
4. **Upload Results** - HTML reports and JUnit XML
5. **Identify Flaky Tests** - Quarantine unstable tests

## When to Use

Use `/e2e` when:
- Testing critical user journeys (login, checkout, payments)
- Verifying multi-step flows work end-to-end
- Testing UI interactions and navigation
- Validating integration between frontend and backend
- Preparing for production deployment

## Quick Commands

```bash
# Run all E2E tests
npx playwright test

# Run specific test file
npx playwright test tests/e2e/auth.spec.ts

# Run in headed mode (see browser)
npx playwright test --headed

# Debug test
npx playwright test --debug

# Generate test code
npx playwright codegen http://localhost:3000

# View report
npx playwright show-report
```

## Test Structure (Page Object Model)

```typescript
// pages/LoginPage.ts
export class LoginPage {
  readonly page: Page
  readonly emailInput: Locator
  readonly submitButton: Locator

  constructor(page: Page) {
    this.page = page
    this.emailInput = page.locator('[data-testid="email"]')
    this.submitButton = page.locator('[data-testid="submit"]')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.submitButton.click()
  }
}
```

## Artifact Management

**On All Tests:**
- HTML Report with timeline and results
- JUnit XML for CI integration

**On Failure Only:**
- Screenshot of the failing state
- Video recording of the test
- Trace file for debugging

## Flaky Test Quarantine

```typescript
test('flaky: complex flow', async ({ page }) => {
  test.fixme(true, 'Test is flaky - Issue #123')
  // Test code...
})
```

## Best Practices

**DO:**
- Use Page Object Model for maintainability
- Use data-testid attributes for selectors
- Wait for API responses, not arbitrary timeouts
- Test critical user journeys end-to-end

**DON'T:**
- Use brittle selectors (CSS classes can change)
- Test implementation details
- Run tests against production
- Ignore flaky tests

## Related Agents

This command invokes the `e2e-runner` agent located at:
`.claude/agents/e2e-runner.md`
