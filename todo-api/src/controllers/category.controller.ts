import { Response, NextFunction } from 'express'
import { categoryService } from '../services/category.service'
import { sendSuccess, sendCreated } from '../utils/response'
import { AuthenticatedRequest } from '../types'
import { CreateCategoryInput } from '../schemas/category.schema'

export class CategoryController {
  async create(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id
      const input = req.body as CreateCategoryInput
      const category = await categoryService.create(userId, input)

      sendCreated(res, category)
    } catch (error) {
      next(error)
    }
  }

  async findAll(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id
      const categories = await categoryService.findAll(userId)

      sendSuccess(res, categories)
    } catch (error) {
      next(error)
    }
  }

  async delete(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id
      const categoryId = req.params.id
      await categoryService.delete(userId, categoryId)

      sendSuccess(res, { deleted: true })
    } catch (error) {
      next(error)
    }
  }
}

export const categoryController = new CategoryController()
