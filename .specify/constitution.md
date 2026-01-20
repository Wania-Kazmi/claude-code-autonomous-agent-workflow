# Todo API Constitution

> Ground rules and principles for the Todo API project

---

## Core Principles

1. **Test-First Development**: Write tests before implementation using TDD cycle (RED → GREEN → REFACTOR)
2. **Immutability**: Never mutate state directly - always use spread operator and immutable patterns
3. **Type Safety**: Full TypeScript strict mode - no `any` types without justification
4. **Security First**: Validate all inputs, sanitize outputs, never trust client data
5. **Single Responsibility**: Each file, function, and class has one clear purpose

---

## Code Standards

### File Organization
- Maximum file size: 400 lines (800 absolute max)
- High cohesion, low coupling
- One component/service/controller per file
- Organize by feature, not by type

### Naming Conventions
```
components/    PascalCase   Button.tsx
controllers/   PascalCase   TodoController.ts
services/      PascalCase   AuthService.ts
utils/         camelCase    formatDate.ts
schemas/       camelCase    todo.schema.ts
routes/        camelCase    auth.routes.ts
```

### Error Handling
- All errors must be caught and handled
- Use custom AppError classes with status codes
- Never expose stack traces in production
- Log errors with context for debugging

### API Response Format
```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  details?: ValidationError[]
}
```

---

## Technology Decisions

| Layer | Technology | Justification |
|-------|------------|---------------|
| Runtime | Node.js | Required by project spec |
| Framework | Express.js | Required by project spec |
| Language | TypeScript | Type safety, better DX |
| Database | PostgreSQL | Required by project spec |
| ORM | Prisma | Required by project spec |
| Auth | JWT | Required by project spec |
| Validation | Zod | Required by project spec |
| Testing | Jest | Required by project spec |

---

## Quality Gates

### Before Commit
- [ ] All tests pass (`npm test`)
- [ ] Coverage >= 80%
- [ ] No TypeScript errors (`npm run typecheck`)
- [ ] No linting errors (`npm run lint`)
- [ ] No console.log statements
- [ ] No hardcoded secrets

### Before Merge
- [ ] Code review passed
- [ ] Security review passed (for auth/input handling)
- [ ] All CI checks green

---

## Security Requirements

### Authentication
- JWT access tokens: 15 minute expiry
- JWT refresh tokens: 7 day expiry
- Separate secrets for access and refresh tokens
- Passwords hashed with bcrypt (12 rounds)

### Input Validation
- All endpoints validate input with Zod
- Sanitize all user-provided strings
- Validate params, query, and body

### Data Protection
- Users can only access their own data
- Filter by userId on all queries
- Check ownership before update/delete

---

## Performance Requirements

| Metric | Target |
|--------|--------|
| Response time | < 200ms |
| Rate limiting | 100 requests/minute/user |
| Body size limit | 10kb |
| Database connections | Pool max 10 |

---

## Out of Scope

The following are explicitly NOT part of this project:
- Frontend/UI implementation
- Email service integration (mock only)
- File uploads
- Real-time notifications (WebSockets)
- OAuth/social login
- Multi-tenancy
- Internationalization
- Admin dashboard
