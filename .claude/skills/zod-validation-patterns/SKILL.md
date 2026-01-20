---
name: zod-validation-patterns
description: |
  Zod schema validation patterns, type inference, and Express middleware integration.
  Use when validating API inputs, defining type-safe schemas, or creating validation middleware.
  Triggers: zod, validation, schema, input validation, type safety, validate
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

# Zod Validation Patterns

## Overview

This skill provides patterns and best practices for using Zod schema validation in Express.js applications. It covers schema definition, type inference, custom validators, and middleware integration.

## Project Structure

```
src/
├── schemas/
│   ├── index.ts           # Schema exports
│   ├── auth.schema.ts     # Auth validation schemas
│   ├── todo.schema.ts     # Todo validation schemas
│   └── common.schema.ts   # Reusable schemas
├── middleware/
│   └── validation.middleware.ts
└── types/
    └── schemas.ts         # Inferred types
```

## Code Templates

### Common Base Schemas

```typescript
// src/schemas/common.schema.ts
import { z } from 'zod'

// Reusable ID schema
export const idSchema = z.string().cuid()

// Pagination schema
export const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20)
})

// Date schema with transform
export const dateSchema = z.string().datetime().or(z.date()).transform((val) =>
  typeof val === 'string' ? new Date(val) : val
)

// Optional date
export const optionalDateSchema = dateSchema.optional().nullable()

// Email schema
export const emailSchema = z.string().email().toLowerCase().trim()

// Password schema with requirements
export const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .max(100)
  .regex(/[A-Z]/, 'Password must contain an uppercase letter')
  .regex(/[a-z]/, 'Password must contain a lowercase letter')
  .regex(/[0-9]/, 'Password must contain a number')

// Safe string (trimmed, no XSS)
export const safeStringSchema = z.string().trim().min(1).max(1000)
```

### Auth Schemas

```typescript
// src/schemas/auth.schema.ts
import { z } from 'zod'
import { emailSchema, passwordSchema } from './common.schema'

export const registerSchema = z.object({
  body: z.object({
    email: emailSchema,
    password: passwordSchema,
    name: z.string().trim().min(1).max(100).optional()
  })
})

export const loginSchema = z.object({
  body: z.object({
    email: emailSchema,
    password: z.string().min(1, 'Password is required')
  })
})

export const refreshSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token is required')
  })
})

export const resetPasswordSchema = z.object({
  body: z.object({
    email: emailSchema
  })
})

export const changePasswordSchema = z.object({
  body: z.object({
    currentPassword: z.string().min(1),
    newPassword: passwordSchema
  }).refine(
    (data) => data.currentPassword !== data.newPassword,
    { message: 'New password must be different', path: ['newPassword'] }
  )
})

// Type inference
export type RegisterInput = z.infer<typeof registerSchema>['body']
export type LoginInput = z.infer<typeof loginSchema>['body']
```

### Todo Schemas

```typescript
// src/schemas/todo.schema.ts
import { z } from 'zod'
import { idSchema, optionalDateSchema, paginationSchema } from './common.schema'

export const createTodoSchema = z.object({
  body: z.object({
    title: z.string().trim().min(1, 'Title is required').max(200),
    description: z.string().trim().max(2000).optional(),
    dueDate: optionalDateSchema,
    categoryId: idSchema.optional()
  })
})

export const updateTodoSchema = z.object({
  params: z.object({
    id: idSchema
  }),
  body: z.object({
    title: z.string().trim().min(1).max(200).optional(),
    description: z.string().trim().max(2000).optional().nullable(),
    completed: z.boolean().optional(),
    dueDate: optionalDateSchema,
    categoryId: idSchema.optional().nullable()
  })
})

export const getTodoSchema = z.object({
  params: z.object({
    id: idSchema
  })
})

export const listTodosSchema = z.object({
  query: paginationSchema.extend({
    completed: z.enum(['true', 'false']).transform(v => v === 'true').optional(),
    categoryId: idSchema.optional(),
    search: z.string().trim().max(100).optional()
  })
})

export const deleteTodoSchema = z.object({
  params: z.object({
    id: idSchema
  })
})

// Type inference
export type CreateTodoInput = z.infer<typeof createTodoSchema>['body']
export type UpdateTodoInput = z.infer<typeof updateTodoSchema>['body']
export type ListTodosQuery = z.infer<typeof listTodosSchema>['query']
```

### Validation Middleware

```typescript
// src/middleware/validation.middleware.ts
import { Request, Response, NextFunction } from 'express'
import { ZodSchema, ZodError } from 'zod'

interface ValidationError {
  field: string
  message: string
}

function formatZodErrors(error: ZodError): ValidationError[] {
  return error.errors.map((err) => ({
    field: err.path.join('.'),
    message: err.message
  }))
}

export function validate<T extends ZodSchema>(schema: T) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const validated = await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params
      })

      // Replace request data with validated/transformed data
      req.body = validated.body ?? req.body
      req.query = validated.query ?? req.query
      req.params = validated.params ?? req.params

      next()
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: formatZodErrors(error)
        })
      }
      next(error)
    }
  }
}

// Validate only body
export function validateBody<T extends ZodSchema>(schema: T) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      req.body = await schema.parseAsync(req.body)
      next()
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: formatZodErrors(error)
        })
      }
      next(error)
    }
  }
}
```

