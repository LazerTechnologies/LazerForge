#!/bin/bash
# sync-to-main.sh (for minimal branch)

# Update local branches
git fetch origin

# Check if sync branch exists, create if it doesn't
if ! git show-ref --verify --quiet refs/heads/sync-branch-reverse; then
  git checkout -b sync-branch-reverse
else
  git checkout sync-branch-reverse
fi

# Reset to minimal
git reset --hard origin/minimal

# Push to sync branch
git push -f origin sync-branch-reverse

# Open PR creation page
REPO_URL=$(git remote get-url origin | sed 's/\.git$//' | sed 's/git@github.com:/https:\/\/github.com\//')
open "$REPO_URL/compare/main...sync-branch-reverse?expand=1"