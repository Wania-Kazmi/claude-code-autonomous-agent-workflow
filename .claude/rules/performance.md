# Performance Optimization

## Model Selection Strategy

**Haiku** (90% of Sonnet capability, 3x cost savings):
- Lightweight agents with frequent invocation
- Pair programming and code generation
- Worker agents in multi-agent systems
- Simple file operations

**Sonnet** (Best coding model):
- Main development work
- Orchestrating multi-agent workflows
- Complex coding tasks
- Code review and analysis

**Opus** (Deepest reasoning):
- Complex architectural decisions
- Maximum reasoning requirements
- Research and analysis tasks
- Multi-phase planning

## Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

## React Performance

```typescript
// Memoize expensive calculations
const expensiveValue = useMemo(() => {
  return computeExpensive(data)
}, [data])

// Memoize callbacks
const handleClick = useCallback(() => {
  doSomething(id)
}, [id])

// Memoize components
const MemoizedComponent = React.memo(ExpensiveComponent)
```

## Database Performance

```typescript
// Use indexes for frequent queries
CREATE INDEX idx_users_email ON users(email);

// Select only needed columns
const users = await db.users.findMany({
  select: { id: true, name: true, email: true }
})

// Avoid N+1 queries
const users = await db.users.findMany({
  include: { posts: true }  // Join in single query
})
```

## Caching Strategy

```typescript
// Cache expensive operations
const cached = await redis.get(`user:${id}`)
if (cached) return JSON.parse(cached)

const user = await db.users.findUnique({ where: { id } })
await redis.set(`user:${id}`, JSON.stringify(user), 'EX', 3600)
return user
```

## Build Troubleshooting

If build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally (one error at a time)
4. Verify after each fix
5. Max 3 attempts before reporting to user

## Ultrathink + Plan Mode

For complex tasks requiring deep reasoning:
1. Use `ultrathink` for enhanced thinking
2. Enable **Plan Mode** for structured approach
3. "Rev the engine" with multiple critique rounds
4. Use split role sub-agents for diverse analysis
