import request from 'supertest'
import { createApp } from '../../../src/app'
import { Application } from 'express'

// Mock Prisma
jest.mock('@prisma/client', () => {
  const mockPrisma = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn()
    }
  }
  return {
    PrismaClient: jest.fn(() => mockPrisma)
  }
})

describe('Auth Routes', () => {
  let app: Application

  beforeEach(() => {
    app = createApp()
    jest.clearAllMocks()
  })

  describe('POST /api/auth/register', () => {
    it('should return 400 for invalid email', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({ email: 'invalid', password: 'Password123!' })

      expect(response.status).toBe(400)
      expect(response.body.success).toBe(false)
      expect(response.body.details).toBeDefined()
    })

    it('should return 400 for weak password', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({ email: 'test@example.com', password: 'weak' })

      expect(response.status).toBe(400)
      expect(response.body.success).toBe(false)
    })

    it('should return 400 for missing fields', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({})

      expect(response.status).toBe(400)
    })
  })

  describe('POST /api/auth/login', () => {
    it('should return 400 for invalid email format', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({ email: 'invalid', password: 'password' })

      expect(response.status).toBe(400)
    })

    it('should return 400 for missing password', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({ email: 'test@example.com' })

      expect(response.status).toBe(400)
    })
  })

  describe('POST /api/auth/refresh', () => {
    it('should return 400 for missing refresh token', async () => {
      const response = await request(app)
        .post('/api/auth/refresh')
        .send({})

      expect(response.status).toBe(400)
    })
  })
})
