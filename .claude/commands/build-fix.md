---
description: Incrementally fix TypeScript and build errors with minimal diffs. Fix one error at a time for safety.
---

# Build and Fix Command

Incrementally fix TypeScript and build errors.

## What This Command Does

1. Run build: `npm run build` or `npx tsc --noEmit`

2. Parse error output:
   - Group by file
   - Sort by severity

3. For each error:
   - Show error context (5 lines before/after)
   - Explain the issue
   - Propose fix
   - Apply fix
   - Re-run build
   - Verify error resolved

4. Stop if:
   - Fix introduces new errors
   - Same error persists after 3 attempts
   - User requests pause

5. Show summary:
   - Errors fixed
   - Errors remaining
   - New errors introduced

## Common Error Patterns

**Type Inference Failure**
```typescript
// BAD: Parameter 'x' implicitly has 'any' type
function add(x, y) { return x + y }

// GOOD: Add type annotations
function add(x: number, y: number): number { return x + y }
```

**Null/Undefined Errors**
```typescript
// BAD: Object is possibly 'undefined'
const name = user.name.toUpperCase()

// GOOD: Optional chaining
const name = user?.name?.toUpperCase()
```

**Import Errors**
```typescript
// BAD: Cannot find module '@/lib/utils'

// FIX 1: Check tsconfig paths
// FIX 2: Use relative import
import { formatDate } from '../lib/utils'
```

## Minimal Diff Strategy

**DO:**
- Add type annotations where missing
- Add null checks where needed
- Fix imports/exports

**DON'T:**
- Refactor unrelated code
- Change architecture
- Add new features

## Important

Fix one error at a time for safety!

## Related Agents

This command invokes the `build-error-resolver` agent located at:
`.claude/agents/build-error-resolver.md`
