package com.example.riot_quiche;

import android.os.Bundle;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media.MediaBrowserServiceCompat;

import java.util.List;


public class StylishMediaService extends MediaBrowserServiceCompat {
    private static final String MY_MEDIA_ROOT_ID = "stylish";
    private static final String MY_EMPTY_MEDIA_ROOT_ID = "nirvana";
    private static final String LOG_TAG = "stylish_log";
    private MediaSessionCompat mediaSession;
    private PlaybackStateCompat.Builder stateBuilder;

    @Override
    public void onCreate () {
        super.onCreate();

        // create a MediaSessionCompat
        mediaSession = new MediaSessionCompat(this, LOG_TAG);

        // enable callbacks from software and hardware controllers
        mediaSession.setFlags(
                MediaSessionCompat.FLAG_HANDLES_QUEUE_COMMANDS
        );

        stateBuilder = new PlaybackStateCompat.Builder()
                .setActions(
                        PlaybackStateCompat.ACTION_PLAY |
                        PlaybackStateCompat.ACTION_PAUSE |
                        PlaybackStateCompat.ACTION_PLAY_PAUSE
        );

        mediaSession.setPlaybackState(stateBuilder.build());
        mediaSession.setCallback(new StylishMediaSessionCallback());
    }

    @Nullable
    @Override
    public BrowserRoot onGetRoot(@NonNull String clientPackageName, int clientUid, @Nullable Bundle rootHints) {
        return null;
    }

    @Override
    public void onLoadChildren(@NonNull String parentId, @NonNull Result<List<MediaBrowserCompat.MediaItem>> result) {

    }
}
