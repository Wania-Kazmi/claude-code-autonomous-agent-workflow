---
description: Analyze the codebase structure and update architecture documentation. Generate docs/CODEMAPS/*.
---

# Update Codemaps Command

Analyze the codebase structure and update architecture documentation.

## What This Command Does

1. Scan all source files for imports, exports, and dependencies

2. Generate token-lean codemaps:
   - `docs/CODEMAPS/INDEX.md` - Overview of all areas
   - `docs/CODEMAPS/frontend.md` - Frontend structure
   - `docs/CODEMAPS/backend.md` - Backend/API structure
   - `docs/CODEMAPS/database.md` - Database schema
   - `docs/CODEMAPS/integrations.md` - External services

3. Calculate diff percentage from previous version

4. If changes > 30%, request user approval before updating

5. Add freshness timestamp to each codemap

## Codemap Format

```markdown
# [Area] Codemap

**Last Updated:** YYYY-MM-DD
**Entry Points:** list of main files

## Architecture

[ASCII diagram of component relationships]

## Key Modules

| Module | Purpose | Exports | Dependencies |
|--------|---------|---------|--------------|
| ... | ... | ... | ... |

## Data Flow

[Description of how data flows through this area]

## External Dependencies

- package-name - Purpose, Version
```

## Example Frontend Codemap

```markdown
# Frontend Architecture

**Last Updated:** 2025-01-20
**Framework:** Next.js 15 (App Router)
**Entry Point:** src/app/layout.tsx

## Structure

src/
├── app/                # Next.js App Router
│   ├── api/           # API routes
│   └── (pages)/       # Page routes
├── components/        # React components
├── hooks/             # Custom hooks
└── lib/               # Utilities

## Key Components

| Component | Purpose | Location |
|-----------|---------|----------|
| Header | Navigation | components/Header.tsx |
| Layout | Page wrapper | components/Layout.tsx |
```

## Best Practices

- Single Source of Truth - Generate from code
- Freshness Timestamps - Always include last updated date
- Token Efficiency - Keep codemaps under 500 lines each

## Related Agents

This command invokes the `doc-updater` agent located at:
`.claude/agents/doc-updater.md`
