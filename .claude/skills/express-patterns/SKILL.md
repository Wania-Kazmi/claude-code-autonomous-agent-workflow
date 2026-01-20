---
name: express-patterns
description: |
  Express.js REST API patterns, middleware configuration, error handling, and best practices.
  Use when building Express APIs, configuring middleware, or implementing route handlers.
  Triggers: express, expressjs, rest api, nodejs api, middleware, router
version: 1.0.0
author: Claude Code
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

# Express.js Patterns

## Overview

This skill provides patterns and best practices for building Express.js REST APIs with TypeScript. It covers project structure, middleware configuration, route handlers, error handling, and security.

## Project Structure

```
src/
├── app.ts              # Express app configuration
├── server.ts           # Server entry point
├── routes/
│   ├── index.ts        # Route aggregator
│   ├── auth.routes.ts  # Auth routes
│   └── todos.routes.ts # Todo routes
├── controllers/
│   ├── auth.controller.ts
│   └── todos.controller.ts
├── middleware/
│   ├── auth.middleware.ts
│   ├── error.middleware.ts
│   └── validation.middleware.ts
├── services/
│   ├── auth.service.ts
│   └── todos.service.ts
├── types/
│   └── express.d.ts    # Express type extensions
└── utils/
    ├── logger.ts
    └── asyncHandler.ts
```

## Code Templates

### Express App Setup

```typescript
// src/app.ts
import express, { Application } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import rateLimit from 'express-rate-limit'
import { errorHandler } from './middleware/error.middleware'
import routes from './routes'

const app: Application = express()

// Security middleware
app.use(helmet())
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}))

// Rate limiting
const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute
  message: { error: 'Too many requests, please try again later' }
})
app.use(limiter)

// Body parsing
app.use(express.json({ limit: '10kb' }))
app.use(express.urlencoded({ extended: true }))

// Routes
app.use('/api', routes)

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// Error handling (must be last)
app.use(errorHandler)

export default app
```

### Route Handler Pattern

```typescript
// src/routes/todos.routes.ts
import { Router } from 'express'
import { TodoController } from '../controllers/todos.controller'
import { authMiddleware } from '../middleware/auth.middleware'
import { validate } from '../middleware/validation.middleware'
import { createTodoSchema, updateTodoSchema } from '../schemas/todo.schema'

const router = Router()
const controller = new TodoController()

// All routes require authentication
router.use(authMiddleware)

router.get('/', controller.getAll)
router.get('/:id', controller.getById)
router.post('/', validate(createTodoSchema), controller.create)
router.put('/:id', validate(updateTodoSchema), controller.update)
router.delete('/:id', controller.delete)

export default router
```

### Controller Pattern

```typescript
// src/controllers/todos.controller.ts
import { Request, Response } from 'express'
import { TodoService } from '../services/todos.service'
import { asyncHandler } from '../utils/asyncHandler'
import { AppError } from '../utils/errors'

export class TodoController {
  private todoService = new TodoService()

  getAll = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id
    const todos = await this.todoService.findAll(userId)
    res.json({ success: true, data: todos })
  })

  getById = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params
    const userId = req.user!.id
    const todo = await this.todoService.findById(id, userId)

    if (!todo) {
      throw new AppError('Todo not found', 404)
    }

    res.json({ success: true, data: todo })
  })

  create = asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id
    const todo = await this.todoService.create({ ...req.body, userId })
    res.status(201).json({ success: true, data: todo })
  })

  update = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params
    const userId = req.user!.id
    const todo = await this.todoService.update(id, userId, req.body)
    res.json({ success: true, data: todo })
  })

  delete = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params
    const userId = req.user!.id
    await this.todoService.delete(id, userId)
    res.status(204).send()
  })
}
```

### Async Handler Utility

```typescript
// src/utils/asyncHandler.ts
import { Request, Response, NextFunction, RequestHandler } from 'express'

type AsyncRequestHandler = (
  req: Request,
  res: Response,
  next: NextFunction
) => Promise<void>

export const asyncHandler = (fn: AsyncRequestHandler): RequestHandler => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next)
  }
}
```

### Error Handling Middleware

```typescript
// src/middleware/error.middleware.ts
import { Request, Response, NextFunction } from 'express'
import { AppError } from '../utils/errors'

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error:', err)

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: err.message,
      code: err.code
    })
  }

  // Prisma errors
  if (err.name === 'PrismaClientKnownRequestError') {
    return res.status(400).json({
      success: false,
      error: 'Database operation failed'
    })
  }

  // Default error
  res.status(500).json({
    success: false,
    error: process.env.NODE_ENV === 'production'
      ? 'Internal server error'
      : err.message
  })
}
```

### Custom Error Class

```typescript
// src/utils/errors.ts
export class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message)
    this.name = 'AppError'
    Error.captureStackTrace(this, this.constructor)
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND')
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED')
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400, 'VALIDATION_ERROR')
  }
}
```

## Best Practices

1. **Use async/await with error handling**: Always wrap async route handlers with asyncHandler to catch errors
2. **Layer your application**: Separate routes → controllers → services → repositories
3. **Validate all inputs**: Use validation middleware before controller logic
4. **Use environment variables**: Never hardcode secrets or configuration
5. **Implement proper error responses**: Use consistent error format across all endpoints
6. **Add request logging**: Use morgan or custom logging for debugging
7. **Set security headers**: Always use helmet middleware
8. **Limit request body size**: Prevent DoS attacks with body size limits
9. **Use rate limiting**: Protect against brute force attacks

## Common Commands

```bash
# Create new Express project with TypeScript
npm init -y
npm install express cors helmet express-rate-limit
npm install -D typescript @types/express @types/cors @types/node ts-node nodemon

# Initialize TypeScript
npx tsc --init

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## Anti-Patterns

1. **Mixing concerns in route handlers**: Don't put database queries directly in routes
   ```typescript
   // BAD
   app.get('/users', async (req, res) => {
     const users = await prisma.user.findMany()
     res.json(users)
   })

   // GOOD - Use controller + service layers
   app.get('/users', userController.getAll)
   ```

2. **Not handling async errors**: Unhandled promise rejections crash the server
   ```typescript
   // BAD
   app.get('/users', async (req, res) => {
     const users = await fetchUsers() // If this throws, server crashes
     res.json(users)
   })

   // GOOD - Use asyncHandler
   app.get('/users', asyncHandler(async (req, res) => {
     const users = await fetchUsers()
     res.json(users)
   }))
   ```

3. **Exposing stack traces in production**: Leaks implementation details
   ```typescript
   // BAD
   res.status(500).json({ error: err.stack })

   // GOOD
   res.status(500).json({
     error: process.env.NODE_ENV === 'production'
       ? 'Internal server error'
       : err.message
   })
   ```

4. **Not validating request params**: SQL injection and other attacks
   ```typescript
   // BAD
   const id = req.params.id
   const user = await prisma.user.findUnique({ where: { id } })

   // GOOD - Validate first
   const { id } = validateParams(req.params, idSchema)
   const user = await prisma.user.findUnique({ where: { id } })
   ```
