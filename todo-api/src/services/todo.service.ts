import { PrismaClient, Todo } from '@prisma/client'
import { AppError } from '../utils/AppError'
import { PaginationMeta, TodoFilters } from '../types'
import { CreateTodoInput, UpdateTodoInput } from '../schemas/todo.schema'

const prisma = new PrismaClient()

export interface TodoWithMeta {
  todos: Todo[]
  meta: PaginationMeta
}

export class TodoService {
  async create(userId: string, input: CreateTodoInput): Promise<Todo> {
    // Verify category ownership if provided
    if (input.categoryId) {
      const category = await prisma.category.findFirst({
        where: {
          id: input.categoryId,
          userId
        }
      })

      if (!category) {
        throw AppError.badRequest('Category not found or does not belong to you', 'INVALID_CATEGORY')
      }
    }

    return prisma.todo.create({
      data: {
        title: input.title,
        description: input.description,
        categoryId: input.categoryId,
        userId
      }
    })
  }

  async findAll(
    userId: string,
    filters: TodoFilters,
    page: number,
    limit: number
  ): Promise<TodoWithMeta> {
    const where = {
      userId,
      ...(filters.completed !== undefined && { completed: filters.completed }),
      ...(filters.categoryId && { categoryId: filters.categoryId })
    }

    const [todos, total] = await Promise.all([
      prisma.todo.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' }
      }),
      prisma.todo.count({ where })
    ])

    return {
      todos,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      }
    }
  }

  async findById(userId: string, todoId: string): Promise<Todo> {
    const todo = await prisma.todo.findUnique({
      where: { id: todoId }
    })

    if (!todo) {
      throw AppError.notFound('Todo not found', 'TODO_NOT_FOUND')
    }

    if (todo.userId !== userId) {
      throw AppError.forbidden('You do not have access to this todo', 'ACCESS_DENIED')
    }

    return todo
  }

  async update(userId: string, todoId: string, input: UpdateTodoInput): Promise<Todo> {
    // Verify ownership
    await this.findById(userId, todoId)

    // Verify category ownership if updating category
    if (input.categoryId) {
      const category = await prisma.category.findFirst({
        where: {
          id: input.categoryId,
          userId
        }
      })

      if (!category) {
        throw AppError.badRequest('Category not found or does not belong to you', 'INVALID_CATEGORY')
      }
    }

    return prisma.todo.update({
      where: { id: todoId },
      data: {
        ...(input.title !== undefined && { title: input.title }),
        ...(input.description !== undefined && { description: input.description }),
        ...(input.completed !== undefined && { completed: input.completed }),
        ...(input.categoryId !== undefined && { categoryId: input.categoryId })
      }
    })
  }

  async delete(userId: string, todoId: string): Promise<void> {
    // Verify ownership
    await this.findById(userId, todoId)

    await prisma.todo.delete({
      where: { id: todoId }
    })
  }
}

export const todoService = new TodoService()
