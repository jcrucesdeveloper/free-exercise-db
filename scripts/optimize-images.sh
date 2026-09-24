#!/usr/bin/env bash
# Resizes and re-encodes every exercises/<id>/{0,1}.jpg to WebP, in place.
#
# Run from the repo root: scripts/optimize-images.sh
#
# Rationale: wtx-app (github.com/jcrucesdeveloper/wtx-app) serves these
# images on demand from a jsDelivr CDN pointed at a tagged commit of this
# fork. Upstream's originals average ~70KB each (~122MB total across 1746
# images) - fine for a git checkout, wasteful for a mobile app fetching them
# one at a time. Resizing to a mobile-appropriate width and switching to
# WebP cuts that by roughly 4-5x with no visible quality loss at the sizes
# this app displays them.
set -euo pipefail
cd "$(dirname "$0")/.."

command -v magick >/dev/null || { echo "ImageMagick's 'magick' is required" >&2; exit 1; }

MAX_WIDTH=480
QUALITY=80
count=0

for dir in exercises/*/; do
  for frame in 0 1; do
    src="${dir}${frame}.jpg"
    [ -f "$src" ] || continue
    dst="${dir}${frame}.webp"
    magick "$src" -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -quality "$QUALITY" "$dst"
    rm "$src"
    count=$((count + 1))
  done
done

echo "Converted $count images to WebP."
