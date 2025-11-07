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

if grep -Eq '^\s*//\s*(warning(s)?AsError(s)?|allWarningsAsErrors)\s*(\.set)?\s*\(?\s*true\)?' "${build_file}"; then
  echo "Warning-as-error property already commented; nothing to do."
  exit 0
fi

patch_candidates=()

patch_candidates+=("$(
  cat <<'EOF'
diff --git a/buildSrc/build.gradle.kts b/buildSrc/build.gradle.kts
--- a/buildSrc/build.gradle.kts
+++ b/buildSrc/build.gradle.kts
@@
-        warningAsError = true
+        // warningAsError = true
EOF
)")

patch_candidates+=("$(
  cat <<'EOF'
diff --git a/buildSrc/build.gradle.kts b/buildSrc/build.gradle.kts
--- a/buildSrc/build.gradle.kts
+++ b/buildSrc/build.gradle.kts
@@
-        warningsAsErrors = true
+        // warningsAsErrors = true
EOF
)")

patch_candidates+=("$(
  cat <<'EOF'
diff --git a/buildSrc/build.gradle.kts b/buildSrc/build.gradle.kts
--- a/buildSrc/build.gradle.kts
+++ b/buildSrc/build.gradle.kts
@@
-        warningsAsErrors.set(true)
+        // warningsAsErrors.set(true)
EOF
)")

patch_candidates+=("$(
  cat <<'EOF'
diff --git a/buildSrc/build.gradle.kts b/buildSrc/build.gradle.kts
--- a/buildSrc/build.gradle.kts
+++ b/buildSrc/build.gradle.kts
@@
-        allWarningsAsErrors = true
+        // allWarningsAsErrors = true
EOF
)") 

patch_candidates+=("$(
  cat <<'EOF'
diff --git a/buildSrc/build.gradle.kts b/buildSrc/build.gradle.kts
--- a/buildSrc/build.gradle.kts
+++ b/buildSrc/build.gradle.kts
@@
-        allWarningsAsErrors.set(true)
+        // allWarningsAsErrors.set(true)
EOF
)") 

patch_applied=false
for patch in "${patch_candidates[@]}"; do
  if git apply --check --unidiff-zero <<<"${patch}" >/dev/null 2>&1; then
    git apply --unidiff-zero <<<"${patch}"
    patch_applied=true
    echo "Commented warning-as-error property in ${build_file}."
    break
  fi
done

if [[ "${patch_applied}" != true ]]; then
  echo "Failed to locate a warning-as-error property to comment out in ${build_file}." >&2
  exit 1
fi