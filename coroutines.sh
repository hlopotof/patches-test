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

build_file="buildSrc/build.gradle.kts"

if [[ ! -f "${build_file}" ]]; then
  echo "Expected ${build_file} but it was not found." >&2
  exit 1
fi

if grep -Eq '^\s*//\s*(warning(s)?AsError(s)?|allWarningsAsErrors)\b' "${build_file}"; then
  echo "Warning-as-error property already commented; nothing to do."
  exit 0
fi

echo "Checking out develop branch before applying patches."
git checkout develop

if python3 - "${build_file}" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
lines = text.splitlines(keepends=True)

targets = (
    "warningAsError",
    "warningsAsErrors",
    "allWarningsAsErrors",
)
value_markers = (
    "= true",
    "=true",
    ".set(true",
    "set(true",
)

modified = False
for index, line in enumerate(lines):
    stripped = line.lstrip()
    if not stripped or stripped.startswith("//"):
        continue
    if not any(target in line for target in targets):
        continue
    if not any(marker in stripped for marker in value_markers):
        continue
    indent_length = len(line) - len(stripped)
    indent = line[:indent_length]
    lines[index] = f"{indent}// {stripped}"
    modified = True
    break

if not modified:
    sys.exit(1)

path.write_text("".join(lines), encoding="utf-8")
PY
then
  echo "Commented warning-as-error property in ${build_file}."
else
  echo "Failed to locate a warning-as-error property to comment out in ${build_file}." >&2
  exit 1
fi