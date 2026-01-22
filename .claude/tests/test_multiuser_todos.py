#!/usr/bin/env python3
"""
Test suite for multi-user TODO collaboration features.

Tests the intelligent merge logic, contributor tracking, and conflict resolution.
"""

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from datetime import datetime
import hashlib


# Helper functions (duplicated from sync-todos.py for testing)
def get_todo_hash(todo):
    """Generate unique hash for a TODO based on its content."""
    content = todo.get('content', '')
    return hashlib.md5(content.encode()).hexdigest()[:8]


def merge_todos(existing_todos, new_todos, session_id):
    """Intelligently merge TODOs from different sessions."""
    existing_map = {get_todo_hash(t): t for t in existing_todos}
    new_map = {get_todo_hash(t): t for t in new_todos}

    merged = []
    seen_hashes = set()

    # Process existing TODOs
    for hash_id, existing_todo in existing_map.items():
        if hash_id in new_map:
            new_todo = new_map[hash_id]

            # Status priority
            status_priority = {'completed': 3, 'in_progress': 2, 'pending': 1}
            existing_priority = status_priority.get(existing_todo.get('status'), 0)
            new_priority = status_priority.get(new_todo.get('status'), 0)

            if new_priority > existing_priority:
                merged_todo = {**new_todo}
                merged_todo['updated_by'] = session_id
                merged_todo['updated_at'] = datetime.now().isoformat()
            else:
                merged_todo = {**existing_todo}

            contributors = existing_todo.get('contributors', [])
            if session_id not in contributors:
                contributors.append(session_id)
            merged_todo['contributors'] = contributors

            merged.append(merged_todo)
            seen_hashes.add(hash_id)
        else:
            merged.append(existing_todo)
            seen_hashes.add(hash_id)

    # Add new TODOs
    for hash_id, new_todo in new_map.items():
        if hash_id not in seen_hashes:
            new_todo['created_by'] = session_id
            new_todo['created_at'] = datetime.now().isoformat()
            new_todo['contributors'] = [session_id]
            merged.append(new_todo)

    return merged


def save_history(todos, session_id, history_dir):
    """Save historical snapshot."""
    history_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    history_file = history_dir / f"{timestamp}_{session_id[:8]}.json"

    with open(history_file, 'w') as f:
        json.dump({
            'timestamp': datetime.now().isoformat(),
            'session': session_id,
            'todos': todos
        }, f, indent=2)


class TestTodoHash(unittest.TestCase):
    """Test TODO hashing for duplicate detection."""

    def test_same_content_same_hash(self):
        """Same content should produce same hash."""
        todo1 = {"content": "Implement login API", "status": "pending"}
        todo2 = {"content": "Implement login API", "status": "completed"}

        self.assertEqual(get_todo_hash(todo1), get_todo_hash(todo2))

    def test_different_content_different_hash(self):
        """Different content should produce different hash."""
        todo1 = {"content": "Implement login API", "status": "pending"}
        todo2 = {"content": "Add password hashing", "status": "pending"}

        self.assertNotEqual(get_todo_hash(todo1), get_todo_hash(todo2))

    def test_empty_content_handling(self):
        """Empty content should be handled gracefully."""
        todo = {"status": "pending"}  # No content field
        hash_result = get_todo_hash(todo)

        self.assertIsNotNone(hash_result)
        self.assertIsInstance(hash_result, str)


