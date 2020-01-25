package com.example.riot_quiche;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioDeviceInfo;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.session.MediaSession;
import android.os.Bundle;
import android.os.Handler;
import android.provider.MediaStore;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media.AudioManagerCompat;
import androidx.media.MediaBrowserServiceCompat;

import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;

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
    private AudioManager audioManager;
    private Handler handler;
    private MediaSessionCompat.Callback mediaSessionCallback = new MediaSessionCompat.Callback() {

        @Override
        public void onPlayFromMediaId (String mediaId, Bundle extras) {
            /*
            On played from local media ID (not an external network URI or others).
            */
            MediaBrowserCompat.MediaItem targetItem = library.getMediaItemFromMediaId(mediaId);

            DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(
                    getApplicationContext(),
                    Util.getUserAgent(getApplicationContext(), "Sevas")
            );
            MediaSource mediaSource = new ExtractorMediaSource.Factory(dataSourceFactory)
                    .createMediaSource(targetItem.getDescription().getMediaUri());

            // prepare exoPlayer
            exoPlayer.prepare(mediaSource);

            onPlay();

            mediaSession.setMetadata(library.getMetadataFromMediaId(mediaId));

        }

        @Override
        public void onPlay () {
            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build();
            AudioFocusRequest afr = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                    .setAudioAttributes(audioAttributes)
                    .setAcceptsDelayedFocusGain(true)
                    .setWillPauseWhenDucked(true)
                    .setOnAudioFocusChangeListener((int focusChange) -> {
                        // TODO: on focus change ここで何するねん・・・・
                    })
                    .build();
            if (audioManager.requestAudioFocus(afr) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                // activate media session
                mediaSession.setActive(true);
                exoPlayer.setPlayWhenReady(true);
            }
        }
    };

    @Override
    public void onCreate () {
        super.onCreate();

        // create an AudioManager
        audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);

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

        List<MediaBrowserCompat.MediaItem> mediaItemList = new ArrayList<>();
//        if (parentId.equals(MEDIA_ROOT_ID)) {
//            LinkedHashMap<String, MediaMetadataCompat> metadataList = library.getMetaData();
//
//            for (MediaMetadataCompat mbc : metadataList.values()) {
//                mediaItemList.add(
//                        new MediaBrowserCompat.MediaItem(
//                                mbc.getDescription(),
//                                MediaBrowserCompat.MediaItem.FLAG_PLAYABLE |
//                                MediaBrowserCompat.MediaItem.FLAG_BROWSABLE)
//                );
//            }
//        }

        //TODO: 今は何も返していない（Metadataは全てQuicheLibraryが保持している）.
        result.sendResult(mediaItemList);
    }
}
