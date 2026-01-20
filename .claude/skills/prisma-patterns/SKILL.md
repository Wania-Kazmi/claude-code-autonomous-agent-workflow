---
name: prisma-patterns
description: |
  Prisma ORM patterns, schema design, migrations, and best practices for PostgreSQL.
  Use when designing database schemas, writing queries, or managing migrations.
  Triggers: prisma, orm, database, postgresql, schema, migration
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

# Prisma ORM Patterns

## Overview

This skill provides patterns and best practices for using Prisma ORM with PostgreSQL. It covers schema design, migrations, client configuration, and common query patterns.

## Project Structure

```
prisma/
├── schema.prisma       # Database schema
├── migrations/         # Migration history
│   └── 20240101_init/
│       └── migration.sql
└── seed.ts            # Database seeding
src/
├── lib/
│   └── prisma.ts      # Prisma client singleton
├── repositories/
│   ├── user.repository.ts
│   └── todo.repository.ts
└── types/
    └── prisma.d.ts    # Generated types
```

## Code Templates

### Prisma Schema Design

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  password  String
  name      String?
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  todos     Todo[]
  categories Category[]

  @@map("users")
}

model Todo {
  id          String    @id @default(cuid())
  title       String
  description String?
  completed   Boolean   @default(false)
  dueDate     DateTime? @map("due_date")
  createdAt   DateTime  @default(now()) @map("created_at")
  updatedAt   DateTime  @updatedAt @map("updated_at")

  userId     String  @map("user_id")
  user       User    @relation(fields: [userId], references: [id], onDelete: Cascade)

  categoryId String?   @map("category_id")
  category   Category? @relation(fields: [categoryId], references: [id], onDelete: SetNull)

  @@index([userId])
  @@index([categoryId])
  @@map("todos")
}

model Category {
  id        String   @id @default(cuid())
  name      String
  color     String?
  createdAt DateTime @default(now()) @map("created_at")

  userId String @map("user_id")
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  todos Todo[]

  @@unique([userId, name])
  @@map("categories")
}
```

### Prisma Client Singleton

```typescript
// src/lib/prisma.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === 'development'
    ? ['query', 'error', 'warn']
    : ['error']
})

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}

// Graceful shutdown
process.on('beforeExit', async () => {
  await prisma.$disconnect()
})
```

### Repository Pattern

```typescript
// src/repositories/todo.repository.ts
import { prisma } from '../lib/prisma'
import { Prisma, Todo } from '@prisma/client'

export interface CreateTodoData {
  title: string
  description?: string
  dueDate?: Date
  userId: string
  categoryId?: string
}

export interface UpdateTodoData {
  title?: string
  description?: string
  completed?: boolean
  dueDate?: Date
  categoryId?: string
}

export interface TodoFilters {
  completed?: boolean
  categoryId?: string
}

export class TodoRepository {
  async findAll(userId: string, filters?: TodoFilters): Promise<Todo[]> {
    const where: Prisma.TodoWhereInput = { userId }

    if (filters?.completed !== undefined) {
      where.completed = filters.completed
    }
    if (filters?.categoryId) {
      where.categoryId = filters.categoryId
    }

    return prisma.todo.findMany({
      where,
      include: { category: true },
      orderBy: { createdAt: 'desc' }
    })
  }

  async findById(id: string, userId: string): Promise<Todo | null> {
    return prisma.todo.findFirst({
      where: { id, userId },
      include: { category: true }
    })
  }

  async create(data: CreateTodoData): Promise<Todo> {
    return prisma.todo.create({
      data,
      include: { category: true }
    })
  }

  async update(id: string, userId: string, data: UpdateTodoData): Promise<Todo> {
    // First verify ownership
    const existing = await this.findById(id, userId)
    if (!existing) {
      throw new Error('Todo not found')
    }

    return prisma.todo.update({
      where: { id },
      data,
      include: { category: true }
    })
  }

  async delete(id: string, userId: string): Promise<void> {
    // First verify ownership
    const existing = await this.findById(id, userId)
    if (!existing) {
      throw new Error('Todo not found')
    }

    await prisma.todo.delete({ where: { id } })
  }

