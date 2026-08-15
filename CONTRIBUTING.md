# Contributing

The goal of this repo is to provide not only an optimized configuration for experienced Solidity developers but to also serve as a starting point for developers who are new to Foundry or Solidity. We're looking in particular for the following Contributions to the `main` branch:

- Reusable utility and library contracts that add value to LazerForge as a template
- Expanded [tutorials](/lazerTutorial/README.md) on smart contract development and testing in foundry
- Helpful test examples

## Branch Structure

> **`main` is the only branch you should ever commit to.**
>
> Every other branch is generated from it and will be overwritten without warning.

### Branch Overview

1. **`main`**

   - Includes all tutorials, examples, and dependencies
   - The single source of truth, and the only branch that accepts PRs

2. **`minimal`** and any future starter branches
   - Stripped-down versions for users who want a lighter starting point
   - **Build artifacts**, regenerated from `main` on every push
   - Never edited by hand

Users are unaffected by any of this — `forge init --template lazertechnologies/lazerforge --branch minimal` works exactly as before.

## How Variant Branches Are Generated

Each variant is described by a manifest in [`variants/`](variants/), and built by [`tools/build-variant.sh`](tools/build-variant.sh). On every push to `main`, CI regenerates each variant, runs `forge build`, `forge test`, and `forge fmt --check` **against the generated tree**, and publishes it only if all of that passes.

This means variant branches are finally tested, and cannot drift from `main`.

### Building a variant locally

```bash
tools/build-variant.sh minimal
```

That writes a git worktree to `.variant-build/minimal/` and stops without pushing, so you can inspect the result:

```bash
git -C .variant-build/minimal show --stat
```

Add `--push` to publish, though in normal use CI does that for you.

### Changing what a variant contains

There are three mechanisms, in rough order of preference:

1. **Remove a path** — add it to `remove:` in `variants/<variant>.yml`. This covers whole files and directories.

2. **Remove part of a shared file** — wrap the lines in a marker region. This is how `minimal` drops the Uniswap dependencies while `foundry.toml` stays a single file on `main`:

   ```toml
   # variant:full:start
   '@uniswap/v2-core/=dependencies/@uniswap-v2-core-1.0.1/',
   # variant:full:end
   ```

   The name list is comma separated (`# variant:full,defi:start` keeps the region for both), `full` means `main` itself, and the marker lines are always stripped from generated output. Both `#` and `//` comment prefixes work, so this applies to Solidity as well as TOML.

   A marker has to be alone on its line, so mentioning one in prose does nothing. Markdown files are skipped entirely — otherwise this very section would be treated as a region to strip. Use an overlay for per-variant documentation.

3. **Replace a file entirely** — drop a copy at `variants/<variant>/files/<path>`. It is copied over the tree last. `minimal` uses this for `script/Deploy.s.sol`, which deploys `InflationToken` rather than the `BalanceManager` that `minimal` removes.

The build script fails rather than producing a broken branch if a manifest entry no longer matches anything, if a marker region is unbalanced, if a remapping is left pointing at a dependency the variant removed, or if a removed contract is still imported by a file that survives.

### Adding a new variant

Copy `variants/minimal.yml`, adjust it, and open a PR. CI discovers manifests automatically — there is no list to update, and no new branch to babysit.

### If you need to change a variant branch

You cannot, directly. Make the change on `main`, or to the variant's manifest, and let the build produce it. Branch protection on the generated branches enforces this.

> **Maintainers:** the generated branches need branch protection that blocks direct pushes from everyone except the `Build Variant Branches` workflow, which needs `contents: write`.

## Questions or Clarifications

If you have any questions about the branch structure or contribution process, please open an issue in the repository.
