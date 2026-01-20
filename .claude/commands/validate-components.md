---
description: Validate generated skills, agents, and hooks for production-readiness. Scores and grades A-F.
---

# /validate-components

Load and apply the component-quality-validator skill to validate generated components.

## Instructions

1. Read the component-quality-validator skill from `.claude/skills/component-quality-validator/SKILL.md`
2. Scan for generated components (skills, agents, hooks)
3. Score each component against quality criteria
4. Generate validation report with grades
5. Output APPROVED or REJECTED for each component

## Quality Criteria

### Skills
- Frontmatter valid (name, description, version)
- Has trigger keywords in description
- Has workflow/steps section
- Has code templates
- Has validation checklist

### Agents
- Model appropriate for task complexity
- Tools list is minimal
- Has clear instructions
- Has failure handling

### Hooks
- Valid JSON syntax
- Valid bash syntax
- Has description
- No conflicts

## Usage

```bash
# Validate all components
/validate-components

# Validate specific type
/validate-components type:skills
/validate-components type:agents
/validate-components type:hooks

# Validate specific component
/validate-components skill:express-patterns
```
