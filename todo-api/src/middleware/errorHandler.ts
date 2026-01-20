import { Request, Response, NextFunction } from 'express'
import { AppError } from '../utils/AppError'
import { sendError } from '../utils/response'
import { isProduction } from '../config/env'

export function errorHandler(
  error: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): Response {
  if (error instanceof AppError) {
    return sendError(res, error.message, error.statusCode)
  }

  // Log unexpected errors
  console.error('Unexpected error:', error)

  // In production, don't expose internal error details
  const message = isProduction
    ? 'An unexpected error occurred'
    : error.message

  return sendError(res, message, 500)
}
