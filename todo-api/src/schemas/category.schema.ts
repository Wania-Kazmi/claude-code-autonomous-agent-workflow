import { z } from 'zod'

export const createCategorySchema = z.object({
  name: z
    .string()
    .min(1, 'Name is required')
    .max(50, 'Name must be at most 50 characters')
})

export const categoryIdParamSchema = z.object({
  id: z.string().uuid('Invalid category ID')
})

export type CreateCategoryInput = z.infer<typeof createCategorySchema>
export type CategoryIdParam = z.infer<typeof categoryIdParamSchema>
