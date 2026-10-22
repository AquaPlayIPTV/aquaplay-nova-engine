#!/usr/bin/env bash
# Clones every source in sources.lock into work/, each at its exact commit, in
# the layout Nova's own build expects (AVP/, MediaLib/, native/...).
#
# A path ending in .git is made a bare repository: Nova's FFmpeg build script
# clones FFmpeg from native/ffmpeg-android-builder/ffmpeg.git when it exists,
# so putting the pinned release there means the script builds exactly that.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=${WORK:-$ROOT/work}
mkdir -p "$WORK"

grep -v '^\s*#' "$ROOT/sources.lock" | while read -r path url sha; do
  [ -z "${path:-}" ] && continue
  dest="$WORK/$path"
  echo "== $path @ $sha"
  if [[ "$path" == *.git ]]; then
    if [ ! -d "$dest" ]; then
      git init -q --bare "$dest"
      git -C "$dest" remote add origin "$url"
    fi
    git -C "$dest" fetch -q --depth 1 origin "$sha"
    git -C "$dest" update-ref refs/heads/pinned "$sha"
    git -C "$dest" symbolic-ref HEAD refs/heads/pinned
  else
    if [ ! -d "$dest/.git" ]; then
      git init -q "$dest"
      git -C "$dest" remote add origin "$url"
    fi
    git -C "$dest" fetch -q --depth 1 origin "$sha"
    git -C "$dest" checkout -q --detach "$sha"
  fi
  test "$(git -C "$dest" rev-parse HEAD)" = "$sha"
done

# Nova's top-level Makefile, as its repo manifest copies it.
cp "$WORK/AVP/Makefile" "$WORK/Makefile"
