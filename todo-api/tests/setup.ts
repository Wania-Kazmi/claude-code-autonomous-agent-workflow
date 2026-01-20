// Set test environment variables before any imports
process.env.NODE_ENV = 'test'
process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/todoapi_test'
process.env.JWT_ACCESS_SECRET = 'test-access-secret-at-least-32-characters'
process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-at-least-32-characters'
process.env.JWT_ACCESS_EXPIRES = '15m'
process.env.JWT_REFRESH_EXPIRES = '7d'
process.env.BCRYPT_ROUNDS = '4' // Lower rounds for faster tests
process.env.RATE_LIMIT_WINDOW_MS = '60000'
process.env.RATE_LIMIT_MAX = '1000' // Higher limit for tests

// Increase timeout for async operations
jest.setTimeout(30000)
