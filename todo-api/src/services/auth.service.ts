import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { PrismaClient, User } from '@prisma/client'
import { AppError } from '../utils/AppError'
import { env } from '../config/env'
import { AuthTokens, TokenPayload, UserResponse } from '../types'
import { RegisterInput, LoginInput } from '../schemas/auth.schema'

const prisma = new PrismaClient()

export class AuthService {
  async register(input: RegisterInput): Promise<{ user: UserResponse; tokens: AuthTokens }> {
    const existingUser = await prisma.user.findUnique({
      where: { email: input.email }
    })

    if (existingUser) {
      throw AppError.conflict('Email already registered', 'EMAIL_EXISTS')
    }

    const hashedPassword = await bcrypt.hash(input.password, env.bcryptRounds)

    const user = await prisma.user.create({
      data: {
        email: input.email,
        password: hashedPassword
      }
    })

    const tokens = this.generateTokens(user)

    return {
      user: this.toUserResponse(user),
      tokens
    }
  }

  async login(input: LoginInput): Promise<{ user: UserResponse; tokens: AuthTokens }> {
    const user = await prisma.user.findUnique({
      where: { email: input.email }
    })

    if (!user) {
      throw AppError.unauthorized('Invalid credentials', 'INVALID_CREDENTIALS')
    }

    const isPasswordValid = await bcrypt.compare(input.password, user.password)

    if (!isPasswordValid) {
      throw AppError.unauthorized('Invalid credentials', 'INVALID_CREDENTIALS')
    }

    const tokens = this.generateTokens(user)

    return {
      user: this.toUserResponse(user),
      tokens
    }
  }

  async refreshToken(refreshToken: string): Promise<{ accessToken: string }> {
    try {
      const decoded = jwt.verify(refreshToken, env.jwtRefreshSecret) as TokenPayload

      if (decoded.type !== 'refresh') {
        throw AppError.unauthorized('Invalid token type', 'INVALID_TOKEN_TYPE')
      }

      const user = await prisma.user.findUnique({
        where: { id: decoded.userId }
      })

      if (!user) {
        throw AppError.unauthorized('User not found', 'USER_NOT_FOUND')
      }

      const accessToken = this.generateAccessToken(user)

      return { accessToken }
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw AppError.unauthorized('Refresh token expired', 'TOKEN_EXPIRED')
      }

      if (error instanceof jwt.JsonWebTokenError) {
        throw AppError.unauthorized('Invalid refresh token', 'INVALID_TOKEN')
      }

      throw error
    }
  }

  private generateTokens(user: User): AuthTokens {
    const accessToken = this.generateAccessToken(user)
    const refreshToken = this.generateRefreshToken(user)

    return { accessToken, refreshToken }
  }

  private generateAccessToken(user: User): string {
    const payload: TokenPayload = {
      userId: user.id,
      email: user.email,
      type: 'access'
    }

    return jwt.sign(payload, env.jwtAccessSecret, {
      expiresIn: env.jwtAccessExpires
    })
  }

  private generateRefreshToken(user: User): string {
    const payload: TokenPayload = {
      userId: user.id,
      email: user.email,
      type: 'refresh'
    }

    return jwt.sign(payload, env.jwtRefreshSecret, {
      expiresIn: env.jwtRefreshExpires
    })
  }

  private toUserResponse(user: User): UserResponse {
    return {
      id: user.id,
      email: user.email
    }
  }
}

export const authService = new AuthService()
