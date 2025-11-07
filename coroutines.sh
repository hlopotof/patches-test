#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  exec /usr/bin/env bash "$0" "$@"
fi

set -euo pipefail

ensure_git_identity() {
  local current_name
  if ! current_name=$(git config user.name 2>/dev/null) || [[ -z "${current_name}" ]]; then
    local fallback_name="${GIT_DEFAULT_NAME:-TeamCity}"
    git config user.name "${fallback_name}"
    echo "Configured git user.name to ${fallback_name}"
  fi

  local current_email
  if ! current_email=$(git config user.email 2>/dev/null) || [[ -z "${current_email}" ]]; then
    local fallback_email="${GIT_DEFAULT_EMAIL:-teamcity@${HOSTNAME:-localhost}}"
    git config user.email "${fallback_email}"
    echo "Configured git user.email to ${fallback_email}"
  fi
}

ensure_git_identity

finalize_cherry_pick() {
  local previous_head="$1"
  local commit="$2"

  if [[ "${no_commit}" == true ]]; then
    local current_head
    current_head=$(git rev-parse HEAD)
    if [[ "${current_head}" != "${previous_head}" ]]; then
      git reset --soft "${previous_head}"
      echo "Reset HEAD back to ${previous_head} to keep ${commit} as uncommitted changes."
    fi
    echo "Cherry-picked ${commit} without creating a commit."
  else
    echo "Cherry-picked ${commit}."
  fi
}

default_commits=(
  82613aebb7d5c953c326afdece0ff8c6e9311ca9
)

no_commit=true
declare -a commits=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-commit|--nocommit)
      no_commit=true
      shift
      ;;
    --commit|--with-commit)
      no_commit=false
      shift
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        commits+=("$1")
        shift
      done
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
    *)
      commits+=("$1")
      shift
      ;;
  esac
done

if [[ ${#commits[@]} -eq 0 ]]; then
  if [[ ${#default_commits[@]} -eq 0 ]]; then
    echo "No commits specified and default list empty; aborting." >&2
    exit 1
  fi
  commits=("${default_commits[@]}")
fi

cherry_pick_args=(-X theirs)
if [[ "${no_commit}" == true ]]; then
  cherry_pick_args+=(--no-commit)
fi

for commit in "${commits[@]}"; do
  echo "Applying commit ${commit}"
  previous_head=$(git rev-parse HEAD)
  if git cherry-pick "${cherry_pick_args[@]}" "${commit}"; then
    finalize_cherry_pick "${previous_head}" "${commit}"
    continue
  fi

  status=$?
  echo "Cherry-pick ${commit} exited with ${status}. Resolving by forcing commit content."
  git status --short

  conflict_files=$(git diff --name-only --diff-filter=U)
  if [[ -z "${conflict_files}" ]]; then
    echo "No conflict files detected, aborting cherry-pick." >&2
    git cherry-pick --abort
    exit "${status}"
  fi

  while IFS= read -r path; do
    [[ -z "${path}" ]] && continue
    echo "Forcing ${path} from commit ${commit}"
    git checkout --theirs "${path}"
    git add "${path}"
  done <<<"${conflict_files}"

  git cherry-pick --continue
  finalize_cherry_pick "${previous_head}" "${commit}"
done