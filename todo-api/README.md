# Todo API

REST API for managing todo items with user authentication.

## Features

- User registration and authentication with JWT
- CRUD operations for todos
- Category management
- Filtering and pagination
- Rate limiting
- Input validation with Zod

## Tech Stack

- **Runtime:** Node.js with TypeScript
- **Framework:** Express.js
- **Database:** PostgreSQL with Prisma ORM
- **Authentication:** JWT (access + refresh tokens)
- **Validation:** Zod
- **Testing:** Jest + Supertest

## Getting Started

### Prerequisites

- Node.js 18+
- PostgreSQL
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env
# Edit .env with your database credentials

# Generate Prisma client
npm run prisma:generate

# Run migrations
npm run prisma:migrate

# Start development server
npm run dev
```

### Environment Variables

See `.env.example` for required variables.

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Create account |
| POST | /api/auth/login | Login and get tokens |
| POST | /api/auth/refresh | Refresh access token |

### Todos (requires authentication)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/todos | List all todos |
| POST | /api/todos | Create a todo |
| GET | /api/todos/:id | Get a todo |
| PUT | /api/todos/:id | Update a todo |
| DELETE | /api/todos/:id | Delete a todo |

### Categories (requires authentication)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/categories | List all categories |
| POST | /api/categories | Create a category |
| DELETE | /api/categories/:id | Delete a category |

## Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm test             # Run tests
npm run test:coverage # Run tests with coverage
npm run typecheck    # Type check
npm run prisma:studio # Open Prisma Studio
```

## Project Structure

```
src/
├── config/         # Environment configuration
├── controllers/    # Request handlers
├── middleware/     # Express middleware
├── routes/         # API routes
├── schemas/        # Zod validation schemas
├── services/       # Business logic
├── types/          # TypeScript types
├── utils/          # Utilities
├── app.ts          # Express app setup
└── index.ts        # Entry point
```

## Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

## License

MIT
