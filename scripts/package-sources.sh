#!/usr/bin/env bash
# Writes dist/<name>-sources.tar.xz: the complete source of everything in the
# engine, published beside each release. FFmpeg is included already patched,
# exactly as built (Nova's build script patches a fresh clone and deletes it
# afterwards, so it is patched again here the same way). This is what the
# LGPL asks for: FFmpeg, AudioCompress and libdeinterlace are LGPL.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=${WORK:-$ROOT/work}
NAME=${1:?usage: package-sources.sh <archive name without extension>}
DIST=$ROOT/dist
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$DIST" "$STAGE/$NAME"

# Build scripts and the packaging, so the libraries can be rebuilt as they were.
cp -r "$ROOT/scripts" "$ROOT/engine" "$ROOT/licenses" "$ROOT/sources.lock" \
      "$ROOT/LICENSE" "$ROOT/NOTICE.md" "$ROOT/README.md" "$STAGE/$NAME/"
rm -rf "$STAGE/$NAME/engine/build" "$STAGE/$NAME/engine/jniLibs" "$STAGE/$NAME/engine/.gradle"

# Every fetched source, without git data or build output.
tar -C "$WORK" -cf - \
  --exclude=.git --exclude=ffmpeg.git --exclude='obj' --exclude='libs' \
  --exclude='native/prebuilt/ffmpeg' . | tar -C "$STAGE/$NAME" --one-top-level=sources -xf -

# FFmpeg, patched the way native/ffmpeg-android-builder/build.sh patches it.
B="$WORK/native/ffmpeg-android-builder"
FF="$STAGE/$NAME/sources/ffmpeg-patched"
git clone -q "$B/ffmpeg.git" "$FF"
(
  cd "$FF"
  patch -s -p1 < "$B/config_opus.patch"
  patch -s -p1 < "$B/atempo.patch"
  patch -s -p1 < "$B/sofalizer.patch"
  git apply "$B/tls_verify_default.patch"
  rm -rf .git
)

tar -C "$STAGE" -cJf "$DIST/$NAME-sources.tar.xz" "$NAME"
ls -l "$DIST/$NAME-sources.tar.xz"
