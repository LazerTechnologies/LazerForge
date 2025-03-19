# Contributing

The goal of this repo is to provide not only an optimized configuration for experienced Solidity developers but to also serve as a starting point for developers who are new to Foundry or Solidity. We're looking in particular for the following Contributions to the `main` branch:

- Reusable utility and library contracts that add value to LazerForge as a template
- Expanded [tutorials](/lazerTutorial/README.md) on smart contract development and testing in foundry
- Helpful test examples

## Branch Structure and Guidelines

### Branch Overview

This repository maintains two primary branches with distinct purposes:

1. **`main` Branch**

   - Includes all tutorials, examples, and additional dependencies
   - Serves as the primary development and reference branch

2. **`minimal` Branch**
   - Provides a stripped-down, essential version of the project
   - Excludes tutorials, extensive examples, and non-core dependencies
   - Designed for users who need a lightweight, core implementation

### Branch Preservation Guidelines

- **Do Not Merge Branches Directly**
  - The `main` and `minimal` branches are intentionally kept separate
  - Direct merges between these branches are prohibited
  - Branch protection rules are in place to prevent accidental merging

### Config Contributions

- If you want to contribute changes that should apply to both branches:
  1. Make changes in the `main` branch first
  2. Carefully cherry-pick or selectively apply changes to the `minimal` branch
  3. Ensure that the `minimal` branch remains lean and focused

### Pulling Updates

- To update the `minimal` branch with specific changes from `main`:

  ```bash
  # Fetch changes
  git fetch origin main

  # Selectively checkout specific files
  git checkout origin/main -- foundry.toml
  git checkout origin/main -- README.md
  git checkout origin/main -- sample.env

  # Commit only the desired changes
  git commit -m "Selectively update minimal branch"
  ```

### Questions or Clarifications

If you have any questions about the branch structure or contribution process, please open an issue in the repository.
