#!/usr/bin/env bash
#
# Generate a variant branch from `main`.
#
# Variant branches (`variant/minimal`, and the starters planned in the README)
# are build artifacts. They are never edited by hand - this script regenerates
# the whole tree from a manifest, so the branches cannot drift.
#
# Usage:
#   tools/build-variant.sh <variant> [--ref <git-ref>] [--out <dir>] [--push]
#
#   <variant>      name of a manifest in variants/, without the .yml
#   --ref          source commit to build from (default: origin/main, or HEAD
#                  if there is no such ref)
#   --out          where to place the build worktree (default: .variant-build/<variant>)
#   --push         push the generated branch to origin after building
#
# The build is a git worktree containing one new commit on top of the existing
# variant branch, so published branches keep their history and consumers of
# `forge init --template ... --branch minimal` are unaffected.

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

die() {
    printf '\033[31merror\033[0m: %s\n' "$*" >&2
    exit 1
}

log() {
    printf '\033[36m==>\033[0m %s\n' "$*"
}

warn() {
    printf '\033[33mwarning\033[0m: %s\n' "$*" >&2
}

# ---------------------------------------------------------------------------
# Manifest parsing
#
# Deliberately a restricted YAML subset - `key: value` scalars and `key:`
# followed by `  - item` lists - so the script needs no YAML dependency. Keep
# variants/*.yml within that subset.
# ---------------------------------------------------------------------------

manifest_scalar() {
    local key="$1" file="$2"
    awk -v key="$key" '
        $0 ~ "^" key ":" {
            sub("^" key ":[[:space:]]*", "")
            sub(/[[:space:]]+$/, "")
            gsub(/^["\047]|["\047]$/, "")
            print
            exit
        }
    ' "$file"
}

