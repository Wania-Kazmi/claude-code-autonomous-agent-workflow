import { Router } from 'express'
import { categoryController } from '../controllers/category.controller'
import { authenticate } from '../middleware/auth.middleware'
import { validate } from '../middleware/validate.middleware'
import { createCategorySchema, categoryIdParamSchema } from '../schemas/category.schema'

const router = Router()

// All routes require authentication
router.use(authenticate)

router.post(
  '/',
  validate({ body: createCategorySchema }),
  categoryController.create.bind(categoryController)
)

router.get(
  '/',
  categoryController.findAll.bind(categoryController)
)

router.delete(
  '/:id',
  validate({ params: categoryIdParamSchema }),
  categoryController.delete.bind(categoryController)
)

export default router
