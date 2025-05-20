#!/bin/bash
# sync-to-minimal.sh

# Update local branches
git fetch origin

# Check if sync branch exists, create if it doesn't
if ! git show-ref --verify --quiet refs/heads/sync-branch; then
  echo "Creating sync-branch..."
  git checkout -b sync-branch
else
  echo "Checking out existing sync-branch..."
  git checkout sync-branch
fi

# Reset to main
git reset --hard origin/main
echo "Reset sync-branch to match origin/main"

# Push to sync branch
git push -f origin sync-branch
echo "Pushed sync-branch to remote"

# Open PR creation page (GitHub example)
REPO_URL=$(git remote get-url origin | sed 's/\.git$//' | sed 's/git@github.com:/https:\/\/github.com\//')
echo "Opening PR creation page..."
open "$REPO_URL/compare/minimal...sync-branch?expand=1"

echo "Done! Please review and create the PR from sync-branch to minimal"