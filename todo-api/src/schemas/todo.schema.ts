import { z } from 'zod'

export const createTodoSchema = z.object({
  title: z
    .string()
    .min(1, 'Title is required')
    .max(200, 'Title must be at most 200 characters'),
  description: z
    .string()
    .max(2000, 'Description must be at most 2000 characters')
    .optional(),
  categoryId: z
    .string()
    .uuid('Invalid category ID')
    .optional()
})

export const updateTodoSchema = z.object({
  title: z
    .string()
    .min(1, 'Title cannot be empty')
    .max(200, 'Title must be at most 200 characters')
    .optional(),
  description: z
    .string()
    .max(2000, 'Description must be at most 2000 characters')
    .nullable()
    .optional(),
  completed: z
    .boolean()
    .optional(),
  categoryId: z
    .string()
    .uuid('Invalid category ID')
    .nullable()
    .optional()
})

export const todoIdParamSchema = z.object({
  id: z.string().uuid('Invalid todo ID')
})

export const todoQuerySchema = z.object({
  completed: z
    .enum(['true', 'false'])
    .optional()
    .transform((val) => val === 'true' ? true : val === 'false' ? false : undefined),
  categoryId: z
    .string()
    .uuid('Invalid category ID')
    .optional(),
  page: z
    .string()
    .optional()
    .default('1')
    .transform((val) => Math.max(1, parseInt(val, 10) || 1)),
  limit: z
    .string()
    .optional()
    .default('20')
    .transform((val) => Math.min(100, Math.max(1, parseInt(val, 10) || 20)))
})

export type CreateTodoInput = z.infer<typeof createTodoSchema>
export type UpdateTodoInput = z.infer<typeof updateTodoSchema>
export type TodoIdParam = z.infer<typeof todoIdParamSchema>
export type TodoQuery = z.infer<typeof todoQuerySchema>
