# Branch rulesets

Importable rulesets for this repository. Import each one at
**Settings → Rules → Rulesets → New ruleset → Import a ruleset**.

| File | Applies to | Purpose |
| --- | --- | --- |
| [`main.json`](main.json) | the default branch | PR required, CI must pass, no force-push or deletion |
| [`variant-branches.json`](variant-branches.json) | `refs/heads/variant/*` | only the build workflow may update; nobody can push or delete |

## Why the `variant/` prefix

Generated branches all live under `variant/`, so **one** ruleset covers every
one of them. Adding a starter is a manifest in [`variants/`](../../variants/)
and nothing else — no new ruleset, and no edit to an existing one.

## `variant-branches.json`

The `update` and `deletion` rules block everyone from touching a generated
branch, which is what makes "never edit a variant branch" enforced rather than
merely documented.

The `bypass_actors` entry is the **GitHub Actions** app (`actor_id: 15368`,
`actor_type: "Integration"`). The `Build Variant Branches` workflow pushes with
`GITHUB_TOKEN`, which authenticates as that app, so it is the only actor that can
update these branches. Without the bypass the workflow's publish step fails with
a rules violation.

If a push from the workflow is ever rejected, check that this bypass entry
survived the import — the UI lists it under **Bypass list**.

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
