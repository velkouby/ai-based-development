#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" != "main" ]]; then
  echo "Deployment is configured from main. Current branch: $branch"
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Commit tracked changes before deploying."
  exit 1
fi

site_dir="$(mktemp -d)"
trap 'rm -rf "$site_dir"' EXIT

if [[ -x ".venv/bin/mkdocs" ]]; then
  mkdocs_bin=".venv/bin/mkdocs"
else
  mkdocs_bin="mkdocs"
fi

"$mkdocs_bin" build --strict --site-dir "$site_dir"
git push origin main

echo "Pushed main. GitHub Actions will deploy the site to GitHub Pages."
