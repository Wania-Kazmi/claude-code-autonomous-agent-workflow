---
name: jwt-auth-patterns
description: |
  JWT authentication patterns, token management, and security best practices.
  Use when implementing authentication, authorization, and session management.
  Triggers: jwt, authentication, auth, token, login, session, bearer
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

# JWT Authentication Patterns

## Overview

This skill provides patterns and best practices for implementing JWT-based authentication in Express.js applications. It covers token generation, verification, refresh tokens, and security considerations.

## Project Structure

```
src/
├── middleware/
│   └── auth.middleware.ts    # JWT verification
├── services/
│   └── auth.service.ts       # Auth business logic
├── controllers/
│   └── auth.controller.ts    # Auth route handlers
├── routes/
│   └── auth.routes.ts        # Auth endpoints
├── utils/
│   ├── jwt.ts               # JWT utilities
│   └── password.ts          # Password hashing
└── types/
    └── express.d.ts         # Request type extensions
```

## Code Templates

### JWT Utility Module

```typescript
// src/utils/jwt.ts
import jwt, { SignOptions, JwtPayload } from 'jsonwebtoken'

const ACCESS_TOKEN_SECRET = process.env.JWT_ACCESS_SECRET!
const REFRESH_TOKEN_SECRET = process.env.JWT_REFRESH_SECRET!
const ACCESS_TOKEN_EXPIRY = '15m'
const REFRESH_TOKEN_EXPIRY = '7d'

export interface TokenPayload {
  userId: string
  email: string
}

export interface Tokens {
  accessToken: string
  refreshToken: string
}

export function generateAccessToken(payload: TokenPayload): string {
  const options: SignOptions = {
    expiresIn: ACCESS_TOKEN_EXPIRY,
    issuer: 'todo-api'
  }
  return jwt.sign(payload, ACCESS_TOKEN_SECRET, options)
}

export function generateRefreshToken(payload: TokenPayload): string {
  const options: SignOptions = {
    expiresIn: REFRESH_TOKEN_EXPIRY,
    issuer: 'todo-api'
  }
  return jwt.sign(payload, REFRESH_TOKEN_SECRET, options)
}

export function generateTokens(payload: TokenPayload): Tokens {
  return {
    accessToken: generateAccessToken(payload),
    refreshToken: generateRefreshToken(payload)
  }
}

export function verifyAccessToken(token: string): TokenPayload {
  const decoded = jwt.verify(token, ACCESS_TOKEN_SECRET) as JwtPayload & TokenPayload
  return {
    userId: decoded.userId,
    email: decoded.email
  }
}

export function verifyRefreshToken(token: string): TokenPayload {
  const decoded = jwt.verify(token, REFRESH_TOKEN_SECRET) as JwtPayload & TokenPayload
  return {
    userId: decoded.userId,
    email: decoded.email
  }
}
```

### Auth Middleware

```typescript
// src/middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express'
import { verifyAccessToken, TokenPayload } from '../utils/jwt'
import { AppError } from '../utils/errors'

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      user?: TokenPayload
    }
  }
}

export function authMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const authHeader = req.headers.authorization

  if (!authHeader) {
    throw new AppError('No authorization header', 401, 'NO_TOKEN')
  }

  const [bearer, token] = authHeader.split(' ')

  if (bearer !== 'Bearer' || !token) {
    throw new AppError('Invalid authorization format', 401, 'INVALID_FORMAT')
  }

  try {
    const payload = verifyAccessToken(token)
    req.user = payload
    next()
  } catch (error) {
    if (error instanceof Error && error.name === 'TokenExpiredError') {
      throw new AppError('Token expired', 401, 'TOKEN_EXPIRED')
    }
    throw new AppError('Invalid token', 401, 'INVALID_TOKEN')
  }
}

// Optional auth - doesn't fail if no token
export function optionalAuthMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const authHeader = req.headers.authorization

  if (!authHeader) {
    return next()
  }

  const [bearer, token] = authHeader.split(' ')

  if (bearer === 'Bearer' && token) {
    try {
      req.user = verifyAccessToken(token)
    } catch {
      // Ignore invalid tokens in optional auth
    }
  }

  next()
}
```

### Password Hashing Utility

```typescript
// src/utils/password.ts
import bcrypt from 'bcryptjs'

const SALT_ROUNDS = 12

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS)
}

export async function verifyPassword(
  password: string,
  hashedPassword: string
): Promise<boolean> {
  return bcrypt.compare(password, hashedPassword)
}
```

### Auth Service

