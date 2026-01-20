import { Router } from 'express'
import { authController } from '../controllers/auth.controller'
import { validate } from '../middleware/validate.middleware'
import { authRateLimiter } from '../middleware/rateLimiter'
import { registerSchema, loginSchema, refreshTokenSchema } from '../schemas/auth.schema'

const router = Router()

router.post(
  '/register',
  authRateLimiter,
  validate({ body: registerSchema }),
  authController.register.bind(authController)
)

router.post(
  '/login',
  authRateLimiter,
  validate({ body: loginSchema }),
  authController.login.bind(authController)
)

router.post(
  '/refresh',
  validate({ body: refreshTokenSchema }),
  authController.refresh.bind(authController)
)

export default router
