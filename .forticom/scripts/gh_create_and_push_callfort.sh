#!/usr/bin/env bash
# gh_create_and_push_callfort.sh
# Create private repo in 'callfort' org and push via SSH

set -o nounset
set -o errexit
set -o pipefail

# 🔍 Derive repo name from Git root
GIT_ROOT="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "${GIT_ROOT}")"
ORG="callfort"
FULL_NAME="${ORG}/${REPO_NAME}"

# ✅ Create the repo if it doesn't exist
if gh repo view "${FULL_NAME}" &>/dev/null; then
  echo "⚠️ Repo '${FULL_NAME}' already exists on GitHub."
else
  echo "📦 Creating private repo '${FULL_NAME}'..."
  gh repo create "${FULL_NAME}" --private --confirm
fi

# 🛠️ Set SSH remote if needed
REMOTE_URL="git@github.com:${FULL_NAME}.git"
if ! git remote get-url origin &>/dev/null; then
  git remote add origin "${REMOTE_URL}"
else
  git remote set-url origin "${REMOTE_URL}"
fi

# 🚀 Push current HEAD to GitHub
echo "🚀 Pushing current branch to GitHub..."
git push -u origin HEAD

echo "✅ Done. Pushed '${REPO_NAME}' to '${REMOTE_URL}'"
