# Branch rulesets

Importable rulesets for this repository. Import each one at
**Settings → Rules → Rulesets → New ruleset → Import a ruleset**.

| File | Applies to | Purpose |
| --- | --- | --- |
| [`main.json`](main.json) | the default branch | PR required, CI must pass, no force-push or deletion |
| [`variant-branches.json`](variant-branches.json) | `refs/heads/variant/*` | no force-push, no deletion; direct pushes are reverted automatically |

## Why the `variant/` prefix

Generated branches all live under `variant/`, so **one** ruleset covers every
one of them. Adding a starter is a manifest in [`variants/`](../../variants/)
and nothing else — no new ruleset, and no edit to an existing one.

## `variant-branches.json`

This ruleset blocks **deletion** and **force-pushes**. It deliberately does *not*
use the "restrict updates" rule, which needs explaining.

### Why there is no "restrict updates" rule

Restricting updates would block the build workflow along with everyone else,
because `GITHUB_TOKEN` cannot be granted a bypass. Adding the GitHub Actions app
as an `Integration` bypass actor is rejected on import:

```
Actor GitHub Actions integration must be part of the ruleset
source or owner organization
```

GitHub Actions is built into GitHub rather than installed as an org app, so it is
not a valid actor here. A `RepositoryRole` bypass is accepted but does not help —
`GITHUB_TOKEN` holds no repository role, so the workflow would still be blocked.

### What protects the branches instead

Direct pushes are not blocked, but they do not survive:

1. Every build **replaces the entire tree** with content generated from `main`,
   so anything committed by hand is gone from the next build's tree.
2. A push to `variant/**` **triggers that rebuild immediately** — the workflow
   listens on those branches for exactly this reason, so a hand-edit is reverted
   in about a minute rather than lingering until `main` next changes. Pushes made
   with `GITHUB_TOKEN` do not trigger workflows, so this cannot loop.

Together with the two rules, history cannot be rewritten, the branch cannot be
deleted, and content always converges back to what `main` generates.

### If you want hard enforcement

Restricting updates becomes possible if the workflow pushes as an actor that
*can* bypass:

- **Deploy key** — add a write-access deploy key, push over SSH with the private
  key in a secret, and add a `DeployKey` bypass actor.
- **GitHub App** — install an org-owned app, mint a token in the workflow, and
  add it as an `Integration` bypass actor.

Both trade setup and a secret to rotate for a guarantee the self-heal path
already provides in practice, which is why neither is the default.

## `main.json`

Required status checks are `Forge Tests`, `Forge Lint`, and `Variants`. The last
one is an aggregate job that passes only if every variant built, compiled, and
tested. It exists so this list stays correct as starters are added — the
per-variant jobs are named after the variant, so requiring them directly would
mean editing this ruleset every time.

Adjust `required_approving_review_count` before importing if a single approval
is not what you want.

## Keeping these in sync

These files are a convenience, not the source of truth — GitHub is. If you change
a ruleset in the UI, export it (**⋯ → Export a ruleset**) and commit the result
here so the next person imports what is actually in force.
