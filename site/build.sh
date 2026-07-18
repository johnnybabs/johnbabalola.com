#!/usr/bin/env bash
# Build the static site into site/dist.
#
# The site is plain HTML/CSS (ADR-0003), so "build" is an assembly step: copy
# the source assets into a clean dist/ that the deploy syncs to S3. Keeping a
# separate dist/ means the S3 bucket only ever holds shippable files, never
# tooling (this script), dotfiles, or docs.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DIST="${SRC}/dist"

rm -rf "${DIST}"
mkdir -p "${DIST}"

# Copy everything under site/ except build tooling, the dist output itself,
# dotfiles, and markdown docs. rsync is present on ubuntu-latest and locally.
rsync -a \
  --exclude 'dist/' \
  --exclude 'build.sh' \
  --exclude '.gitkeep' \
  --exclude '.*' \
  --exclude '*.md' \
  "${SRC}/" "${DIST}/"

echo "Built site into ${DIST}:"
find "${DIST}" -type f | sed "s|${DIST}/|  |" | sort
