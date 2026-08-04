#!/usr/bin/env bash
# ============================================================================
#  Publish the staged bundle to gh-pages in one command.
#  Runs stage-deploy.sh (strip .DS_Store, size gate, secret-scan), then builds
#  a deploy commit onto the current gh-pages tip from a throwaway blobless
#  clone and pushes it — the exact sequence in SITE_DEPLOY.md, scripted so
#  nothing is copy-pasted (the "$C:refs/..." zsh :r-modifier footgun included).
#
#  Usage:  bash browser-lab/deploy-gh-pages.sh "Deploy: <what changed>"
#
#  Rebuild the image first (browser-lab/image/build-image.sh) only if image
#  inputs changed — challenge artifacts, Dockerfile, overlay/, wordlists.
# ============================================================================
set -euo pipefail
cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"
REMOTE="https://github.com/jdtherobot/jd-ctf-environment.git"

MSG="${1:?usage: deploy-gh-pages.sh \"Deploy: <what changed>\"}"

bash "$REPO_ROOT/browser-lab/stage-deploy.sh"
BUNDLE="$REPO_ROOT/build/scratch/lab/deploy"

# Throwaway clone: commits + trees only, never the old ~760 MB image blobs.
# Never git checkout / git status in here — either would fault the blobs in.
GHP="$(mktemp -d)"
trap 'rm -rf "$GHP"' EXIT
git init -q "$GHP"
cd "$GHP"
git remote add origin "$REMOTE"
git fetch -q --depth=1 --filter=blob:none origin gh-pages

find "$BUNDLE" -name .DS_Store -delete
git --work-tree="$BUNDLE" add -A
C="$(git commit-tree "$(git write-tree)" -p FETCH_HEAD -m "$MSG")"
git push origin "${C}:refs/heads/gh-pages"   # normal push, NOT forced
echo "pushed ${C} -> gh-pages"

# Wait for the Pages build if gh is available; otherwise just point at it.
if command -v gh >/dev/null 2>&1; then
  echo "waiting for Pages build..."
  for _ in $(seq 1 18); do
    sleep 10
    STATUS="$(gh api repos/jdtherobot/jd-ctf-environment/pages/builds/latest --jq .status 2>/dev/null || echo unknown)"
    echo "  status: $STATUS"
    [ "$STATUS" = "built" ] && { echo "live: https://britt.gg/jd-ctf-environment/"; exit 0; }
    [ "$STATUS" = "errored" ] && { gh api repos/jdtherobot/jd-ctf-environment/pages/builds/latest; exit 1; }
  done
  echo "build still running — check: gh api repos/jdtherobot/jd-ctf-environment/pages/builds/latest"
else
  echo "verify with: gh api repos/jdtherobot/jd-ctf-environment/pages/builds/latest (status: built)"
fi