class TestMergeTodos(unittest.TestCase):
    """Test intelligent TODO merging logic."""

    def setUp(self):
        """Set up test session IDs."""
        self.session_a = "session-a-12345"
        self.session_b = "session-b-67890"

    def test_merge_empty_lists(self):
        """Merging empty lists should return empty list."""
        result = merge_todos([], [], self.session_a)
        self.assertEqual(result, [])

    def test_merge_with_empty_existing(self):
        """Merging with empty existing should add all new items."""
        new_todos = [
            {"content": "Task 1", "status": "pending"},
            {"content": "Task 2", "status": "pending"}
        ]

        result = merge_todos([], new_todos, self.session_a)

        self.assertEqual(len(result), 2)
        # Check that metadata was added
        for todo in result:
            self.assertIn('created_by', todo)
            self.assertIn('contributors', todo)
            self.assertEqual(todo['created_by'], self.session_a)
            self.assertIn(self.session_a, todo['contributors'])

    def test_merge_with_empty_new(self):
        """Merging with empty new should keep existing items."""
        existing_todos = [
            {"content": "Task 1", "status": "completed"},
            {"content": "Task 2", "status": "in_progress"}
        ]

        result = merge_todos(existing_todos, [], self.session_a)

        self.assertEqual(len(result), 2)
        self.assertEqual(result[0]['content'], "Task 1")
        self.assertEqual(result[1]['content'], "Task 2")

    def test_merge_no_duplicates(self):
        """Merging with no duplicates should combine all items."""
        existing_todos = [
            {"content": "Task 1", "status": "completed"}
        ]
        new_todos = [
            {"content": "Task 2", "status": "pending"}
        ]

        result = merge_todos(existing_todos, new_todos, self.session_b)

        self.assertEqual(len(result), 2)
        contents = [t['content'] for t in result]
        self.assertIn("Task 1", contents)
        self.assertIn("Task 2", contents)

    def test_merge_with_duplicate_status_upgrade(self):
        """Duplicate TODO with higher status should win."""
        existing_todos = [
            {"content": "Implement login API", "status": "pending"}
        ]
        new_todos = [
            {"content": "Implement login API", "status": "completed"}
        ]

        result = merge_todos(existing_todos, new_todos, self.session_b)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]['status'], "completed")
        self.assertEqual(result[0]['updated_by'], self.session_b)

    def test_merge_with_duplicate_status_downgrade(self):
        """Duplicate TODO with lower status should not override."""
        existing_todos = [
            {"content": "Implement login API", "status": "completed"}
        ]
        new_todos = [
            {"content": "Implement login API", "status": "pending"}
        ]

        result = merge_todos(existing_todos, new_todos, self.session_b)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]['status'], "completed")
        # Should NOT have updated_by since status didn't change
        self.assertNotIn('updated_by', result[0])

    def test_contributor_tracking(self):
        """Contributors should be tracked across merges."""
        existing_todos = [
            {
                "content": "Implement login API",
                "status": "in_progress",
                "contributors": [self.session_a]
            }
        ]
        new_todos = [
            {"content": "Implement login API", "status": "completed"}
        ]

        result = merge_todos(existing_todos, new_todos, self.session_b)

        self.assertEqual(len(result), 1)
        contributors = result[0]['contributors']
        self.assertIn(self.session_a, contributors)
        self.assertIn(self.session_b, contributors)
        self.assertEqual(len(contributors), 2)

    def test_status_priority_completed_over_in_progress(self):
        """Completed status should win over in_progress."""
        existing = [{"content": "Task", "status": "in_progress"}]
        new = [{"content": "Task", "status": "completed"}]

        result = merge_todos(existing, new, self.session_b)

        self.assertEqual(result[0]['status'], "completed")

    def test_status_priority_in_progress_over_pending(self):
        """In progress status should win over pending."""
        existing = [{"content": "Task", "status": "pending"}]
        new = [{"content": "Task", "status": "in_progress"}]

        result = merge_todos(existing, new, self.session_b)

        self.assertEqual(result[0]['status'], "in_progress")

    def test_complex_merge_scenario(self):
        """Test complex scenario with multiple TODOs and updates."""
        existing_todos = [
            {"content": "Task A", "status": "completed", "contributors": [self.session_a]},
            {"content": "Task B", "status": "in_progress", "contributors": [self.session_a]},
            {"content": "Task C", "status": "pending", "contributors": [self.session_a]}
        ]
        new_todos = [
            {"content": "Task B", "status": "completed"},  # Upgrade
            {"content": "Task C", "status": "in_progress"},  # Upgrade
            {"content": "Task D", "status": "pending"}  # New
        ]

        result = merge_todos(existing_todos, new_todos, self.session_b)

        # Should have 4 TODOs (A, B, C, D)
        self.assertEqual(len(result), 4)

        # Find each task
        task_map = {t['content']: t for t in result}

        # Task A should be unchanged
        self.assertEqual(task_map['Task A']['status'], "completed")

        # Task B should be upgraded to completed
        self.assertEqual(task_map['Task B']['status'], "completed")
        self.assertIn(self.session_a, task_map['Task B']['contributors'])
        self.assertIn(self.session_b, task_map['Task B']['contributors'])

        # Task C should be upgraded to in_progress
        self.assertEqual(task_map['Task C']['status'], "in_progress")
        self.assertIn(self.session_a, task_map['Task C']['contributors'])
        self.assertIn(self.session_b, task_map['Task C']['contributors'])

        # Task D should be new
        self.assertEqual(task_map['Task D']['status'], "pending")
        self.assertEqual(task_map['Task D']['created_by'], self.session_b)


