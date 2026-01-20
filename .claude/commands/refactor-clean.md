---
description: Safely identify and remove dead code with test verification. Never delete code without running tests first.
---

# Refactor Clean Command

Safely identify and remove dead code with test verification.

## What This Command Does

1. Run dead code analysis tools:
   - `knip`: Find unused exports and files
   - `depcheck`: Find unused dependencies
   - `ts-prune`: Find unused TypeScript exports

2. Generate comprehensive report in `docs/DELETION_LOG.md`

3. Categorize findings by severity:
   - **SAFE**: Test files, unused utilities
   - **CAUTION**: API routes, components
   - **DANGER**: Config files, main entry points

4. Propose safe deletions only

5. Before each deletion:
   - Run full test suite
   - Verify tests pass
   - Apply change
   - Re-run tests
   - Rollback if tests fail

6. Show summary of cleaned items

## Analysis Commands

```bash
# Run knip for unused exports/files
npx knip

# Check unused dependencies
npx depcheck

# Find unused TypeScript exports
npx ts-prune
```

## Deletion Log Format

```markdown
# Code Deletion Log

## [YYYY-MM-DD] Refactor Session

### Unused Dependencies Removed
- package-name@version - Reason: never used

### Unused Files Deleted
- src/old-component.tsx - Replaced by: src/new-component.tsx

### Impact
- Files deleted: 15
- Dependencies removed: 5
- Bundle size reduction: ~45 KB
```

## Safety Checklist

Before removing ANYTHING:
- [ ] Run detection tools
- [ ] Grep for all references
- [ ] Check dynamic imports
- [ ] Run all tests
- [ ] Create backup branch

## Important

Never delete code without running tests first!

## Related Agents

This command invokes the `refactor-cleaner` agent located at:
`.claude/agents/refactor-cleaner.md`
