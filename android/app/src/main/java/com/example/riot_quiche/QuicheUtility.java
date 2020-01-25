package com.example.riot_quiche;

import android.support.v4.media.MediaBrowserCompat;

import java.util.LinkedHashMap;

public class QuicheUtility {
    private static final QuicheUtility ourInstance = new QuicheUtility();

    public static QuicheUtility getInstance() {
        return ourInstance;
    }

    private QuicheUtility() {
        mediaMap = new LinkedHashMap<>();
    }

    // media items map components

    public void setMediaMap (LinkedHashMap<String, MediaBrowserCompat.MediaItem> targetMap) {
        mediaMap = targetMap;
    }

}
