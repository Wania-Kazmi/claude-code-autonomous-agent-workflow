#!/bin/bash
# init-project-branch.sh - Initialize project with feature branch
# Called automatically when starting autonomous workflow

set -e

PROJECT_NAME="${1:-$(basename $(pwd))}"
BRANCH_NAME="feature/${PROJECT_NAME}"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           PROJECT INITIALIZATION - BRANCH SETUP                 ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not a git repository. Initializing..."
    git init
    echo "✓ Git repository initialized"
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# Check if we're on main/master
if [[ "$CURRENT_BRANCH" == "main" ]] || [[ "$CURRENT_BRANCH" == "master" ]] || [[ -z "$CURRENT_BRANCH" ]]; then
    echo "📍 Current branch: ${CURRENT_BRANCH:-<none>}"
    echo ""

    # Check if feature branch already exists
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        echo "⚠️  Branch '$BRANCH_NAME' already exists"
        echo "   Switching to existing branch..."
        git checkout "$BRANCH_NAME"
        echo "✓ Switched to $BRANCH_NAME"
    else
        echo "🌿 Creating feature branch: $BRANCH_NAME"
        git checkout -b "$BRANCH_NAME"
        echo "✓ Created and switched to $BRANCH_NAME"

        # Check if there's a remote configured
        if git remote | grep -q "origin"; then
            echo ""
            echo "📤 Setting up remote tracking..."
            # Only push if there are commits
            if git log -1 > /dev/null 2>&1; then
                git push -u origin "$BRANCH_NAME" 2>/dev/null || {
                    echo "⚠️  Remote push will be done on first commit"
                }
            else
                echo "⚠️  No commits yet - will push on first commit"
            fi
        else
            echo ""
            echo "⚠️  No remote 'origin' configured"
            echo "   Add remote with: git remote add origin <url>"
        fi
    fi
else
    echo "✓ Already on feature branch: $CURRENT_BRANCH"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║               BRANCH SETUP COMPLETE                             ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Current Branch: $(git branch --show-current)"
echo "║  Ready for autonomous workflow                                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
