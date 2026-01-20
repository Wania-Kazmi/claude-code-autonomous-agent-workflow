import dotenv from 'dotenv'

dotenv.config()

interface EnvConfig {
  port: number
  nodeEnv: string
  databaseUrl: string
  jwtAccessSecret: string
  jwtRefreshSecret: string
  jwtAccessExpires: string
  jwtRefreshExpires: string
  bcryptRounds: number
  rateLimitWindowMs: number
  rateLimitMax: number
}

function getEnvVar(key: string, defaultValue?: string): string {
  const value = process.env[key] || defaultValue
  if (!value) {
    throw new Error(`Missing environment variable: ${key}`)
  }
  return value
}

function getEnvVarAsNumber(key: string, defaultValue: number): number {
  const value = process.env[key]
  if (!value) return defaultValue
  const parsed = parseInt(value, 10)
  if (isNaN(parsed)) {
    throw new Error(`Invalid number for environment variable: ${key}`)
  }
  return parsed
}

export const env: EnvConfig = {
  port: getEnvVarAsNumber('PORT', 3000),
  nodeEnv: getEnvVar('NODE_ENV', 'development'),
  databaseUrl: getEnvVar('DATABASE_URL'),
  jwtAccessSecret: getEnvVar('JWT_ACCESS_SECRET'),
  jwtRefreshSecret: getEnvVar('JWT_REFRESH_SECRET'),
  jwtAccessExpires: getEnvVar('JWT_ACCESS_EXPIRES', '15m'),
  jwtRefreshExpires: getEnvVar('JWT_REFRESH_EXPIRES', '7d'),
  bcryptRounds: getEnvVarAsNumber('BCRYPT_ROUNDS', 12),
  rateLimitWindowMs: getEnvVarAsNumber('RATE_LIMIT_WINDOW_MS', 60000),
  rateLimitMax: getEnvVarAsNumber('RATE_LIMIT_MAX', 100)
}

export const isProduction = env.nodeEnv === 'production'
export const isDevelopment = env.nodeEnv === 'development'
export const isTest = env.nodeEnv === 'test'
