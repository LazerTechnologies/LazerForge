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

2. **`variant/*`** — `variant/minimal`, and the starters planned in the README
   - Stripped-down versions for users who want a lighter starting point
   - **Build artifacts**, regenerated from `main` on every push
   - Never edited by hand

Users select one with the `--branch` flag:

```bash
forge init --template lazertechnologies/lazerforge --branch variant/minimal <project_name>
```

Everything generated lives under the `variant/` prefix so that a single branch ruleset matching `variant/*` protects all of them. Adding a starter then needs no repository settings changes at all.

## How Variant Branches Are Generated

Each variant is described by a manifest in [`variants/`](variants/), and built by [`tools/build-variant.sh`](tools/build-variant.sh). On every push to `main`, CI regenerates each variant, runs `forge build`, `forge test`, and `forge fmt --check` **against the generated tree**, and publishes it only if all of that passes.

This means variant branches are finally tested, and cannot drift from `main`.

### Building a variant locally

```bash
just variant minimal --ref HEAD    # or: tools/build-variant.sh minimal --ref HEAD
```

Variants are built from `origin/main` by default, which is what CI wants but almost never what you want while working on a branch — pass `--ref HEAD` to build from your own commits. Note that it builds from a **commit**, not your working tree, so commit before rebuilding.

It writes a git worktree to `.variant-build/minimal/` and stops without pushing, so you can inspect the result:

```bash
git -C .variant-build/minimal show --stat
```

Add `--push` to publish, though in normal use CI does that for you.

### Changing what a variant contains

There are two mechanisms. Prefer the first.

**1. Remove a path** — add it to `remove:` in `variants/<variant>.yml`. This covers whole files and directories.

Structure the repo so this is usually enough. Deploy scripts are one per contract — `DeployBalanceManager.s.sol`, `DeployInflationToken.s.sol` — precisely so that a variant which drops a contract just drops its script. A single `Deploy.s.sol` naming one contract would need special handling in every variant that lacks it.

**2. Remove part of a shared file** — wrap the lines in a marker region. This is how `minimal` drops the Uniswap dependencies while `foundry.toml` stays a single file on `main`:

```toml
# variant:full:start
'@uniswap/v2-core/=dependencies/@uniswap-v2-core-1.0.1/',
# variant:full:end
```

The name list is comma separated (`# variant:full,defi:start` keeps the region for both), and the marker lines are always stripped from generated output. Both `#` and `//` prefixes work, so this covers Solidity as well as TOML. A marker has to be alone on its line, so mentioning one in prose does nothing.

Markdown uses an HTML comment instead, so the marker does not render:

```markdown
<!-- variant:full:start -->

- The full Uniswap suite is included too

<!-- variant:full:end -->
```

Markdown markers are only recognised **outside** fenced code blocks, which is what lets this section show the syntax without the build acting on it. To strip a fenced block, put the markers around the fence.

#### Regions can only remove

`full` means `main` itself, and `main` is never generated — it is the input. So a region always shows up on `main`, and a variant build only ever takes content away.

That means you cannot write content that appears on `minimal` but not on `main`. Phrase the shared text so it is true everywhere, and put the extra detail in a `full`-only region. The README does this: the dependency bullet mentions only OpenZeppelin and Solady, and a `variant:full` region adds the Uniswap bullet after it.

### Validation

The build fails rather than producing a broken branch when:

- a manifest entry no longer matches anything
- a marker region is unbalanced or nested
- a remapping still points at a dependency the variant removed
- a removed contract is still imported by a file that survives

It also prunes `soldeer.lock` down to the dependencies the variant actually declares.

### Adding a new variant

Copy `variants/minimal.yml`, adjust it, and open a PR. Keep the `variant/` prefix on the `branch:` value.

That is the whole process. CI discovers manifests automatically, so there is no list to update, no workflow to edit, and — because the ruleset matches `variant/*` — no repository settings to change either.

### If you need to change a variant branch

You cannot, directly. Make the change on `main`, or to the variant's manifest, and let the build produce it.

> **Maintainers:** importable rulesets that enforce all of this live in [`.github/rulesets/`](.github/rulesets/), along with notes on what each one does.

## Questions or Clarifications

If you have any questions about the branch structure or contribution process, please open an issue in the repository.
