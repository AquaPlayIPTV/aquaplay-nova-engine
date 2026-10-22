#!/usr/bin/env bash
# Builds Nova's playback engine for Android from the sources fetch.sh put in
# work/, and gathers every library the engine needs into engine/jniLibs/<abi>/.
#
#   ANDROID_HOME  an SDK whose ndk/ folder holds the one NDK to build with
#                 (Nova's scripts take the newest NDK they find there)
#   ABIS          default "armeabi-v7a arm64-v8a x86_64"; x86_64 is only for
#                 the Android TV emulator
#
# FFmpeg is always built here, never taken ready-made, so the source published
# beside each release is exactly what the libraries were built from. Nova's
# config_full.sh is used as it is: no --enable-gpl and no --enable-nonfree, so
# the result is LGPL.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=${WORK:-$ROOT/work}
OUT=${OUT:-$ROOT/engine/jniLibs}
ABIS=${ABIS:-"armeabi-v7a arm64-v8a x86_64"}
: "${ANDROID_HOME:?ANDROID_HOME must point at an SDK with exactly one NDK in ndk/}"

has_abi() { [[ " $ABIS " == *" $1 "* ]]; }

cd "$WORK"

# aos-avos at the pinned commit defines the default stream buffer and
# I-frame size functions inside its DEBUG_MSG block (Source/stream.c), while
# libavos.c, stream_video.c, stream_parser.c and avos_mp_video.c call them in
# every build, so a release build cannot link libavos.so. Close the block
# before them and open it again after: the debug commands stay debug-only.
(
  f=native/avos/Source/stream.c
  if ! grep -q 'AquaPlay: out of DEBUG_MSG' "$f"; then
    awk '
      /^void define_default_stream_buffer_size\(int size\)/ && !a { print "#endif /* DEBUG_MSG (AquaPlay: out of DEBUG_MSG) */"; a=1 }
      /^DECLARE_DEBUG_COMMAND\("sbs"/ && a && !b { print "#ifdef DEBUG_MSG"; b=1 }
      { print }
      END { if (!a || !b) exit 1 }
    ' "$f" > "$f.new" || { echo "stream.c: the DEBUG_MSG block is not where it was" >&2; exit 1; }
    mv "$f.new" "$f"
  fi
)

echo "== FFmpeg"
(
  cd native/ffmpeg-android-builder
  for abi in $ABIS; do
    case "$abi" in
      armeabi-v7a) arch=arm ;;
      arm64-v8a)   arch=arm64 ;;
      x86_64)      arch=x86_64 ;;
      *) echo "unsupported ABI $abi" >&2; exit 1 ;;
    esac
    bash build.sh -a "$arch" -c config_full.sh
    if ! grep -q '^License: LGPL' ../prebuilt/ffmpeg/dist-full-"$abi"/configure.log; then
      echo "FFmpeg for $abi did not configure as LGPL" >&2; exit 1
    fi
  done
)

# Nova's own make rules from here: the same ones its app build runs.
nova_make() {
  make "$@" BUILD=RELEASE \
    NDK_CPU_ARM_NEON=$(has_abi armeabi-v7a && echo 1 || echo 0) \
    NDK_CPU_ARM_64=$(has_abi arm64-v8a && echo 1 || echo 0) \
    NDK_CPU_X86_64=$(has_abi x86_64 && echo 1 || echo 0) \
    NDK_CPU_X86=0
}

echo "== libnativehelper"
nova_make native_libnativehelper

echo "== avos"
LIBAV_CONFIG=full nova_make native_build_native/avos

echo "== gathering libraries"
rm -rf "$OUT"
for abi in $ABIS; do
  mkdir -p "$OUT/$abi"
  cp native/avos/libs/"$abi"/*.so "$OUT/$abi/"
  [ -f "$OUT/$abi/libnvpnativehelper.so" ] || cp native/libnativehelper/libs/"$abi"/libnvpnativehelper.so "$OUT/$abi/"
  cp native/prebuilt/ffmpeg/dist-full-"$abi"/lib/*.so "$OUT/$abi/"
  cp native/prebuilt/dav1d/lib/"$abi"/libdav1d.so "$OUT/$abi/"
  cp native/prebuilt/opus/lib/"$abi"/libopus.so "$OUT/$abi/"
  cp native/prebuilt/libmysofa/lib/"$abi"/libmysofa.so "$OUT/$abi/"
  # Play needs 64-bit libraries that load on 16 KB memory pages.
  if [ "$abi" = arm64-v8a ] || [ "$abi" = x86_64 ]; then
    for so in "$OUT/$abi"/*.so; do
      align=$(readelf -lW "$so" | awk '$1=="LOAD"{print $NF; exit}')
      if [ $((align)) -lt 16384 ]; then
        echo "$so is aligned to $align, not 16 KB" >&2; exit 1
      fi
    done
  fi
  ls -l "$OUT/$abi"
done
