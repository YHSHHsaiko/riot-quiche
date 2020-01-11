package com.example.riot_quiche;

import android.os.Bundle;
import android.os.Handler;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media.MediaBrowserServiceCompat;

import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;


public class QuicheMediaService extends MediaBrowserServiceCompat {
    private static final String MEDIA_ROOT_ID = "quiche";
    private static final String MEDIA_EMPTY_ROOT_ID = "nirvana";
    private static final String LOG_TAG = "quiche_log";
    private MediaSessionCompat mediaSession;
    private PlaybackStateCompat.Builder stateBuilder;
    private QuicheLibrary library;
    private ExoPlayer exoPlayer;
    private Handler handler;


    @Override
    public void onCreate () {
        super.onCreate();

        // initialize the music library
        library = new QuicheLibrary(this);

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
                        PlaybackStateCompat.ACTION_PLAY_PAUSE);

        mediaSession.setPlaybackState(stateBuilder.build());
        mediaSession.setCallback(mediaSessionCallback);
        setSessionToken(mediaSession.getSessionToken());
        mediaSession.getController().registerCallback(new MediaControllerCompat.Callback() {
            @Override
            public void onPlaybackStateChanged (PlaybackStateCompat state) {
                notificate();
            }

            @Override
            public void onMetadataChanged (MediaMetadataCompat metadata) {
                notificate();
            }
        });

        // initialize exoPlayer
        exoPlayer = ExoPlayerFactory.newSimpleInstance(
                getApplicationContext(),
                new DefaultTrackSelector()
        );
        exoPlayer.addListener(exoPlayerEventListener);

        // create async handler
        handler = new Handler();
        handler.postDelayed(new Runnable () {
           @Override
           public void run () {
               if (exoPlayer.getPlaybackState() == Player.STATE_READY && exoPlayer.getPlayWhenReady()) {
                   updatePlaybackState();
               }

               handler.postDelayed(this, 500);
           }
        }, 500);
    }

    @Nullable
    @Override
    public BrowserRoot onGetRoot(@NonNull String clientPackageName, int clientUid, @Nullable Bundle rootHints) {
        BrowserRoot root = new BrowserRoot(MEDIA_ROOT_ID, null);
        return root;
    }

    @Override
    public void onLoadChildren(
            @NonNull final String parentId,
            @NonNull final Result<List<MediaBrowserCompat.MediaItem>> result) {

        if (parentId.equals(MEDIA_ROOT_ID)) {
            LinkedHashMap<String, MediaMetadataCompat> metadataList = library.getMetaData();
            List<MediaBrowserCompat.MediaItem> mediaItemList = new ArrayList<>();

            for (MediaMetadataCompat mbc : metadataList.values()) {
                mediaItemList.add(
                        new MediaBrowserCompat.MediaItem(
                                mbc.getDescription(),
                                MediaBrowserCompat.MediaItem.FLAG_PLAYABLE |
                                MediaBrowserCompat.MediaItem.FLAG_BROWSABLE)
                );
            }
            result.sendResult(mediaItemList);
        } else {
            result.sendResult(new ArrayList<>());
        }
    }
}
