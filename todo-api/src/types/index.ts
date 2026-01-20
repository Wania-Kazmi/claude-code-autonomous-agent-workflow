import { Request } from 'express'

export interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  details?: ValidationError[]
  meta?: PaginationMeta
}

export interface ValidationError {
  field: string
  message: string
}

export interface PaginationMeta {
  total: number
  page: number
  limit: number
  totalPages: number
}

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string
    email: string
  }
}

export interface TokenPayload {
  userId: string
  email: string
  type: 'access' | 'refresh'
}

export interface AuthTokens {
  accessToken: string
  refreshToken: string
}

export interface UserResponse {
  id: string
  email: string
}

export interface PaginationParams {
  page: number
  limit: number
}

export interface TodoFilters {
  completed?: boolean
  categoryId?: string
}
