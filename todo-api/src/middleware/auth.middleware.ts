import { Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
import { AuthenticatedRequest, TokenPayload } from '../types'
import { AppError } from '../utils/AppError'
import { env } from '../config/env'

export function authenticate(
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
): void {
  try {
    const authHeader = req.headers.authorization

    if (!authHeader) {
      throw AppError.unauthorized('No authorization header provided')
    }

    const parts = authHeader.split(' ')

    if (parts.length !== 2 || parts[0] !== 'Bearer') {
      throw AppError.unauthorized('Invalid authorization format. Use: Bearer <token>')
    }

    const token = parts[1]

    const decoded = jwt.verify(token, env.jwtAccessSecret) as TokenPayload

    if (decoded.type !== 'access') {
      throw AppError.unauthorized('Invalid token type')
    }

    req.user = {
      id: decoded.userId,
      email: decoded.email
    }

    next()
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      next(AppError.unauthorized('Invalid token'))
      return
    }

    if (error instanceof jwt.TokenExpiredError) {
      next(AppError.unauthorized('Token expired'))
      return
    }

    next(error)
  }
}