```typescript
// src/services/auth.service.ts
import { prisma } from '../lib/prisma'
import { hashPassword, verifyPassword } from '../utils/password'
import { generateTokens, verifyRefreshToken, Tokens } from '../utils/jwt'
import { AppError } from '../utils/errors'

export interface RegisterData {
  email: string
  password: string
  name?: string
}

export interface LoginData {
  email: string
  password: string
}

export class AuthService {
  async register(data: RegisterData): Promise<Tokens> {
    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email }
    })

    if (existingUser) {
      throw new AppError('Email already registered', 400, 'EMAIL_EXISTS')
    }

    // Hash password and create user
    const hashedPassword = await hashPassword(data.password)
    const user = await prisma.user.create({
      data: {
        email: data.email,
        password: hashedPassword,
        name: data.name
      }
    })

    // Generate tokens
    return generateTokens({
      userId: user.id,
      email: user.email
    })
  }

  async login(data: LoginData): Promise<Tokens> {
    // Find user
    const user = await prisma.user.findUnique({
      where: { email: data.email }
    })

    if (!user) {
      throw new AppError('Invalid credentials', 401, 'INVALID_CREDENTIALS')
    }

    // Verify password
    const isValid = await verifyPassword(data.password, user.password)

    if (!isValid) {
      throw new AppError('Invalid credentials', 401, 'INVALID_CREDENTIALS')
    }

    // Generate tokens
    return generateTokens({
      userId: user.id,
      email: user.email
    })
  }

  async refreshTokens(refreshToken: string): Promise<Tokens> {
    try {
      const payload = verifyRefreshToken(refreshToken)

      // Verify user still exists
      const user = await prisma.user.findUnique({
        where: { id: payload.userId }
      })

      if (!user) {
        throw new AppError('User not found', 401)
      }

      return generateTokens({
        userId: user.id,
        email: user.email
      })
    } catch (error) {
      throw new AppError('Invalid refresh token', 401, 'INVALID_REFRESH_TOKEN')
    }
  }
}
```

### Auth Controller

```typescript
// src/controllers/auth.controller.ts
import { Request, Response } from 'express'
import { AuthService } from '../services/auth.service'
import { asyncHandler } from '../utils/asyncHandler'

export class AuthController {
  private authService = new AuthService()

  register = asyncHandler(async (req: Request, res: Response) => {
    const { email, password, name } = req.body
    const tokens = await this.authService.register({ email, password, name })

    res.status(201).json({
      success: true,
      data: tokens
    })
  })

  login = asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body
    const tokens = await this.authService.login({ email, password })

    res.json({
      success: true,
      data: tokens
    })
  })

  refresh = asyncHandler(async (req: Request, res: Response) => {
    const { refreshToken } = req.body
    const tokens = await this.authService.refreshTokens(refreshToken)

    res.json({
      success: true,
      data: tokens
    })
  })

  me = asyncHandler(async (req: Request, res: Response) => {
    // User is attached by authMiddleware
    res.json({
      success: true,
      data: {
        userId: req.user!.userId,
        email: req.user!.email
      }
    })
  })
}
```

### Auth Routes

```typescript
// src/routes/auth.routes.ts
import { Router } from 'express'
import { AuthController } from '../controllers/auth.controller'
import { authMiddleware } from '../middleware/auth.middleware'
import { validate } from '../middleware/validation.middleware'
import { registerSchema, loginSchema, refreshSchema } from '../schemas/auth.schema'

const router = Router()
const controller = new AuthController()

router.post('/register', validate(registerSchema), controller.register)
router.post('/login', validate(loginSchema), controller.login)
router.post('/refresh', validate(refreshSchema), controller.refresh)
router.get('/me', authMiddleware, controller.me)

export default router
```

## Best Practices

1. **Use short-lived access tokens**: 15 minutes or less to limit exposure
2. **Implement refresh token rotation**: Issue new refresh token with each refresh
3. **Store refresh tokens securely**: Consider database storage with revocation capability
4. **Use strong secrets**: At least 256 bits of entropy for JWT secrets
5. **Include minimal claims**: Only userId and email, not sensitive data
6. **Set token issuer and audience**: Validate in verification for extra security
7. **Hash passwords with bcrypt**: Use at least 12 salt rounds
8. **Never log tokens**: Treat tokens as sensitive data
9. **Implement token blacklisting**: For immediate logout capability

## Common Commands

```bash
# Install JWT dependencies
npm install jsonwebtoken bcryptjs
npm install -D @types/jsonwebtoken @types/bcryptjs

# Generate secure secrets
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Add to .env
JWT_ACCESS_SECRET=your_generated_secret_here
JWT_REFRESH_SECRET=another_generated_secret_here
```

## Anti-Patterns

1. **Storing sensitive data in tokens**: Tokens can be decoded by anyone
   ```typescript
   // BAD - Don't include sensitive data
   jwt.sign({ userId, password, ssn }, secret)

   // GOOD - Minimal payload
   jwt.sign({ userId, email }, secret)
   ```

2. **Using weak or hardcoded secrets**: Major security vulnerability
   ```typescript
   // BAD
   const secret = 'my-secret'

   // GOOD - Use environment variables
   const secret = process.env.JWT_SECRET!
   if (!secret) throw new Error('JWT_SECRET not configured')
   ```

3. **Not validating token expiry**: Allows use of old tokens
   ```typescript
   // BAD - Ignoring errors
   try {
     return jwt.verify(token, secret)
   } catch {
     return jwt.decode(token) // Still returns expired token data!
   }

   // GOOD - Throw on any error
   return jwt.verify(token, secret) // Throws if expired
   ```

4. **Same secret for access and refresh tokens**: Compromises security
   ```typescript
   // BAD
   const SECRET = process.env.JWT_SECRET

   // GOOD - Separate secrets
   const ACCESS_SECRET = process.env.JWT_ACCESS_SECRET
   const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET
   ```
