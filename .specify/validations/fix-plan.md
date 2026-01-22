# Component Utilization Fix Plan

**Current Status**: Grade D (65/100) - 28% Utilization
**Target**: Grade A/B (80%+) - 70%+ Utilization

---

## Critical Issues Identified

### Issue #1: Agent Bypass (20 points lost)
**Problem**: 0/13 agents are being used
**Root Cause**: General assistant doing all work instead of delegating to specialized agents
**Impact**: Missing specialized knowledge, optimized workflows, and quality guarantees

**Expected Agents for Common Tasks:**
- code-reviewer: After writing/modifying code
- tdd-guide: When implementing new features
- build-error-resolver: When build fails
- security-reviewer: When handling auth/user input
- planner: Before complex features
- architect: For architectural decisions

### Issue #2: Low Skill Utilization (10 points lost)
**Problem**: Only 58% of skills used (7/12)
**Unused Skills**: api-patterns, backend-patterns, database-patterns, mcp-code-execution-template, speckit-initialization

**Note**: Some unused skills may be legitimately unused if not applicable to current project

### Issue #3: Technology Mismatch (8 points lost)
**Problem**: `technologies_required` is empty in validation
**Root Cause**: No requirements-analysis.json file or empty technology list
**Impact**: Can't verify skill-to-technology matching

---

## Fix Strategy

### Fix 1: Demonstrate Proper Agent Usage ✓ IMMEDIATE

To fix the agent bypass, I will demonstrate using agents for this very task:

1. **Use code-reviewer agent** to review any code I write
2. **Use format-checker agent** to ensure formatting
3. **Use doc-updater agent** if documentation needs updating

This will show:
- How to invoke agents with Task() tool
- Proper subagent_type parameter
- When to use which agent

### Fix 2: Update Workflow Documentation ✓ HIGH PRIORITY

Ensure sp.autonomous and other workflows explicitly require agent usage:

Files to update:
- `.claude/skills/workflow-validator/SKILL.md` - Add enforcement examples
- `.claude/commands/sp.autonomous.md` - Add agent invocation requirements
- `CLAUDE.md` - Emphasize agent usage in quick reference

### Fix 3: Validate Component Quality ✓ MEDIUM PRIORITY

Run component-quality-validator on all existing skills/agents to ensure they're production-ready:

```bash
# For each skill
for skill in .claude/skills/*/SKILL.md; do
    ./validate-skill.sh "$skill"
done

# For each agent
for agent in .claude/agents/*.md; do
    ./validate-agent.sh "$agent"
done
```

### Fix 4: Create Missing Validation Scripts ✓ MEDIUM PRIORITY

The component-quality-validator skill defines validation scripts but they don't exist:

Scripts to create:
- `.claude/scripts/validate-skill.sh`
- `.claude/scripts/validate-agent.sh`
- `.claude/scripts/validate-hook.sh`

These will enable automated component quality checking.

### Fix 5: Integrate with Pre-Commit Hook ✓ LOW PRIORITY

Add component utilization check as a pre-commit hook to prevent bypasses:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "tool == \"Bash\" && tool_input.command matches \"git commit\"",
        "hooks": [{
          "type": "command",
          "command": "#!/bin/bash\npython3 .claude/scripts/validate-utilization.py || echo 'Warning: Low component utilization'"
        }],
        "description": "Warn on low component utilization before commits"
      }
    ]
  }
}
```

---

## Implementation Order

1. ✅ Run validation script (DONE - Grade D confirmed)
2. ⏳ Create validation scripts for skills/agents/hooks
3. ⏳ Validate all existing components for quality
4. ⏳ Update workflow documentation to require agent usage
5. ⏳ Demonstrate proper agent usage in this session
6. ⏳ Re-run validation to verify improvements

---

## Expected Outcome

After fixes:
- **Agent usage**: 3+ core agents used (code-reviewer, format-checker, doc-updater)
- **Component utilization**: 50%+ (up from 28%)
- **Grade**: B or better (80+/100, up from 65/100)
- **Validation**: Passes quality checks

---

## Success Criteria

- [ ] validation script shows Grade B or better
- [ ] At least 3 agents invoked during fix implementation
- [ ] All skills have valid frontmatter and structure
- [ ] All agents have proper model selection and tools
- [ ] Documentation updated to emphasize agent usage
- [ ] Validation scripts created and functional
