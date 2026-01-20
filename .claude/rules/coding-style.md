# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate:

```javascript
// WRONG: Mutation
function updateUser(user, name) {
  user.name = name  // MUTATION!
  return user
}

// CORRECT: Immutability
function updateUser(user, name) {
  return {
    ...user,
    name
  }
}
```

```javascript
// WRONG: Array mutation
array.push(item)
array.splice(0, 1)

// CORRECT: Immutable arrays
const newArray = [...array, item]
const filtered = array.filter((_, i) => i !== 0)
```

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large components
- Organize by feature/domain, not by type

## Error Handling

ALWAYS handle errors comprehensively:

```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('Detailed user-friendly message')
}
```

## Input Validation

ALWAYS validate user input:

```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

const validated = schema.parse(input)
```

## Naming Conventions

```typescript
// Functions: camelCase, verb prefix
function getUserById(id: string) {}
function calculateTotal(items: Item[]) {}

// Components: PascalCase
function UserProfile() {}
function ShoppingCart() {}

// Constants: UPPER_SNAKE_CASE
const MAX_RETRY_COUNT = 3
const API_BASE_URL = '/api'

// Types/Interfaces: PascalCase
interface UserProfile {}
type PaymentMethod = 'card' | 'crypto'
```

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No console.log statements
- [ ] No hardcoded values
- [ ] No mutation (immutable patterns used)
- [ ] Input validation present
- [ ] Tests written and passing
