# Hooks System

## Hook Types

- **PreToolUse**: Before tool execution (validation, parameter modification)
- **PostToolUse**: After tool execution (auto-format, checks)
- **Stop**: When session ends (final verification)

## Current Hooks (in .claude/hooks.json)

### PreToolUse

1. **Dev Server Blocker**: Blocks `npm run dev` outside tmux
   - Ensures you can access logs
   - Suggests tmux command

2. **Tmux Reminder**: Suggests tmux for long-running commands
   - npm, pnpm, yarn, cargo, docker, pytest, playwright
   - Non-blocking, just a reminder

3. **Git Push Review**: Pauses before git push
   - Allows review of changes
   - User can Ctrl+C to abort

4. **Doc File Blocker**: Blocks unnecessary .md/.txt files
   - Whitelists README, CLAUDE, AGENTS, CONTRIBUTING
   - Keeps documentation consolidated

### PostToolUse

1. **PR Logging**: Logs PR URL after creation
   - Extracts URL from `gh pr create` output
   - Shows review command

2. **Prettier Formatting**: Auto-formats JS/TS files
   - Runs after Edit on .ts/.tsx/.js/.jsx
   - Keeps code consistent

3. **Console.log Warning**: Warns about console.log
   - Checks edited files for console.log
   - Reminds to remove before commit

### Stop

1. **Console.log Audit**: Final check for console.log
   - Checks all modified files
   - Last warning before session ends

## Auto-Accept Permissions

Use with caution:
- Enable for trusted, well-defined plans
- Disable for exploratory work
- Configure `allowedTools` in settings

## TodoWrite Best Practices

Use TodoWrite tool to:
- Track progress on multi-step tasks
- Verify understanding of instructions
- Enable real-time steering
- Show granular implementation steps

Todo list reveals:
- Out of order steps
- Missing items
- Extra unnecessary items
- Wrong granularity
- Misinterpreted requirements

## Creating Custom Hooks

Add to `.claude/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "tool == \"Bash\" && tool_input.command matches \"pattern\"",
        "hooks": [
          {
            "type": "command",
            "command": "#!/bin/bash\n# Your script here"
          }
        ],
        "description": "What this hook does"
      }
    ]
  }
}
```
