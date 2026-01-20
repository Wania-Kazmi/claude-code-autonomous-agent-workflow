# Git Workflow

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Examples:
- `feat: add user authentication`
- `fix: resolve race condition in cache`
- `refactor: simplify payment processing`

## Pull Request Workflow

When creating PRs:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch

## Feature Implementation Workflow

1. **Plan First**
   - Use **planner** agent to create implementation plan
   - Identify dependencies and risks
   - Break down into phases
   - WAIT FOR USER CONFIRMATION

2. **TDD Approach**
   - Use **tdd-guide** agent
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review**
   - Use **code-reviewer** agent immediately after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

4. **Commit & Push**
   - Detailed commit messages
   - Follow conventional commits format

## Branch Naming

```
feature/add-user-auth
fix/cache-race-condition
refactor/payment-processing
docs/update-readme
```

## Commands

```bash
# Create feature branch
git checkout -b feature/my-feature

# Stage and commit
git add .
git commit -m "feat: description"

# Push with upstream
git push -u origin feature/my-feature

# Create PR
gh pr create --title "feat: description" --body "..."
```
