---
description: Comprehensive security and quality review of code changes. Checks for vulnerabilities, code quality issues, and best practices.
---

# Code Review Command

Comprehensive security and quality review of uncommitted changes.

## What This Command Does

1. Get changed files: `git diff --name-only HEAD`

2. For each changed file, check for:

**Security Issues (CRITICAL):**
- Hardcoded credentials, API keys, tokens
- SQL injection vulnerabilities
- XSS vulnerabilities
- Missing input validation
- Insecure dependencies
- Path traversal risks

**Code Quality (HIGH):**
- Functions > 50 lines
- Files > 800 lines
- Nesting depth > 4 levels
- Missing error handling
- console.log statements
- TODO/FIXME comments
- Missing JSDoc for public APIs

**Best Practices (MEDIUM):**
- Mutation patterns (use immutable instead)
- Missing tests for new code
- Accessibility issues (a11y)

3. Generate report with:
   - Severity: CRITICAL, HIGH, MEDIUM, LOW
   - File location and line numbers
   - Issue description
   - Suggested fix

4. Approval criteria:
   - **APPROVE**: No CRITICAL or HIGH issues
   - **WARNING**: MEDIUM issues only
   - **BLOCK**: CRITICAL or HIGH issues found

## Review Output Format

```
[CRITICAL] Hardcoded API key
File: src/api/client.ts:42
Issue: API key exposed in source code
Fix: Move to environment variable

const apiKey = "sk-abc123";  // BAD
const apiKey = process.env.API_KEY;  // GOOD
```

## Immutability Check (CRITICAL)

Always flag mutation patterns:

```typescript
// BAD: Direct mutation
user.name = 'New Name'
array.push(item)

// GOOD: Immutable patterns
const updatedUser = { ...user, name: 'New Name' }
const newArray = [...array, item]
```

## Important

Never approve code with security vulnerabilities!

## Related Agents

This command invokes the `code-reviewer` agent located at:
`.claude/agents/code-reviewer.md`
