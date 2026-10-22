# AquaPlay Nova engine

The playback engine of [Nova Video Player](https://github.com/nova-video-player/aos-AVP)
(avos, with FFmpeg and dav1d), built as one Android library (`.aar`) for
AquaPlay IPTV on Android TV, where it plays films and series episodes.

This repository holds build scripts only. It contains no AquaPlay code; Nova's
and FFmpeg's sources are fetched at exact commits (`sources.lock`), and the
complete source of every release is attached to that release.

## What a build produces

- `nova-engine-<version>-release.aar`: the engine's Java classes
  (`com.archos.medialib`, from Nova's MediaLib) and its native libraries for
  `armeabi-v7a`, `arm64-v8a` and `x86_64` (the last for the emulator only). The
  64-bit libraries are checked to load on 16 KB memory pages.
- `aquaplay-nova-engine-<version>-sources.tar.xz`: every source the libraries
  were built from, FFmpeg included as patched and built.

Releases are made from tags (`v0.1.0`). Every other push builds the same files
as a workflow artifact.

## Building it yourself

On Linux, with an Android SDK whose `ndk/` folder holds one NDK (the workflow
uses 28.2.13676358), JDK 17, Gradle 8.11, and `nasm`, `pkg-config` and `patch`:

```sh
scripts/fetch.sh
ANDROID_HOME=/path/to/sdk-with-one-ndk scripts/build-native.sh
(cd engine && gradle assembleRelease)
scripts/package-sources.sh aquaplay-nova-engine-dev
```

## Using it in an app

Put the `.aar` in the app and add the one library it uses:

```kotlin
implementation(files("libs/nova-engine-0.1.0-release.aar"))
implementation("org.slf4j:slf4j-api:2.0.17")
```

Then `LibAvos.init(context)` once, and `AvosMediaPlayer` works like Android's
`MediaPlayer`: `setDataSource`, `setDisplay`/`setSurface`, `prepareAsync`,
`start`, `seekTo`, with listeners for prepared, completion, errors, buffering
and subtitles.

## Licences

See [NOTICE.md](NOTICE.md). In short: Nova's code is Apache 2.0, FFmpeg and two
small libraries are LGPL (each its own `.so`), and the rest is BSD or Apache.
