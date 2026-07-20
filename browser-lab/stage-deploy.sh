#!/usr/bin/env bash
# Assemble the PUBLISHABLE site bundle for britt.gg/jd-ctf-environment/, then gate it.
#
# The bundle mirrors the repo layout so relative links resolve the same locally and live:
#
#   DEST/
#     index.html                 root landing (the "Launch challenges" page)
#     warehouse-game/index.html  Challenge 3 companion game (self-contained)
#     browser-lab/
#       index.html               lab chooser (Workbench / Terminal)
#       workbench.html           the Guided Workbench GUI
#       terminal.html            terminal-only harness
#       _headers                 harmless on GH Pages, needed on Cloudflare
#       challenges/              verbatim briefs + sanitized assets (GUI + offline mode)
#       image/dist/{fs.json,flat}  the built lab image (if present)
#       vendor/*.bin             same-origin boot kernel (if present)
#
# NOT published (kept in the repo only): the image recipe (Dockerfile/build scripts/tools),
# feasibility/ and *.md design docs — ENGINE_DECISION.md and the feasibility proof both
# contain real flags. The secret-scan at the end is the backstop that enforces this.
#
# Usage: bash stage-deploy.sh [dest]   (default: build/scratch/lab/deploy)
set -euo pipefail
cd "$(dirname "$0")"
HERE="$(pwd)"                                  # browser-lab/
REPO_ROOT="$(cd .. && pwd)"
DEST="${1:-$REPO_ROOT/build/scratch/lab/deploy}"

rm -rf "$DEST"; mkdir -p "$DEST/browser-lab"

# 1) root landing
cp "$REPO_ROOT/index.html" "$DEST/index.html"

# 2) warehouse game — self-contained single file (README is a doc, not shipped)
mkdir -p "$DEST/warehouse-game"
cp "$REPO_ROOT/warehouse-game/index.html" "$DEST/warehouse-game/index.html"

# 3) browser-lab publishable surface — what the browser loads, never the recipe/docs
cp index.html workbench.html terminal.html "$DEST/browser-lab/"
[ -f _headers ] && cp _headers "$DEST/browser-lab/_headers"
cp -r challenges "$DEST/browser-lab/challenges"
if [ -d vendor ]; then
  mkdir -p "$DEST/browser-lab/vendor"; cp vendor/*.bin "$DEST/browser-lab/vendor/" 2>/dev/null || true
fi
if [ -d image/dist ]; then
  mkdir -p "$DEST/browser-lab/image/dist"
  cp image/dist/fs.json "$DEST/browser-lab/image/dist/fs.json" 2>/dev/null || true
  [ -d image/dist/flat ] && cp -r image/dist/flat "$DEST/browser-lab/image/dist/flat"
fi

# strip macOS cruft that cp -r drags along
find "$DEST" -name '.DS_Store' -delete 2>/dev/null || true

echo "staged publishable bundle -> $DEST"
find "$DEST" -maxdepth 3 -type f | sed "s#$DEST/##" | sort | sed 's/^/  /' | grep -v '/flat/' | head -40
FLAT_N=$(find "$DEST" -path '*/flat/*' -type f 2>/dev/null | wc -l | tr -d ' ')
[ "$FLAT_N" != "0" ] && echo "  browser-lab/image/dist/flat/  ($FLAT_N content-addressed objects)"

# 4) size gate — GitHub Pages rejects any single file over 100 MB
echo; echo "== size gate (GitHub Pages: 100 MB per-file limit) =="
BIG="$(find "$DEST" -type f -size +100M 2>/dev/null || true)"
if [ -n "$BIG" ]; then echo "!! these files exceed 100 MB:"; echo "$BIG"; exit 1; fi
echo "ok — no file over 100 MB"

# 5) secret-scan — refuses to ship if any flag/secret slipped into the bundle
echo; echo "== secret-scan the bundle =="
bash "$REPO_ROOT/build/secret-scan/scan.sh" "$DEST"
