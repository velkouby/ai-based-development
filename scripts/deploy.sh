#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

remote="${DEPLOY_REMOTE:-origin}"
branch="${DEPLOY_BRANCH:-main}"
site_url="${SITE_URL:-https://velkouby.github.io/ai-based-development/}"

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" != "$branch" ]]; then
  echo "Deployment is configured from $branch. Current branch: $current_branch"
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Commit or stash local changes before deploying:"
  git status --short
  exit 1
fi

site_dir="$(mktemp -d)"
trap 'rm -rf "$site_dir"' EXIT

if [[ -x ".venv/bin/mkdocs" ]]; then
  mkdocs_bin=".venv/bin/mkdocs"
else
  mkdocs_bin="mkdocs"
fi

if ! command -v "$mkdocs_bin" >/dev/null 2>&1; then
  echo "mkdocs is not available. Install dependencies with: pip install -r requirements.txt"
  exit 1
fi

repo_url="$(git config --get "remote.${remote}.url" || true)"
actions_url=""
if [[ "$repo_url" =~ ^git@github.com:(.+)\.git$ ]]; then
  actions_url="https://github.com/${BASH_REMATCH[1]}/actions/workflows/deploy.yml"
elif [[ "$repo_url" =~ ^https://github.com/(.+)\.git$ ]]; then
  actions_url="https://github.com/${BASH_REMATCH[1]}/actions/workflows/deploy.yml"
fi

echo "Building MkDocs site with strict validation..."
"$mkdocs_bin" build --strict --site-dir "$site_dir"

echo "Pushing $branch to $remote..."
git push "$remote" "$branch"

echo
echo "Pushed $branch. GitHub Actions will deploy the site to GitHub Pages."
if [[ -n "$actions_url" ]]; then
  echo "Workflow: $actions_url"
fi
echo "Site: $site_url"
