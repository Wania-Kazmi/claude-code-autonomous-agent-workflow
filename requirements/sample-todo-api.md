# Todo API

A REST API for managing todo items with user authentication.

## Features

### User Management
- User registration with email and password
- User login with JWT authentication
- Password reset via email

### Todo Operations
- Create todo items
- List all todos for logged-in user
- Update todo (title, description, status)
- Delete todo
- Mark todo as complete/incomplete

### Categories
- Create categories
- Assign todos to categories
- Filter todos by category

## Technical Requirements

- Backend: Express.js with TypeScript
- Database: PostgreSQL with Prisma ORM
- Authentication: JWT tokens
- Validation: Zod schemas
- Testing: Jest with 80%+ coverage

## API Endpoints

```
POST   /auth/register
POST   /auth/login
POST   /auth/reset-password

GET    /todos
POST   /todos
GET    /todos/:id
PUT    /todos/:id
DELETE /todos/:id

GET    /categories
POST   /categories
```

## Constraints

- Response time < 200ms
- Proper error handling with standard error format
- Input validation on all endpoints
- Rate limiting: 100 requests/minute per user