### Custom Validators

```typescript
// src/schemas/custom.schema.ts
import { z } from 'zod'

// Hex color validator
export const hexColorSchema = z
  .string()
  .regex(/^#[0-9A-Fa-f]{6}$/, 'Invalid hex color format')

// URL validator with protocol check
export const urlSchema = z
  .string()
  .url()
  .refine(
    (url) => url.startsWith('https://'),
    'URL must use HTTPS'
  )

// Phone number (E.164 format)
export const phoneSchema = z
  .string()
  .regex(/^\+[1-9]\d{1,14}$/, 'Invalid phone number format')

// Slug validator
export const slugSchema = z
  .string()
  .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, 'Invalid slug format')

// Array with unique values
export const uniqueArraySchema = <T extends z.ZodTypeAny>(itemSchema: T) =>
  z.array(itemSchema).refine(
    (items) => new Set(items).size === items.length,
    'Array must contain unique values'
  )

// Enum from values
export const createEnumSchema = <T extends string>(values: readonly T[]) =>
  z.enum(values as [T, ...T[]])

// Conditional schema
export const todoWithDueDateSchema = z.object({
  title: z.string(),
  hasDueDate: z.boolean(),
  dueDate: z.string().datetime().optional()
}).refine(
  (data) => !data.hasDueDate || data.dueDate !== undefined,
  { message: 'Due date is required when hasDueDate is true', path: ['dueDate'] }
)
```

### Schema Composition

```typescript
// src/schemas/composed.schema.ts
import { z } from 'zod'

// Base schema
const baseUserSchema = z.object({
  email: z.string().email(),
  name: z.string().optional()
})

// Extend for creation (add password)
export const createUserSchema = baseUserSchema.extend({
  password: z.string().min(8)
})

// Extend for update (all optional)
export const updateUserSchema = baseUserSchema.partial()

// Merge schemas
const addressSchema = z.object({
  street: z.string(),
  city: z.string(),
  country: z.string()
})

export const userWithAddressSchema = baseUserSchema.merge(
  z.object({ address: addressSchema.optional() })
)

// Pick specific fields
export const userEmailOnlySchema = baseUserSchema.pick({ email: true })

// Omit fields
export const userWithoutEmailSchema = baseUserSchema.omit({ email: true })

// Transform output
export const userResponseSchema = createUserSchema
  .omit({ password: true })
  .transform((user) => ({
    ...user,
    displayName: user.name || user.email.split('@')[0]
  }))
```

## Best Practices

1. **Define schemas close to usage**: Keep auth schemas with auth routes, todo schemas with todo routes
2. **Use type inference**: Let Zod infer TypeScript types instead of duplicating definitions
3. **Create reusable base schemas**: Extract common patterns like ID, email, pagination
4. **Validate all request parts**: body, params, and query in one schema
5. **Use transforms for normalization**: Trim strings, lowercase emails, parse dates
6. **Provide clear error messages**: Custom messages help API consumers
7. **Replace request data with validated data**: Ensures transformed values are used
8. **Keep schemas in sync with Prisma**: Match field names and types
9. **Use refinements for complex rules**: Cross-field validation, conditional requirements

## Common Commands

```bash
# Install Zod
npm install zod

# No types needed - Zod includes TypeScript definitions

# Generate OpenAPI from Zod (optional)
npm install zod-to-openapi
```

## Anti-Patterns

1. **Duplicating types and schemas**: Maintenance nightmare
   ```typescript
   // BAD - Duplicated definition
   interface User { email: string; name?: string }
   const userSchema = z.object({ email: z.string(), name: z.string().optional() })

   // GOOD - Infer type from schema
   const userSchema = z.object({ email: z.string(), name: z.string().optional() })
   type User = z.infer<typeof userSchema>
   ```

2. **Not using transforms for normalization**: Inconsistent data
   ```typescript
   // BAD - Email stored as-is
   const schema = z.object({ email: z.string().email() })

   // GOOD - Normalize email
   const schema = z.object({
     email: z.string().email().toLowerCase().trim()
   })
   ```

3. **Catching errors incorrectly**: Swallows non-validation errors
   ```typescript
   // BAD
   try {
     schema.parse(data)
   } catch (e) {
     res.status(400).json({ error: 'Invalid' })
   }

   // GOOD - Check error type
   try {
     schema.parse(data)
   } catch (e) {
     if (e instanceof ZodError) {
       res.status(400).json({ errors: e.errors })
     } else {
       throw e // Re-throw unexpected errors
     }
   }
   ```

4. **Not validating params and query**: Only validating body
   ```typescript
   // BAD - Only validates body
   router.put('/:id', validate(updateSchema), handler)

   // GOOD - Validates params too
   const schema = z.object({
     params: z.object({ id: z.string().cuid() }),
     body: updateSchema
   })
   router.put('/:id', validate(schema), handler)
   ```
