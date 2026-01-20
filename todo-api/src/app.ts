import express, { Application } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import routes from './routes'
import { errorHandler } from './middleware/errorHandler'
import { rateLimiter } from './middleware/rateLimiter'

export function createApp(): Application {
  const app = express()

  // Security middleware
  app.use(helmet())
  app.use(cors())

  // Rate limiting
  app.use(rateLimiter)

  // Body parsing
  app.use(express.json({ limit: '10kb' }))
  app.use(express.urlencoded({ extended: true, limit: '10kb' }))

  // API routes
  app.use('/api', routes)

  // 404 handler
  app.use((_req, res) => {
    res.status(404).json({
      success: false,
      error: 'Endpoint not found'
    })
  })

  // Error handler
  app.use(errorHandler)

  return app
}
