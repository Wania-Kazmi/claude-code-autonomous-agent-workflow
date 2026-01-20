# Security Guidelines

## Mandatory Security Checks

Before ANY commit:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized HTML)
- [ ] CSRF protection enabled
- [ ] Authentication/authorization verified
- [ ] Rate limiting on all endpoints
- [ ] Error messages don't leak sensitive data

## Secret Management

```typescript
// NEVER: Hardcoded secrets
const apiKey = "sk-proj-xxxxx"

// ALWAYS: Environment variables
const apiKey = process.env.OPENAI_API_KEY

if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

## OWASP Top 10 Checks

1. **Injection** - Parameterized queries, sanitized inputs
2. **Broken Authentication** - Strong password hashing, MFA
3. **Sensitive Data Exposure** - HTTPS, encrypted storage
4. **Broken Access Control** - Authorization on every route
5. **Security Misconfiguration** - Secure defaults, no debug in prod
6. **XSS** - Escape output, CSP headers
7. **Insecure Deserialization** - Validate before deserialize
8. **Components with Known Vulnerabilities** - `npm audit`
9. **Insufficient Logging** - Log security events
10. **SSRF** - Validate and whitelist URLs

## Security Response Protocol

If security issue found:
1. STOP immediately
2. Use **security-reviewer** agent
3. Fix CRITICAL issues before continuing
4. Rotate any exposed secrets
5. Review entire codebase for similar issues

## Agent Support

- **security-reviewer** - Use PROACTIVELY when handling user input, auth, or sensitive data
- **code-reviewer** - Checks for security issues in every review