manifest_list() {
    local key="$1" file="$2"
    awk -v key="$key" '
        # the list header, e.g. `remove:` with nothing after it
        $0 ~ "^" key ":[[:space:]]*$" { in_list = 1; next }
        !in_list { next }
        # blank lines and full-line comments do not end the list
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*#/ { next }
        # a list entry
        /^[[:space:]]*-[[:space:]]+/ {
            sub(/^[[:space:]]*-[[:space:]]+/, "")
            sub(/[[:space:]]+#.*$/, "")
            sub(/[[:space:]]+$/, "")
            gsub(/^["\047]|["\047]$/, "")
            if (length($0)) print
            next
        }
        # anything else at column 0 starts a new key and ends the list
        /^[^[:space:]]/ { in_list = 0 }
    ' "$file"
}

# ---------------------------------------------------------------------------
# Marker regions
#
# A region looks like:
#
#     # variant:full:start
#     ...lines kept only when building the `full` variant...
#     # variant:full:end
#
# The name list is comma separated, so `# variant:full,defi:start` keeps the
# region for both. `full` means `main` itself. Building variant V keeps a region
# only if V appears in its list; the marker lines themselves are always removed.
# Both `#` and `//` comment prefixes work, so this applies to TOML and Solidity.
#
# A marker must be alone on its line, so a mention inside prose or a URL is not
# mistaken for one.
#
# Markdown uses HTML comments instead, `<!-- variant:full:start -->`, so the
# markers do not render. They are only recognised outside fenced code blocks,
# which is what lets CONTRIBUTING.md show the syntax without the build acting on
# it. A region may still wrap a fenced block - put the markers around the fence.
# ---------------------------------------------------------------------------

readonly MARKER_START='^[[:space:]]*(#|//)[[:space:]]*variant:[A-Za-z0-9_,.-]+:start[[:space:]]*$'
readonly MARKER_END='^[[:space:]]*(#|//)[[:space:]]*variant:[A-Za-z0-9_,.-]+:end[[:space:]]*$'
readonly MD_MARKER_START='^[[:space:]]*<!--[[:space:]]*variant:[A-Za-z0-9_,.-]+:start[[:space:]]*-->[[:space:]]*$'
readonly MD_MARKER_END='^[[:space:]]*<!--[[:space:]]*variant:[A-Za-z0-9_,.-]+:end[[:space:]]*-->[[:space:]]*$'

strip_markers() {
    local variant="$1" file="$2" tmp is_md=0
    tmp="$(mktemp)"

    local re_start="$MARKER_START" re_end="$MARKER_END"
    case "$file" in
        *.md|*.markdown) is_md=1; re_start="$MD_MARKER_START"; re_end="$MD_MARKER_END" ;;
    esac

    awk -v variant="$variant" -v path="$file" -v is_md="$is_md" \
        -v re_start="$re_start" -v re_end="$re_end" '
        function fail(msg) {
            printf "error: %s:%d: %s\n", path, NR, msg > "/dev/stderr"
            exit 1
        }
        function spec_of(line,   s) {
            match(line, /variant:[A-Za-z0-9_,.-]+:/)
            s = substr(line, RSTART + 8, RLENGTH - 9)
            return s
        }
        {
            # track fences first, and always, so a region may wrap a whole
            # fenced block without the toggling getting out of step
            if (is_md && $0 ~ /^[[:space:]]*(```|~~~)/) {
                fenced = !fenced
                if (!in_region || keep) print
                next
            }
            if (is_md && fenced) {
                if (!in_region || keep) print
                next
            }
            if ($0 ~ re_start) {
                if (in_region) fail("nested variant region")
                spec = spec_of($0)
                in_region = 1
                keep = 0
                n = split(spec, names, ",")
                for (i = 1; i <= n; i++) if (names[i] == variant) keep = 1
                next
            }
            if ($0 ~ re_end) {
                if (!in_region) fail("variant region closed but never opened")
                endspec = spec_of($0)
                if (endspec != spec) fail("region opened as \"" spec "\" but closed as \"" endspec "\"")
                in_region = 0
                next
            }
            if (!in_region || keep) print
        }
        END {
            if (in_region) {
                printf "error: %s: unterminated variant region \"%s\"\n", path, spec > "/dev/stderr"
                exit 1
            }
        }
    ' "$file" > "$tmp" || { rm -f "$tmp"; return 1; }

    if ! cmp -s "$file" "$tmp"; then
        cat "$tmp" > "$file"
        printf '%s\n' "$file"
    fi
    rm -f "$tmp"
}

# ---------------------------------------------------------------------------
# Validation
#
# The generated tree gets compiled and tested by CI, but two classes of mistake
# survive that: a remapping left pointing at a dependency the variant dropped
# (forge only resolves remappings that are actually imported), and a manifest
# entry that no longer matches anything after a refactor.
# ---------------------------------------------------------------------------

# the package names left in [dependencies] after the variant transformations
declared_dependencies() {
    awk '
        /^\[dependencies\]/ { in_deps = 1; next }
        /^\[/ { in_deps = 0 }
        in_deps && /=/ {
            key = $0
            sub(/[[:space:]]*=.*$/, "", key)
            gsub(/^[[:space:]]*|[[:space:]]*$/, "", key)
            gsub(/^"|"$/, "", key)
            if (length(key) && key !~ /^#/) print key
        }
    ' "$1"
}

# soldeer.lock is carried over from main, so it still pins packages the variant
# just dropped. `forge soldeer install` ignores them, but a lockfile that
# disagrees with the manifest is precisely the drift this is meant to prevent.
prune_lockfile() {
    local dir="$1" lock="$1/soldeer.lock" config="$1/foundry.toml" tmp before after

    [ -f "$lock" ] && [ -f "$config" ] || return 0

    before="$(grep -c '^\[\[dependencies\]\]' "$lock" || true)"
    tmp="$(mktemp)"

    # passed through the environment rather than -v, which mangles newlines
    DECLARED_DEPS="$(declared_dependencies "$config")" awk '
        BEGIN {
            RS = ""; ORS = "\n\n"
            n = split(ENVIRON["DECLARED_DEPS"], arr, "\n")
            for (i = 1; i <= n; i++) if (length(arr[i])) keep[arr[i]] = 1
        }
        /^\[\[dependencies\]\]/ {
            name = ""
            if (match($0, /name[[:space:]]*=[[:space:]]*"[^"]*"/)) {
                name = substr($0, RSTART, RLENGTH)
                sub(/^name[[:space:]]*=[[:space:]]*"/, "", name)
                sub(/"$/, "", name)
            }
            if (!(name in keep)) next
        }
        { print }
    ' "$lock" > "$tmp"

    # collapse the trailing blank line paragraph mode leaves behind
    printf '%s\n' "$(cat "$tmp")" > "$lock"
    rm -f "$tmp"

    after="$(grep -c '^\[\[dependencies\]\]' "$lock" || true)"
    if [ "$before" != "$after" ]; then
        log "pruned soldeer.lock from $before to $after dependencies"
    fi
}

validate_remappings() {
    local dir="$1" config="$1/foundry.toml" stale=0

    [ -f "$config" ] || return 0

    local declared
    declared="$(declared_dependencies "$config")"

    # every remapping target of the form dependencies/<pkg>-<version>/ must name
    # a package that is still declared
    local target pkg
    while IFS= read -r target; do
        pkg="$(printf '%s' "$target" | sed -E 's|^dependencies/(.+)-[0-9]+\.[0-9]+\.[0-9]+.*$|\1|')"
        [ "$pkg" = "$target" ] && continue
        if ! printf '%s\n' "$declared" | grep -qxF "$pkg"; then
            warn "remapping points at '$pkg', which is not in [dependencies]"
            stale=1
        fi
    done < <(grep -oE "dependencies/[^']+" "$config" | sort -u)

    [ "$stale" -eq 0 ] || die "foundry.toml has remappings for dependencies this variant removed - wrap them in a variant marker region"
}

validate_no_dangling_imports() {
    local dir="$1" removed_file="$2" missing=0
    local path base hits

    while IFS= read -r path; do
        case "$path" in
            */) continue ;;         # directories are checked by the compiler
            *.sol) ;;
            *) continue ;;
        esac
        base="$(basename "$path")"
        hits="$(grep -rlF "$base" "$dir/src" "$dir/test" "$dir/script" 2>/dev/null || true)"
        if [ -n "$hits" ]; then
            warn "removed $path but it is still referenced by:"
            printf '  %s\n' $hits >&2
            missing=1
        fi
    done < "$removed_file"

    [ "$missing" -eq 0 ] || die "the generated tree still references removed files - remove the referring file too, or wrap the reference in a variant marker region"
}

# ---------------------------------------------------------------------------
# Argument handling
# ---------------------------------------------------------------------------

VARIANT=""
REF=""
OUT=""
PUSH=0

while [ $# -gt 0 ]; do
    case "$1" in
        --ref)  REF="${2:?--ref needs a value}"; shift 2 ;;
        --out)  OUT="${2:?--out needs a value}"; shift 2 ;;
        --push) PUSH=1; shift ;;
        -h|--help)
            sed -n '2,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        -*)     die "unknown option: $1" ;;
        *)
            [ -z "$VARIANT" ] || die "only one variant may be built at a time"
            VARIANT="$1"; shift ;;
    esac
done

[ -n "$VARIANT" ] || die "usage: tools/build-variant.sh <variant> [--ref <git-ref>] [--out <dir>] [--push]"

readonly MANIFEST="$REPO_ROOT/variants/$VARIANT.yml"
[ -f "$MANIFEST" ] || die "no manifest at variants/$VARIANT.yml"

# the build ends in a commit, so fail early with something more useful than
# git's "empty ident name" if there is no identity to commit as
if [ -z "$(git -C "$REPO_ROOT" config user.email || true)" ]; then
    die "no git identity configured - set user.name and user.email before building a variant"
fi

if [ -z "$REF" ]; then
    if git -C "$REPO_ROOT" rev-parse --verify --quiet origin/main >/dev/null; then
        REF="origin/main"
    else
        REF="HEAD"
    fi
fi
git -C "$REPO_ROOT" rev-parse --verify --quiet "$REF" >/dev/null || die "no such git ref: $REF"

[ -n "$OUT" ] || OUT="$REPO_ROOT/.variant-build/$VARIANT"

BRANCH="$(manifest_scalar branch "$MANIFEST")"
[ -n "$BRANCH" ] || BRANCH="$VARIANT"
DESCRIPTION="$(manifest_scalar description "$MANIFEST")"

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

log "building '$VARIANT' from $REF ($(git -C "$REPO_ROOT" rev-parse --short "$REF"))"

# a stale worktree from an interrupted run would otherwise block the checkout
if [ -e "$OUT" ]; then
    git -C "$REPO_ROOT" worktree remove --force "$OUT" 2>/dev/null || rm -rf "$OUT"
fi
git -C "$REPO_ROOT" worktree prune

BUILD_BRANCH="variant-build/$VARIANT"
git -C "$REPO_ROOT" branch -D "$BUILD_BRANCH" >/dev/null 2>&1 || true

# base the build on the published branch when it exists, so the variant keeps a
# linear history instead of being force-pushed over
BASE=""
for candidate in "refs/remotes/origin/$BRANCH" "refs/heads/$BRANCH"; do
    if git -C "$REPO_ROOT" rev-parse --verify --quiet "$candidate" >/dev/null; then
        BASE="$candidate"
        break
    fi
done

if [ -n "$BASE" ]; then
    log "basing on existing $BASE"
    git -C "$REPO_ROOT" worktree add --quiet -B "$BUILD_BRANCH" "$OUT" "$BASE"
else
    log "no existing '$BRANCH' branch, starting a new history"
    git -C "$REPO_ROOT" worktree add --quiet --detach "$OUT" "$REF"
    git -C "$OUT" checkout --quiet --orphan "$BUILD_BRANCH"
fi

# replace the worktree contents wholesale with the source tree. This is what
# makes drift impossible: nothing of the previous variant build survives.
git -C "$OUT" rm -rq --cached . 2>/dev/null || true
find "$OUT" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
git -C "$REPO_ROOT" archive "$REF" | tar -x -C "$OUT"

# --- apply `remove:` ---------------------------------------------------------

REMOVED_LIST="$(mktemp)"
trap 'rm -f "$REMOVED_LIST"' EXIT

removed_count=0
while IFS= read -r path; do
    [ -n "$path" ] || continue
    target="$OUT/${path%/}"
    if [ ! -e "$target" ]; then
        die "manifest removes '$path', which does not exist in $REF - the manifest is stale"
    fi
    rm -rf "$target"
    printf '%s\n' "$path" >> "$REMOVED_LIST"
    removed_count=$((removed_count + 1))
done < <(manifest_list remove "$MANIFEST")
log "removed $removed_count path(s)"

# --- strip marker regions ----------------------------------------------------

stripped_count=0
while IFS= read -r file; do
    # skip anything that is not text
    if ! grep -Iq . "$file" 2>/dev/null; then continue; fi

    changed=""
    # a malformed region must fail the build rather than silently pass through
    changed="$(strip_markers "$VARIANT" "$file")" \
        || die "could not process variant regions in ${file#"$OUT"/}"
    if [ -n "$changed" ]; then
        stripped_count=$((stripped_count + 1))
    fi
done < <(find "$OUT" -type f -not -path "$OUT/.git/*")
log "stripped variant regions from $stripped_count file(s)"

# Markdown needs the HTML-comment form. A `#`-prefixed marker there is a heading
# that silently does nothing, so flag it rather than leaving it to be discovered
# in the published branch. Fenced blocks are exempt - the docs show the syntax.
stray_markers="$(
    while IFS= read -r file; do
        awk -v re_start="$MARKER_START" -v path="${file#"$OUT"/}" '
            /^[[:space:]]*(```|~~~)/ { fenced = !fenced; next }
            !fenced && $0 ~ re_start { printf "  %s:%d\n", path, NR }
        ' "$file"
    done < <(find "$OUT" -type f \( -name '*.md' -o -name '*.markdown' \) -not -path "$OUT/.git/*")
)"
if [ -n "$stray_markers" ]; then
    warn "Markdown markers must use the <!-- variant:...:start --> form:"
    printf '%s\n' "$stray_markers" >&2
fi

# --- prune generated metadata ------------------------------------------------

prune_lockfile "$OUT"

# --- validate ----------------------------------------------------------------

validate_remappings "$OUT"
validate_no_dangling_imports "$OUT" "$REMOVED_LIST"
log "validation passed"

# --- commit ------------------------------------------------------------------

git -C "$OUT" add -A
if git -C "$OUT" diff --cached --quiet; then
    log "'$BRANCH' is already up to date with $REF, nothing to commit"
    printf '\n%s\n' "worktree: $OUT"
    exit 0
fi

SHORT_REF="$(git -C "$REPO_ROOT" rev-parse --short "$REF")"
SUBJECT_LINE="$(git -C "$REPO_ROOT" log -1 --format=%s "$REF")"

git -C "$OUT" commit --quiet -F - <<EOF
🤖 generate \`$BRANCH\` from main@$SHORT_REF

${DESCRIPTION:-Generated variant branch.}

This branch is a build artifact of \`main\`, produced by
tools/build-variant.sh from variants/$VARIANT.yml. Do not commit to it
directly - changes belong on \`main\` and will be overwritten here.

main@$SHORT_REF: $SUBJECT_LINE
EOF

log "committed $(git -C "$OUT" rev-parse --short HEAD) on $BUILD_BRANCH"

# --- push --------------------------------------------------------------------

if [ "$PUSH" -eq 1 ]; then
    log "pushing $BUILD_BRANCH to origin/$BRANCH"
    git -C "$OUT" push origin "$BUILD_BRANCH:refs/heads/$BRANCH"
    log "pushed"
else
    printf '\n%s\n' "built '$BRANCH' in $OUT (not pushed)"
    printf '%s\n' "review it with:  git -C $OUT show --stat"
    printf '%s\n' "publish it with: tools/build-variant.sh $VARIANT --push"
fi
