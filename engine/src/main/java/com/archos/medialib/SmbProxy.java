/*
 * Copyright 2026 AquaPlayIPTV
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.archos.medialib;

import android.net.Uri;

import java.io.IOException;
import java.util.Map;

/**
 * Stands in for Nova's SmbProxy, which streams files from network shares
 * (SMB, FTP, SFTP, WebDAV) through a local HTTP server and needs Nova's whole
 * file library to do it. This engine only plays http(s) addresses and local
 * files, so nothing ever needs a proxy: AvosMediaPlayer asks, hears no, and
 * opens the address itself.
 *
 * Written for this build; not part of Nova.
 */
public final class SmbProxy {

    private SmbProxy() {
    }

    public static boolean needToStream(String scheme) {
        return false;
    }

    public static SmbProxy setDataSource(Uri uri, IMediaPlayer mp, Map<String, String> headers) throws IOException {
        throw new IOException("Network shares are not supported: " + uri.getScheme());
    }

    public void stop() {
    }

    public int doesCurrentFileExists() {
        return -1;
    }
}
