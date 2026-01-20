---
description: Sync documentation from source-of-truth. Update README, CONTRIB, and RUNBOOK from package.json and .env.example.
---

# Update Documentation Command

Sync documentation from source-of-truth.

## What This Command Does

1. Read package.json scripts section
   - Generate scripts reference table
   - Include descriptions from comments

2. Read .env.example
   - Extract all environment variables
   - Document purpose and format

3. Generate docs/CONTRIB.md with:
   - Development workflow
   - Available scripts
   - Environment setup
   - Testing procedures

4. Generate docs/RUNBOOK.md with:
   - Deployment procedures
   - Monitoring and alerts
   - Common issues and fixes
   - Rollback procedures

5. Identify obsolete documentation:
   - Find docs not modified in 90+ days
   - List for manual review

6. Show diff summary

## Source of Truth

- `package.json` - Scripts and dependencies
- `.env.example` - Environment variables
- Actual codebase - Architecture and structure

## README Template

```markdown
# Project Name

Brief description

## Setup

```bash
npm install
cp .env.example .env.local
npm run dev
```

## Architecture

See [docs/CODEMAPS/INDEX.md](docs/CODEMAPS/INDEX.md)

## Features

- [Feature 1] - Description
- [Feature 2] - Description

## Documentation

- [Setup Guide](docs/GUIDES/setup.md)
- [API Reference](docs/GUIDES/api.md)
- [Architecture](docs/CODEMAPS/INDEX.md)
```

## Quality Checklist

Before committing documentation:
- [ ] All file paths verified to exist
- [ ] Code examples compile/run
- [ ] Links tested
- [ ] Freshness timestamps updated
- [ ] No obsolete references

## Related Agents

This command invokes the `doc-updater` agent located at:
`.claude/agents/doc-updater.md`
