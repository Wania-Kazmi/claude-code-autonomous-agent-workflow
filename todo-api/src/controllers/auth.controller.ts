import { Request, Response, NextFunction } from 'express'
import { authService } from '../services/auth.service'
import { sendSuccess, sendCreated } from '../utils/response'
import { RegisterInput, LoginInput, RefreshTokenInput } from '../schemas/auth.schema'

export class AuthController {
  async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const input = req.body as RegisterInput
      const result = await authService.register(input)

      sendCreated(res, {
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken
      })
    } catch (error) {
      next(error)
    }
  }

  async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const input = req.body as LoginInput
      const result = await authService.login(input)

      sendSuccess(res, {
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken
      })
    } catch (error) {
      next(error)
    }
  }

  async refresh(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const input = req.body as RefreshTokenInput
      const result = await authService.refreshToken(input.refreshToken)

      sendSuccess(res, result)
    } catch (error) {
      next(error)
    }
  }
}

export const authController = new AuthController()
