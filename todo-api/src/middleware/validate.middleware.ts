import { Request, Response, NextFunction } from 'express'
import { ZodSchema, ZodError } from 'zod'
import { sendError } from '../utils/response'
import { ValidationError } from '../types'

interface ValidationSchemas {
  body?: ZodSchema
  params?: ZodSchema
  query?: ZodSchema
}

export function validate(schemas: ValidationSchemas) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (schemas.body) {
        req.body = await schemas.body.parseAsync(req.body)
      }

      if (schemas.params) {
        req.params = await schemas.params.parseAsync(req.params)
      }

      if (schemas.query) {
        req.query = await schemas.query.parseAsync(req.query)
      }

      next()
    } catch (error) {
      if (error instanceof ZodError) {
        const details: ValidationError[] = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message
        }))

        sendError(res, 'Validation failed', 400, details)
        return
      }

      next(error)
    }
  }
}
