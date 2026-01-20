import { AppError } from '../../../src/utils/AppError'

describe('AppError', () => {
  describe('constructor', () => {
    it('should create error with default values', () => {
      const error = new AppError('Test error')

      expect(error.message).toBe('Test error')
      expect(error.statusCode).toBe(500)
      expect(error.code).toBe('INTERNAL_ERROR')
      expect(error.isOperational).toBe(true)
    })

    it('should create error with custom status code', () => {
      const error = new AppError('Not found', 404)

      expect(error.statusCode).toBe(404)
    })

    it('should create error with custom code', () => {
      const error = new AppError('Custom error', 400, 'CUSTOM_CODE')

      expect(error.code).toBe('CUSTOM_CODE')
    })

    it('should be an instance of Error', () => {
      const error = new AppError('Test')

      expect(error).toBeInstanceOf(Error)
      expect(error).toBeInstanceOf(AppError)
    })
  })

  describe('static methods', () => {
    it('should create bad request error', () => {
      const error = AppError.badRequest('Invalid input')

      expect(error.statusCode).toBe(400)
      expect(error.message).toBe('Invalid input')
      expect(error.code).toBe('BAD_REQUEST')
    })

    it('should create unauthorized error', () => {
      const error = AppError.unauthorized()

      expect(error.statusCode).toBe(401)
      expect(error.message).toBe('Unauthorized')
    })

    it('should create forbidden error', () => {
      const error = AppError.forbidden()

      expect(error.statusCode).toBe(403)
      expect(error.message).toBe('Forbidden')
    })

    it('should create not found error', () => {
      const error = AppError.notFound('User not found')

      expect(error.statusCode).toBe(404)
      expect(error.message).toBe('User not found')
    })

    it('should create conflict error', () => {
      const error = AppError.conflict('Email already exists')

      expect(error.statusCode).toBe(409)
      expect(error.message).toBe('Email already exists')
    })

    it('should create too many requests error', () => {
      const error = AppError.tooManyRequests()

      expect(error.statusCode).toBe(429)
    })

    it('should create internal error', () => {
      const error = AppError.internal()

      expect(error.statusCode).toBe(500)
    })
  })
})
