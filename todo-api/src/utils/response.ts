import { Response } from 'express'
import { ApiResponse, PaginationMeta, ValidationError } from '../types'

export function sendSuccess<T>(
  res: Response,
  data: T,
  statusCode: number = 200,
  meta?: PaginationMeta
): Response {
  const response: ApiResponse<T> = {
    success: true,
    data
  }

  if (meta) {
    response.meta = meta
  }

  return res.status(statusCode).json(response)
}

export function sendError(
  res: Response,
  message: string,
  statusCode: number = 500,
  details?: ValidationError[]
): Response {
  const response: ApiResponse<never> = {
    success: false,
    error: message
  }

  if (details && details.length > 0) {
    response.details = details
  }

  return res.status(statusCode).json(response)
}

export function sendCreated<T>(res: Response, data: T): Response {
  return sendSuccess(res, data, 201)
}

export function sendNoContent(res: Response): Response {
  return res.status(204).send()
}

export function calculatePagination(
  total: number,
  page: number,
  limit: number
): PaginationMeta {
  return {
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit)
  }
}
