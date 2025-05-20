#!/bin/bash
# sync-to-minimal.sh

# Update local branches
git fetch origin
git checkout sync-branch
git reset --hard origin/main

# Push to sync branch
git push -f origin sync-branch

# Open PR creation page (GitHub example)
REPO_URL=$(git remote get-url origin | sed 's/\.git$//' | sed 's/git@github.com:/https:\/\/github.com\//')
open "$REPO_URL/compare/minimal...sync-branch?expand=1"