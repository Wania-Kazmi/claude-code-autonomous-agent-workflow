import { PrismaClient, Category } from '@prisma/client'
import { AppError } from '../utils/AppError'
import { CreateCategoryInput } from '../schemas/category.schema'

const prisma = new PrismaClient()

export class CategoryService {
  async create(userId: string, input: CreateCategoryInput): Promise<Category> {
    // Check for duplicate name for this user
    const existing = await prisma.category.findFirst({
      where: {
        name: input.name,
        userId
      }
    })

    if (existing) {
      throw AppError.conflict('Category with this name already exists', 'CATEGORY_EXISTS')
    }

    return prisma.category.create({
      data: {
        name: input.name,
        userId
      }
    })
  }

  async findAll(userId: string): Promise<Category[]> {
    return prisma.category.findMany({
      where: { userId },
      orderBy: { name: 'asc' }
    })
  }

  async findById(userId: string, categoryId: string): Promise<Category> {
    const category = await prisma.category.findUnique({
      where: { id: categoryId }
    })

    if (!category) {
      throw AppError.notFound('Category not found', 'CATEGORY_NOT_FOUND')
    }

    if (category.userId !== userId) {
      throw AppError.forbidden('You do not have access to this category', 'ACCESS_DENIED')
    }

    return category
  }

  async delete(userId: string, categoryId: string): Promise<void> {
    // Verify ownership
    await this.findById(userId, categoryId)

    await prisma.category.delete({
      where: { id: categoryId }
    })
  }
}

export const categoryService = new CategoryService()
