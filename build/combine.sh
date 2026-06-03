#!/usr/bin/env bash
set -euo pipefail

target="combined"
base="main"

if ! git diff --quiet --ignore-submodules -- && ! git diff --cached --quiet --ignore-submodules --; then
  echo "Error: working tree is dirty. Commit or stash changes before running this script."
  exit 1
fi

if git rev-parse --verify --quiet "refs/heads/$target"; then
  git checkout "$target"
else
  git checkout "$base"
  git checkout -b "$target"
fi

# 1. Exit early if no branches are provided
if [ $# -eq 0 ]; then
    echo "Error: No branches provided."
    echo "Usage: $0 branch1 branch2 branch3..."
    exit 1
fi

# 3. Loop through every parameter passed
for BRANCH in "$@"; do
    echo "🔄 Attempting to merge: $BRANCH..."

    # Check if the target exists locally or remotely
    if ! git rev-parse --verify --quiet "refs/heads/$BRANCH" &>/dev/null; then
        echo "❌ Error: Branch '$BRANCH' does not exist. Skipping."
        continue
    fi

    # Run the merge command
    if git merge "$BRANCH" --no-ff --no-edit; then
        echo "✅ Successfully merged: $BRANCH"
    else
        echo "❌ Conflict detected while merging: $BRANCH"
        echo "Stopping script so you can fix the conflict."
        echo "Run 'git merge --abort' if you want to undo this step."
        exit 1
    fi
done

echo "🎉 All specified branches merged successfully into [$target]!"