  async toggleComplete(id: string, userId: string): Promise<Todo> {
    const existing = await this.findById(id, userId)
    if (!existing) {
      throw new Error('Todo not found')
    }

    return prisma.todo.update({
      where: { id },
      data: { completed: !existing.completed },
      include: { category: true }
    })
  }
}
```

### Transaction Pattern

```typescript
// src/services/user.service.ts
import { prisma } from '../lib/prisma'

export async function createUserWithDefaults(
  email: string,
  password: string,
  name?: string
) {
  return prisma.$transaction(async (tx) => {
    // Create user
    const user = await tx.user.create({
      data: { email, password, name }
    })

    // Create default categories
    await tx.category.createMany({
      data: [
        { name: 'Personal', color: '#3B82F6', userId: user.id },
        { name: 'Work', color: '#10B981', userId: user.id },
        { name: 'Shopping', color: '#F59E0B', userId: user.id }
      ]
    })

    return user
  })
}
```

### Database Seeding

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  // Clean existing data
  await prisma.todo.deleteMany()
  await prisma.category.deleteMany()
  await prisma.user.deleteMany()

  // Create test user
  const hashedPassword = await bcrypt.hash('password123', 10)
  const user = await prisma.user.create({
    data: {
      email: 'test@example.com',
      password: hashedPassword,
      name: 'Test User'
    }
  })

  // Create categories
  const workCategory = await prisma.category.create({
    data: { name: 'Work', color: '#3B82F6', userId: user.id }
  })

  // Create todos
  await prisma.todo.createMany({
    data: [
      {
        title: 'Complete project',
        description: 'Finish the API implementation',
        userId: user.id,
        categoryId: workCategory.id
      },
      {
        title: 'Write tests',
        description: 'Add unit and integration tests',
        userId: user.id,
        categoryId: workCategory.id
      }
    ]
  })

  console.log('Database seeded successfully')
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

## Best Practices

1. **Use a singleton Prisma client**: Prevent connection pool exhaustion in development
2. **Add database indexes**: Index foreign keys and frequently queried fields
3. **Use snake_case in database**: Map to camelCase in code with @@map
4. **Implement soft deletes when needed**: Add deletedAt field instead of hard deletes
5. **Use transactions for multi-table operations**: Ensure data consistency
6. **Always filter by userId**: Prevent data leakage between users
7. **Use select to limit returned fields**: Improve query performance
8. **Set up cascade deletes appropriately**: Use onDelete: Cascade for child records
9. **Validate before database operations**: Use Zod schemas before Prisma calls

## Common Commands

```bash
# Initialize Prisma
npx prisma init

# Create migration
npx prisma migrate dev --name init

# Apply migrations in production
npx prisma migrate deploy

# Generate Prisma client
npx prisma generate

# Open Prisma Studio
npx prisma studio

# Reset database (dev only)
npx prisma migrate reset

# Seed database
npx prisma db seed

# Format schema
npx prisma format

# Validate schema
npx prisma validate
```

## Anti-Patterns

1. **Creating new PrismaClient per request**: Exhausts connection pool
   ```typescript
   // BAD
   async function getUsers() {
     const prisma = new PrismaClient()
     return prisma.user.findMany()
   }

   // GOOD - Use singleton
   import { prisma } from './lib/prisma'
   async function getUsers() {
     return prisma.user.findMany()
   }
   ```

2. **Not checking ownership before update/delete**: Data security vulnerability
   ```typescript
   // BAD
   async function deleteTodo(id: string) {
     await prisma.todo.delete({ where: { id } })
   }

   // GOOD - Verify ownership
   async function deleteTodo(id: string, userId: string) {
     const todo = await prisma.todo.findFirst({ where: { id, userId } })
     if (!todo) throw new Error('Not found')
     await prisma.todo.delete({ where: { id } })
   }
   ```

3. **Selecting all fields when not needed**: Performance overhead
   ```typescript
   // BAD - Selects all fields including password
   const users = await prisma.user.findMany()

   // GOOD - Select only needed fields
   const users = await prisma.user.findMany({
     select: { id: true, email: true, name: true }
   })
   ```

4. **Missing indexes on foreign keys**: Slow queries
   ```prisma
   // BAD - No index on userId
   model Todo {
     userId String
   }

   // GOOD - Add index
   model Todo {
     userId String @map("user_id")
     @@index([userId])
   }
   ```
