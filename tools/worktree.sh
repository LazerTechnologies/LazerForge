#!/usr/bin/env bash
#
# Manage development git worktrees under .worktrees/.
#
# Usage:
#   tools/worktree.sh add <branch> [--new-branch <name>] [--path <dir>]
#   tools/worktree.sh list
#   tools/worktree.sh remove <branch>
#
# By default, worktrees are created at .worktrees/<branch-with-slashes-as-dashes>.
# This keeps sibling checkouts inside the repo instead of cluttering the parent
# directory.

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly WORKTREES_DIR="$REPO_ROOT/.worktrees"

die() {
    printf '\033[31merror\033[0m: %s\n' "$*" >&2
    exit 1
}

usage() {
    cat <<'EOF'
Usage:
  tools/worktree.sh add <branch> [--new-branch <name>] [--path <dir>]
  tools/worktree.sh list
  tools/worktree.sh remove <branch>

Examples:
  tools/worktree.sh add ci/caching-coverage-snapshot
  tools/worktree.sh add main --new-branch fix/ci-cache
  tools/worktree.sh remove ci/caching-coverage-snapshot
EOF
}

branch_to_dir() {
    printf '%s' "$1" | tr '/' '-'
}

default_path_for_branch() {
    printf '%s/%s' "$WORKTREES_DIR" "$(branch_to_dir "$1")"
}

cmd_add() {
    local branch=""
    local new_branch=""
    local path=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --new-branch)
                [[ $# -ge 2 ]] || die "--new-branch requires a value"
                new_branch="$2"
                shift 2
                ;;
            --path)
                [[ $# -ge 2 ]] || die "--path requires a value"
                path="$2"
                shift 2
                ;;
            -*)
                die "unknown option: $1"
                ;;
            *)
                [[ -z "$branch" ]] || die "unexpected argument: $1"
                branch="$1"
                shift
                ;;
        esac
    done

    [[ -n "$branch" ]] || die "branch is required"

    if [[ -z "$path" ]]; then
        if [[ -n "$new_branch" ]]; then
            path="$(default_path_for_branch "$new_branch")"
        else
            path="$(default_path_for_branch "$branch")"
        fi
    elif [[ "$path" != /* ]]; then
        path="$REPO_ROOT/$path"
    fi

    case "$path" in
        "$WORKTREES_DIR"/*) ;;
        *)
            die "worktree path must be inside $WORKTREES_DIR (got: $path)"
            ;;
    esac

    mkdir -p "$WORKTREES_DIR"

    if [[ -n "$new_branch" ]]; then
        git -C "$REPO_ROOT" worktree add -b "$new_branch" "$path" "$branch"
    else
        git -C "$REPO_ROOT" worktree add "$path" "$branch"
    fi

    printf '\nworktree: %s\n' "$path"
}

cmd_list() {
    git -C "$REPO_ROOT" worktree list
}

cmd_remove() {
    local branch="${1:-}"
    [[ -n "$branch" ]] || die "branch is required"

    local path
    path="$(default_path_for_branch "$branch")"
    [[ -d "$path" ]] || die "no worktree found at $path"

    git -C "$REPO_ROOT" worktree remove "$path"
}

main() {
    local cmd="${1:-}"
    shift || true

    case "$cmd" in
        add) cmd_add "$@" ;;
        list) cmd_list "$@" ;;
        remove) cmd_remove "$@" ;;
        -h | --help | help | "") usage ;;
        *) die "unknown command: $cmd" ;;
    esac
}

main "$@"
