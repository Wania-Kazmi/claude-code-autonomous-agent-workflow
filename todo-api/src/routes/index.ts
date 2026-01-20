import { Router } from 'express'
import authRoutes from './auth.routes'
import todoRoutes from './todo.routes'
import categoryRoutes from './category.routes'

const router = Router()

router.use('/auth', authRoutes)
router.use('/todos', todoRoutes)
router.use('/categories', categoryRoutes)

// Health check endpoint
router.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

export default router
