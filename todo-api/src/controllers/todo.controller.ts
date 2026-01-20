import { Response, NextFunction } from 'express'
import { todoService } from '../services/todo.service'
import { sendSuccess, sendCreated } from '../utils/response'
import { AuthenticatedRequest } from '../types'
import { CreateTodoInput, UpdateTodoInput, TodoQuery } from '../schemas/todo.schema'

export class TodoController {
  async create(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id
      const input = req.body as CreateTodoInput
      const todo = await todoService.create(userId, input)

      sendCreated(res, todo)
    } catch (error) {
      next(error)
    }
  }

  async findAll(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id
      const query = req.query as unknown as TodoQuery

      const result = await todoService.findAll(
        userId,
        {
          completed: query.completed,
          categoryId: query.categoryId
        },
        query.page,
        query.limit
      )

      sendSuccess(res, result.todos, 200, result.meta)
    } catch (error) {
      next(error)
    }
  }

  async findById(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id
      const todoId = req.params.id
      const todo = await todoService.findById(userId, todoId)

      sendSuccess(res, todo)
    } catch (error) {
      next(error)
    }
  }

  async update(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id
      const todoId = req.params.id
      const input = req.body as UpdateTodoInput
      const todo = await todoService.update(userId, todoId, input)

      sendSuccess(res, todo)
    } catch (error) {
      next(error)
    }
  }

  async delete(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id
      const todoId = req.params.id
      await todoService.delete(userId, todoId)

      sendSuccess(res, { deleted: true })
    } catch (error) {
      next(error)
    }
  }
}

export const todoController = new TodoController()