class TestSaveHistory(unittest.TestCase):
    """Test historical snapshot functionality."""

    def test_save_history_creates_file(self):
        """Saving history should create a snapshot file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            history_dir = Path(tmpdir)
            todos = [
                {"content": "Task 1", "status": "completed"},
                {"content": "Task 2", "status": "pending"}
            ]
            session_id = "test-session-12345"

            save_history(todos, session_id, history_dir)

            # Check that file was created
            history_files = list(history_dir.glob("*.json"))
            self.assertEqual(len(history_files), 1)

            # Verify file content
            with open(history_files[0]) as f:
                snapshot = json.load(f)

            self.assertIn('timestamp', snapshot)
            self.assertIn('session', snapshot)
            self.assertIn('todos', snapshot)
            self.assertEqual(snapshot['session'], session_id)
            self.assertEqual(len(snapshot['todos']), 2)


class TestIntegration(unittest.TestCase):
    """Integration tests for multi-user scenarios."""

    def test_three_way_collaboration(self):
        """Test three different developers collaborating."""
        session_a = "developer-a-001"
        session_b = "developer-b-002"
        session_c = "developer-c-003"

        # Developer A creates initial TODOs
        todos_a = [
            {"content": "Setup project", "status": "completed"},
            {"content": "Implement auth", "status": "in_progress"},
            {"content": "Add tests", "status": "pending"}
        ]

        # Developer B continues work
        todos_b = [
            {"content": "Implement auth", "status": "completed"},  # Completes A's work
            {"content": "Add tests", "status": "in_progress"},  # Starts tests
            {"content": "Setup database", "status": "pending"}  # Adds new task
        ]

        # Developer C adds more
        todos_c = [
            {"content": "Add tests", "status": "completed"},  # Completes tests
            {"content": "Setup database", "status": "in_progress"},  # Starts DB
            {"content": "Deploy to prod", "status": "pending"}  # Adds deployment
        ]

        # Simulate progressive merges
        merge_1 = merge_todos([], todos_a, session_a)
        merge_2 = merge_todos(merge_1, todos_b, session_b)
        merge_3 = merge_todos(merge_2, todos_c, session_c)

        # Final result should have 5 tasks
        self.assertEqual(len(merge_3), 5)

        # Check final statuses
        task_map = {t['content']: t for t in merge_3}

        self.assertEqual(task_map['Setup project']['status'], "completed")
        self.assertEqual(task_map['Implement auth']['status'], "completed")
        self.assertEqual(task_map['Add tests']['status'], "completed")
        self.assertEqual(task_map['Setup database']['status'], "in_progress")
        self.assertEqual(task_map['Deploy to prod']['status'], "pending")

        # Check contributors
        self.assertEqual(len(task_map['Implement auth']['contributors']), 2)
        self.assertIn(session_a, task_map['Implement auth']['contributors'])
        self.assertIn(session_b, task_map['Implement auth']['contributors'])

        self.assertEqual(len(task_map['Add tests']['contributors']), 3)


if __name__ == '__main__':
    unittest.main()
