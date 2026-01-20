import { Router } from 'express'
import { todoController } from '../controllers/todo.controller'
import { authenticate } from '../middleware/auth.middleware'
import { validate } from '../middleware/validate.middleware'
import {
  createTodoSchema,
  updateTodoSchema,
  todoIdParamSchema,
  todoQuerySchema
} from '../schemas/todo.schema'

const router = Router()

// All routes require authentication
router.use(authenticate)

router.post(
  '/',
  validate({ body: createTodoSchema }),
  todoController.create.bind(todoController)
)

router.get(
  '/',
  validate({ query: todoQuerySchema }),
  todoController.findAll.bind(todoController)
)

router.get(
  '/:id',
  validate({ params: todoIdParamSchema }),
  todoController.findById.bind(todoController)
)

router.put(
  '/:id',
  validate({ params: todoIdParamSchema, body: updateTodoSchema }),
  todoController.update.bind(todoController)
)

router.delete(
  '/:id',
  validate({ params: todoIdParamSchema }),
  todoController.delete.bind(todoController)
)

export default router
