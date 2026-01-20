import { Response } from 'express'
import {
  sendSuccess,
  sendError,
  sendCreated,
  sendNoContent,
  calculatePagination
} from '../../../src/utils/response'

describe('Response Utils', () => {
  let mockRes: Partial<Response>

  beforeEach(() => {
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
      send: jest.fn().mockReturnThis()
    }
  })

  describe('sendSuccess', () => {
    it('should send success response with data', () => {
      const data = { id: '1', name: 'Test' }

      sendSuccess(mockRes as Response, data)

      expect(mockRes.status).toHaveBeenCalledWith(200)
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        data
      })
    })

    it('should send success response with custom status code', () => {
      const data = { id: '1' }

      sendSuccess(mockRes as Response, data, 201)

      expect(mockRes.status).toHaveBeenCalledWith(201)
    })

    it('should include meta when provided', () => {
      const data = [{ id: '1' }]
      const meta = { total: 100, page: 1, limit: 10, totalPages: 10 }

      sendSuccess(mockRes as Response, data, 200, meta)

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        data,
        meta
      })
    })
  })

  describe('sendError', () => {
    it('should send error response', () => {
      sendError(mockRes as Response, 'Something went wrong')

      expect(mockRes.status).toHaveBeenCalledWith(500)
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        error: 'Something went wrong'
      })
    })

    it('should send error with custom status code', () => {
      sendError(mockRes as Response, 'Not found', 404)

      expect(mockRes.status).toHaveBeenCalledWith(404)
    })

    it('should include validation details when provided', () => {
      const details = [{ field: 'email', message: 'Invalid email' }]

      sendError(mockRes as Response, 'Validation failed', 400, details)

      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        error: 'Validation failed',
        details
      })
    })

    it('should not include details when empty array', () => {
      sendError(mockRes as Response, 'Error', 400, [])

      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        error: 'Error'
      })
    })
  })

  describe('sendCreated', () => {
    it('should send 201 response', () => {
      const data = { id: '1' }

      sendCreated(mockRes as Response, data)

      expect(mockRes.status).toHaveBeenCalledWith(201)
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        data
      })
    })
  })

  describe('sendNoContent', () => {
    it('should send 204 response', () => {
      sendNoContent(mockRes as Response)

      expect(mockRes.status).toHaveBeenCalledWith(204)
      expect(mockRes.send).toHaveBeenCalled()
    })
  })

  describe('calculatePagination', () => {
    it('should calculate pagination correctly', () => {
      const result = calculatePagination(100, 1, 10)

      expect(result).toEqual({
        total: 100,
        page: 1,
        limit: 10,
        totalPages: 10
      })
    })

    it('should round up total pages', () => {
      const result = calculatePagination(25, 1, 10)

      expect(result.totalPages).toBe(3)
    })

    it('should handle zero total', () => {
      const result = calculatePagination(0, 1, 10)

      expect(result.totalPages).toBe(0)
    })
  })
})
