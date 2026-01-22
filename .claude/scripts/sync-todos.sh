#!/bin/bash
# sync-todos.sh - Sync TODOs between session and project level
# Enables TODO persistence across different conversation sessions

set -e

PROJECT_TODO_FILE=".specify/todos.json"
SESSION_TODO_DIR="$HOME/.claude/todos"

# Function to get the latest session TODO file for current project
get_latest_session_todo() {
    # Get current project directory name (used in conversation context)
    local project_name=$(basename "$(pwd)")

    # Find the most recent TODO file in session directory
    find "$SESSION_TODO_DIR" -name "*.json" -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | \
        head -1 | \
        cut -d' ' -f2
}

# Function to save TODOs to project level
save_to_project() {
    local session_todo_file="$1"

    if [ -f "$session_todo_file" ] && [ -s "$session_todo_file" ]; then
        # Ensure .specify directory exists
        mkdir -p .specify

        # Copy session TODOs to project level with metadata
        cat > "$PROJECT_TODO_FILE" <<EOF
{
  "last_updated": "$(date -Iseconds)",
  "source_session": "$(basename "$session_todo_file" .json)",
  "project": "$(basename "$(pwd)")",
  "todos": $(cat "$session_todo_file")
}
EOF

        echo "✓ TODOs saved to $PROJECT_TODO_FILE"
        return 0
    else
        echo "⚠️  No session TODOs found to save"
        return 1
    fi
}

# Function to load TODOs from project level
load_from_project() {
    if [ -f "$PROJECT_TODO_FILE" ]; then
        # Extract just the todos array
        local todos=$(jq -r '.todos' "$PROJECT_TODO_FILE" 2>/dev/null)

        if [ "$todos" != "null" ] && [ -n "$todos" ]; then
            echo "✓ Found project TODOs from: $(jq -r '.last_updated' "$PROJECT_TODO_FILE")"
            echo "$todos"
            return 0
        fi
    fi

    echo "⚠️  No project TODOs found"
    return 1
}

# Main execution
case "${1:-save}" in
    save)
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              SAVING TODOs TO PROJECT LEVEL                     ║"
        echo "╠════════════════════════════════════════════════════════════════╣"

        latest_session_todo=$(get_latest_session_todo)

        if [ -n "$latest_session_todo" ]; then
            echo "║  Source: $(basename "$latest_session_todo")"
            save_to_project "$latest_session_todo"
        else
            echo "║  No session TODOs found"
        fi

        echo "╚════════════════════════════════════════════════════════════════╝"
        ;;

    load)
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              LOADING TODOs FROM PROJECT LEVEL                  ║"
        echo "╠════════════════════════════════════════════════════════════════╣"

        if todos=$(load_from_project); then
            echo "║  Project: $(jq -r '.project' "$PROJECT_TODO_FILE")"
            echo "║  Last Updated: $(jq -r '.last_updated' "$PROJECT_TODO_FILE")"
            echo "╠════════════════════════════════════════════════════════════════╣"

            # Count tasks by status
            completed=$(echo "$todos" | jq '[.[] | select(.status == "completed")] | length')
            in_progress=$(echo "$todos" | jq '[.[] | select(.status == "in_progress")] | length')
            pending=$(echo "$todos" | jq '[.[] | select(.status == "pending")] | length')

            echo "║  Completed: $completed | In Progress: $in_progress | Pending: $pending"
            echo "╠════════════════════════════════════════════════════════════════╣"
            echo "║  TODO List:"

            # Display each TODO with status
            echo "$todos" | jq -r '.[] | "║  [\(.status)] \(.content)"' | head -10

            if [ "$(echo "$todos" | jq 'length')" -gt 10 ]; then
                echo "║  ... and $(( $(echo "$todos" | jq 'length') - 10 )) more"
            fi
        fi

        echo "╚════════════════════════════════════════════════════════════════╝"
        ;;

    status)
        if [ -f "$PROJECT_TODO_FILE" ]; then
            echo "✓ Project TODOs exist"
            echo "  Last updated: $(jq -r '.last_updated' "$PROJECT_TODO_FILE")"
            echo "  Total tasks: $(jq '.todos | length' "$PROJECT_TODO_FILE")"
        else
            echo "✗ No project TODOs found"
            echo "  Run: bash .claude/scripts/sync-todos.sh save"
        fi
        ;;

    *)
        echo "Usage: $0 {save|load|status}"
        echo ""
        echo "Commands:"
        echo "  save   - Save current session TODOs to project level"
        echo "  load   - Load project TODOs (display only)"
        echo "  status - Check if project TODOs exist"
        exit 1
        ;;
esac
