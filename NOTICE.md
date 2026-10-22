# Notices

This repository builds the playback engine of
[Nova Video Player](https://github.com/nova-video-player/aos-AVP) into one
Android library for [AquaPlay IPTV](https://aquaplayiptv.github.io/). It holds
build scripts only; every source is fetched at the commit listed in
`sources.lock`, and the complete source of each release is attached to that
release as `*-sources.tar.xz`.

## What the engine contains

| Part | From | Licence | Licence text |
| --- | --- | --- | --- |
| avos (the engine), libavosjni, libsfdec, colour conversion | Nova Video Player, originally Archos | Apache 2.0 | `LICENSE` |
| The engine's Java classes in `com.archos.medialib` | Nova Video Player (MediaLib) | Apache 2.0 | `LICENSE` |
| libnativehelper | The Android Open Source Project, via Nova | Apache 2.0 | `licenses/libnativehelper-NOTICE.txt` |
| FFmpeg 9.0.1 (libavcodec, libavformat, libavutil, libavfilter, libswscale, libswresample), with Nova's four patches | FFmpeg; patches by Nova | LGPL 2.1 or later | `licenses/LGPL-2.1.txt`, `licenses/ffmpeg-LICENSE.md` |
| AudioCompress (libaudiocompress) | Nova, from M. Hoffmann's AudioCompress | LGPL | `licenses/LGPL-2.1.txt` |
| libdeinterlace | VLC authors and VideoLAN, via Nova | LGPL 2.1 or later | `licenses/LGPL-2.1.txt` |
| dav1d 1.5.4 | VideoLAN | BSD 2-clause | `licenses/dav1d-BSD-2-Clause.txt` |
| Opus | Xiph.Org and others | BSD 3-clause | `licenses/opus-BSD-3-Clause.txt` |
| libmysofa | Symonics GmbH, Christian Hoene | BSD 3-clause | `licenses/libmysofa-BSD-3-Clause.txt` |
| OpenSSL 3.5 (inside libavformat) | The OpenSSL Project | Apache 2.0 | `licenses/openssl-Apache-2.0.txt` |

FFmpeg is configured with Nova's `config_full.sh`, which uses neither
`--enable-gpl` nor `--enable-nonfree`; the build fails if FFmpeg reports any
licence other than LGPL. Every LGPL library is a separate shared library
(`.so`), so it can be replaced with one built from the published source.

## Changes made to Nova's code

- `com/archos/medialib/SmbProxy.java` is replaced by a stand-in written for
  this build (`engine/src/main/java`), because Nova's streams from network
  shares through its file library, which is not part of the engine.
- No other Nova file is changed. Only the engine's classes are taken from
  MediaLib; its media library, scrapers, torrent and network-share code are
  left out.

## Copyright

Build scripts and the stand-in class: Copyright 2026 AquaPlayIPTV, under the
Apache License 2.0 (`LICENSE`). Everything else belongs to its authors, under
the licences above.
