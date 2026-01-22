#!/bin/bash
# resume-work.sh - Load project context when starting a new session
# Run this when you start a new conversation to restore TODOs

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              RESUMING WORK IN THIS PROJECT                     ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║"
echo "║  Project: $(basename "$(pwd)")"
echo "║"
echo "╠════════════════════════════════════════════════════════════════╣"

# Check if project has TODOs
if [ -f ".specify/todos.json" ]; then
    echo "║"
    echo "║  ✓ Found saved TODOs from previous session"
    echo "║"
    echo "╠════════════════════════════════════════════════════════════════╣"

    # Show TODO summary
    python3 .claude/scripts/sync-todos.py load

    echo ""
    echo "To restore these TODOs to your current session:"
    echo "  1. Copy the tasks above"
    echo "  2. Ask Claude: \"Please add these TODOs to our session\""
    echo "  3. Or use TodoWrite tool directly"
    echo ""
else
    echo "║"
    echo "║  ⓘ No saved TODOs found"
    echo "║  This is normal for new projects"
    echo "║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
fi

# Show recent activity
if [ -f ".claude/logs/activity.log" ]; then
    echo "Recent activity:"
    tail -5 .claude/logs/activity.log 2>/dev/null || echo "  No recent activity"
    echo ""
fi

echo "Ready to work! Your TODOs will be saved automatically when you end the session."
