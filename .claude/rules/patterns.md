# Common Patterns

## API Response Format

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: {
    total: number
    page: number
    limit: number
  }
}

// Usage
return {
  success: true,
  data: users,
  meta: { total: 100, page: 1, limit: 20 }
}

// Error
return {
  success: false,
  error: 'User not found'
}
```

## Custom Hooks Pattern

```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(handler)
  }, [value, delay])

  return debouncedValue
}
```

## Repository Pattern

```typescript
interface Repository<T> {
  findAll(filters?: Filters): Promise<T[]>
  findById(id: string): Promise<T | null>
  create(data: CreateDto): Promise<T>
  update(id: string, data: UpdateDto): Promise<T>
  delete(id: string): Promise<void>
}

class UserRepository implements Repository<User> {
  async findAll(filters?: UserFilters): Promise<User[]> {
    return db.users.findMany({ where: filters })
  }
  // ... other methods
}
```

## Service Layer Pattern

```typescript
class UserService {
  constructor(
    private userRepo: UserRepository,
    private emailService: EmailService
  ) {}

  async createUser(data: CreateUserDto): Promise<User> {
    const user = await this.userRepo.create(data)
    await this.emailService.sendWelcome(user.email)
    return user
  }
}
```

## Error Handling Pattern

```typescript
class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message)
    this.name = 'AppError'
  }
}

// Usage
throw new AppError('User not found', 404, 'USER_NOT_FOUND')

// Handler
app.use((error, req, res, next) => {
  const status = error.statusCode || 500
  res.status(status).json({
    success: false,
    error: error.message,
    code: error.code
  })
})
```

## Component Composition Pattern

```typescript
// Small, focused components
function Button({ children, onClick, variant = 'primary' }) {
  return (
    <button className={`btn btn-${variant}`} onClick={onClick}>
      {children}
    </button>
  )
}

function Card({ title, children }) {
  return (
    <div className="card">
      <h2>{title}</h2>
      {children}
    </div>
  )
}

// Composed
function UserCard({ user }) {
  return (
    <Card title={user.name}>
      <p>{user.email}</p>
      <Button onClick={() => editUser(user.id)}>Edit</Button>
    </Card>
  )
}
```

## Skeleton Projects

When implementing new functionality:
1. Search for battle-tested skeleton projects
2. Use parallel agents to evaluate options
3. Clone best match as foundation
4. Iterate within proven structure
