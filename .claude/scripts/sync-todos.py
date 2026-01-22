#!/usr/bin/env python3
"""
sync-todos.py - Sync TODOs between session and project level
Enables TODO persistence across different conversation sessions
Supports multi-user collaboration with intelligent merge strategies
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime
import hashlib

# Constants
PROJECT_TODO_FILE = Path(".specify/todos.json")
SESSION_TODO_DIR = Path.home() / ".claude" / "todos"
HISTORY_DIR = Path(".specify/todo-history")


def get_latest_session_todo():
    """Get the most recent session TODO file."""
    if not SESSION_TODO_DIR.exists():
        return None

    # Find all JSON files and sort by modification time
    json_files = list(SESSION_TODO_DIR.glob("*.json"))
    if not json_files:
        return None

    # Get the most recently modified file
    latest_file = max(json_files, key=lambda f: f.stat().st_mtime)
    return latest_file


def get_todo_hash(todo):
    """Generate unique hash for a TODO based on its content."""
    # Use content as unique identifier
    content = todo.get('content', '')
    return hashlib.md5(content.encode()).hexdigest()[:8]


def merge_todos(existing_todos, new_todos, session_id):
    """
    Intelligently merge TODOs from different sessions.

    Strategy:
    1. Preserve completed items from both sessions
    2. For duplicates (same content):
       - Use the more advanced status (completed > in_progress > pending)
       - Add contributor metadata
    3. Add new items from current session
    4. Track who contributed what
    """
    # Create hash maps for efficient lookup
    existing_map = {get_todo_hash(t): t for t in existing_todos}
    new_map = {get_todo_hash(t): t for t in new_todos}

    merged = []
    seen_hashes = set()

    # Process existing TODOs
    for hash_id, existing_todo in existing_map.items():
        if hash_id in new_map:
            # Same TODO exists in both - merge with status priority
            new_todo = new_map[hash_id]

            # Status priority: completed > in_progress > pending
            status_priority = {'completed': 3, 'in_progress': 2, 'pending': 1}
            existing_priority = status_priority.get(existing_todo.get('status'), 0)
            new_priority = status_priority.get(new_todo.get('status'), 0)

            # Use the more advanced status
            if new_priority > existing_priority:
                merged_todo = {**new_todo}
                merged_todo['updated_by'] = session_id
                merged_todo['updated_at'] = datetime.now().isoformat()
            else:
                merged_todo = {**existing_todo}

            # Track contributors
            contributors = existing_todo.get('contributors', [])
            if session_id not in contributors:
                contributors.append(session_id)
            merged_todo['contributors'] = contributors

            merged.append(merged_todo)
            seen_hashes.add(hash_id)
        else:
            # Keep existing TODO (may have been from another user)
            merged.append(existing_todo)
            seen_hashes.add(hash_id)

    # Add new TODOs that weren't in existing
    for hash_id, new_todo in new_map.items():
        if hash_id not in seen_hashes:
            new_todo['created_by'] = session_id
            new_todo['created_at'] = datetime.now().isoformat()
            new_todo['contributors'] = [session_id]
            merged.append(new_todo)

    return merged


def save_history(todos, session_id):
    """Save a historical snapshot of TODOs."""
    HISTORY_DIR.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    history_file = HISTORY_DIR / f"{timestamp}_{session_id[:8]}.json"

    with open(history_file, 'w') as f:
        json.dump({
            'timestamp': datetime.now().isoformat(),
            'session': session_id,
            'todos': todos
        }, f, indent=2)


def save_to_project(session_todo_file):
    """Save session TODOs to project level with multi-user merge support."""
    if not session_todo_file or not session_todo_file.exists():
        print("⚠️  No session TODOs found to save")
        return False

    try:
        # Read session TODOs
        with open(session_todo_file, 'r') as f:
            new_todos = json.load(f)

        session_id = session_todo_file.stem

        # Ensure .specify directory exists
        PROJECT_TODO_FILE.parent.mkdir(parents=True, exist_ok=True)

        # Check if project TODOs already exist
        existing_todos = []
        existing_sessions = []
        if PROJECT_TODO_FILE.exists():
            try:
                with open(PROJECT_TODO_FILE, 'r') as f:
                    existing_data = json.load(f)
                    existing_todos = existing_data.get('todos', [])
                    existing_sessions = existing_data.get('sessions', [])
            except (json.JSONDecodeError, IOError):
                print("⚠️  Existing TODO file corrupted, will overwrite")

        # Merge TODOs intelligently
        if existing_todos:
            print(f"ℹ️  Merging with {len(existing_todos)} existing TODOs...")
            merged_todos = merge_todos(existing_todos, new_todos, session_id)
            print(f"✓ Merged: {len(merged_todos)} total TODOs")
        else:
            merged_todos = new_todos
            # Add metadata to new TODOs
            for todo in merged_todos:
                todo['created_by'] = session_id
                todo['created_at'] = datetime.now().isoformat()
                todo['contributors'] = [session_id]

        # Track all contributing sessions
        if session_id not in existing_sessions:
            existing_sessions.append(session_id)

        # Save history snapshot
        save_history(merged_todos, session_id)

        # Save merged data with metadata
        project_data = {
            "last_updated": datetime.now().isoformat(),
            "last_session": session_id,
            "sessions": existing_sessions,
            "project": Path.cwd().name,
            "todos": merged_todos,
            "collaboration": {
                "total_sessions": len(existing_sessions),
                "last_contributor": session_id[:8]
            }
        }

        with open(PROJECT_TODO_FILE, 'w') as f:
            json.dump(project_data, f, indent=2)

        print(f"✓ TODOs saved to {PROJECT_TODO_FILE}")
        print(f"ℹ️  {len(existing_sessions)} session(s) have contributed")
        return True

    except (json.JSONDecodeError, IOError, OSError) as e:
        print(f"❌ Error saving TODOs: {e}")
        return False


def load_from_project():
    """Load TODOs from project level."""
    if not PROJECT_TODO_FILE.exists():
        print("⚠️  No project TODOs found")
        return None

    try:
        with open(PROJECT_TODO_FILE, 'r') as f:
            data = json.load(f)

        todos = data.get('todos', [])
        if not todos:
            print("⚠️  Project TODO file is empty")
            return None

        return data

    except (json.JSONDecodeError, IOError) as e:
        print(f"❌ Error loading TODOs: {e}")
        return None


def display_todos(data):
    """Display TODO list with statistics."""
    if not data:
        return

    todos = data['todos']

    print("╔════════════════════════════════════════════════════════════════╗")
    print("║              LOADING TODOs FROM PROJECT LEVEL                  ║")
    print("╠════════════════════════════════════════════════════════════════╣")
    print(f"║  Project: {data['project']}")
    print(f"║  Last Updated: {data['last_updated']}")
    print("╠════════════════════════════════════════════════════════════════╣")

    # Count tasks by status
    completed = sum(1 for t in todos if t.get('status') == 'completed')
    in_progress = sum(1 for t in todos if t.get('status') == 'in_progress')
    pending = sum(1 for t in todos if t.get('status') == 'pending')

    print(f"║  Completed: {completed} | In Progress: {in_progress} | Pending: {pending}")
    print("╠════════════════════════════════════════════════════════════════╣")
    print("║  TODO List:")

    # Display each TODO with status (limit to 10)
    for i, todo in enumerate(todos[:10], 1):
        status = todo.get('status', 'unknown')
        content = todo.get('content', 'No description')
        # Truncate long content
        if len(content) > 50:
            content = content[:47] + "..."
        print(f"║  [{status}] {content}")

    if len(todos) > 10:
        print(f"║  ... and {len(todos) - 10} more")

    print("╚════════════════════════════════════════════════════════════════╝")


def show_status():
    """Show project TODO status."""
    if PROJECT_TODO_FILE.exists():
        try:
            with open(PROJECT_TODO_FILE, 'r') as f:
                data = json.load(f)

            print("✓ Project TODOs exist")
            print(f"  Last updated: {data.get('last_updated', 'unknown')}")
            print(f"  Total tasks: {len(data.get('todos', []))}")

            # Count by status
            todos = data.get('todos', [])
            completed = sum(1 for t in todos if t.get('status') == 'completed')
            in_progress = sum(1 for t in todos if t.get('status') == 'in_progress')
            pending = sum(1 for t in todos if t.get('status') == 'pending')

            print(f"  Completed: {completed} | In Progress: {in_progress} | Pending: {pending}")

        except (json.JSONDecodeError, IOError) as e:
            print(f"⚠️  Project TODOs file is corrupted: {e}")
    else:
        print("✗ No project TODOs found")
        print("  Run: python .claude/scripts/sync-todos.py save")


def main():
    """Main entry point."""
    command = sys.argv[1] if len(sys.argv) > 1 else "save"

    if command == "save":
        print("╔════════════════════════════════════════════════════════════════╗")
        print("║              SAVING TODOs TO PROJECT LEVEL                     ║")
        print("╠════════════════════════════════════════════════════════════════╣")

        latest_session_todo = get_latest_session_todo()

        if latest_session_todo:
            print(f"║  Source: {latest_session_todo.name}")
            save_to_project(latest_session_todo)
        else:
            print("║  No session TODOs found")

        print("╚════════════════════════════════════════════════════════════════╝")

    elif command == "load":
        data = load_from_project()
        if data:
            display_todos(data)

    elif command == "status":
        show_status()

    else:
        print("Usage: python sync-todos.py {save|load|status}")
        print("")
        print("Commands:")
        print("  save   - Save current session TODOs to project level")
        print("  load   - Load and display project TODOs")
        print("  status - Check project TODO status")
        sys.exit(1)


if __name__ == "__main__":
    main()
