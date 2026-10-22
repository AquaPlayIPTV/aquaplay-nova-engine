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
 * Stands in for Nova's Proxy, the base of its UPnP and network-share proxies,
 * which AvosMediaMetadataRetriever holds on to. This engine plays http(s)
 * addresses and local files only, so there is never a proxy to start or to
 * stop: needToStream says no, and the retriever opens the address itself.
 *
 * Written for this build; not part of Nova.
 */
public abstract class Proxy {
    protected final Uri mUri;

    protected Proxy(Uri uri) {
        mUri = uri;
    }

    public static boolean needToStream(String scheme) {
        return false;
    }

    protected abstract Uri start();

    public abstract void stop();

    public static Proxy setDataSource(Uri uri, IMediaMetadataRetriever mr, Map<String, String> headers)
            throws IllegalArgumentException {
        throw new IllegalArgumentException("No proxy in this engine: " + uri.getScheme());
    }

    public static Proxy setDataSource(Uri uri, IMediaPlayer mp, Map<String, String> headers) throws IOException {
        throw new IOException("No proxy in this engine: " + uri.getScheme());
    }
}
