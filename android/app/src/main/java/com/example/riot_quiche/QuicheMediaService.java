package com.example.riot_quiche;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.AudioAttributes;
import android.media.AudioDeviceInfo;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.session.MediaSession;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;
import android.provider.MediaStore;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaDescriptionCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.media.AudioManagerCompat;
import androidx.media.MediaBrowserServiceCompat;
import androidx.media.session.MediaButtonReceiver;

import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DataSchemeDataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;

import java.io.FileDescriptor;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;


public class QuicheMediaService extends MediaBrowserServiceCompat {
    private static final String MEDIA_ROOT_ID = "quiche";
    private static final String MEDIA_EMPTY_ROOT_ID = "nirvana";
    private static final String LOG_TAG = "quiche_log";
    private static final String NOTIFICAION_CHANNEL_ID = "riot-quiche";
    private static final String NOTIFICATION_ID = "media-play";

    private int notificationVisibility = NotificationCompat.VISIBILITY_PUBLIC;
    private MediaSessionCompat mediaSession;
    private PlaybackStateCompat.Builder stateBuilder;
    public QuicheLibrary library;
    private ExoPlayer exoPlayer;
    private AudioManager audioManager;
    private Handler handler;
    private MediaSessionCompat.Callback mediaSessionCallback = new MediaSessionCompat.Callback() {
        private AudioManager.OnAudioFocusChangeListener onAudioFocusChangeListener =
            new AudioManager.OnAudioFocusChangeListener() {
                @Override
                public void onAudioFocusChange(int focusChange) {
                    switch (focusChange) {
                        // on focus lost
                        case AudioManager.AUDIOFOCUS_LOSS: {
                            mediaSession.getController().getTransportControls().pause();
                            break;
                        }
                        // on focus lost temporary
                        case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT: {
                            mediaSession.getController().getTransportControls().pause();
                            break;
                        }
                        // on ducking
                        case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK: {
                            /* TODO: volume 下げる　おそらくducking終わったら戻さないと
                            *   audioManager.setVolume(volume_level, AudioManager.STREAM_MUSIC)*/
                            break;
                        }
                        case AudioManager.AUDIOFOCUS_GAIN: {
                            mediaSession.getController().getTransportControls().play();
                            break;
                        }
                        default: {
                            break;
                        }
                    }
                }
        };
        private AudioAttributes audioAttributes = new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build();
        private AudioFocusRequest audioFocusRequest =
            new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(audioAttributes)
                .setAcceptsDelayedFocusGain(true)
                .setWillPauseWhenDucked(true)
                .setOnAudioFocusChangeListener(onAudioFocusChangeListener)
                .build();

        @Override
        public void onPlayFromMediaId (String mediaId, Bundle extras) {
            /*
            On played from local media ID (not an external network URI or others).
            */
            MediaBrowserCompat.MediaItem targetItem = library.getMediaItemFromMediaId(mediaId);

            DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(
                    getApplicationContext(),
                    Util.getUserAgent(getApplicationContext(), "riot-quiche")
            );
            Uri uri = targetItem.getDescription().getMediaUri();
            MediaSource mediaSource = new ExtractorMediaSource.Factory(dataSourceFactory)
                    .createMediaSource(uri);

            // prepare exoPlayer
            exoPlayer.prepare(mediaSource);

            onPlay();

            mediaSession.setMetadata(library.getMetadataFromMediaId(mediaId));

        }

        @Override
        public void onPlay () {
            if (audioManager.requestAudioFocus(audioFocusRequest) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                // activate media session
                mediaSession.setActive(true);
                exoPlayer.setPlayWhenReady(true);
            }
        }

        @Override
        public void onPause () {
            exoPlayer.setPlayWhenReady(false);
            audioManager.abandonAudioFocusRequest(audioFocusRequest);
        }

        @Override
        public void onSeekTo (long position) {
            exoPlayer.seekTo(position);
        }

        @Override
        public void onSkipToNext () {
            // TODO: 次の曲をリクエスト．．．？次の曲って？
        }

        @Override
        public void onSkipToPrevious () {
            // TODO: 前の曲をリクエスト・・・？前の曲って？
        }

        @Override
        public void onSkipToQueueItem (long i) {
            // TODO: キューの存在をまず調べなければならない．．．
        }
    };
    private Player.EventListener exoPlayerEventListener = new Player.EventListener() {

        @Override
        public void onPlayerStateChanged (boolean playWhenReady, int playbackState) {
            updatePlaybackState(playWhenReady, playbackState);
        }
    };

    private void updatePlaybackState (boolean playWhenReady, int playbackState) {
        int state;

        switch (playbackState) {
            case Player.STATE_IDLE: {
                state = PlaybackStateCompat.STATE_NONE;
                break;
            }
            case Player.STATE_BUFFERING: {
                state = PlaybackStateCompat.STATE_BUFFERING;
                break;
            }
            case Player.STATE_READY: {
                if (playWhenReady) {
                    state = PlaybackStateCompat.STATE_PLAYING;
                } else {
                    state = PlaybackStateCompat.STATE_PAUSED;
                }
                break;
            }
            case Player.STATE_ENDED: {
                state = PlaybackStateCompat.STATE_STOPPED;
                break;
            }
            default: {
                state = PlaybackStateCompat.STATE_NONE;
                break;
            }
        }

        mediaSession.setPlaybackState(new PlaybackStateCompat.Builder()
                .setActions(PlaybackStateCompat.ACTION_PLAY | PlaybackStateCompat.ACTION_PAUSE |
                        PlaybackStateCompat.ACTION_SKIP_TO_NEXT | PlaybackStateCompat.ACTION_STOP)
                .setState(state, exoPlayer.getCurrentPosition(), exoPlayer.getPlaybackParameters().speed)
                .build()
        );
    }

    @Override
    public int onStartCommand (Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);

        System.out.println("QuicheMediaService: onCreate()");
        // create an AudioManager
        audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);

        // initialize the music library
        library = QuicheLibrary.createInstance(this);

        // create a MediaSessionCompat
        mediaSession = new MediaSessionCompat(this, LOG_TAG);

        // enable callbacks from software and hardware controllers
        mediaSession.setFlags(
                MediaSessionCompat.FLAG_HANDLES_QUEUE_COMMANDS
        );

        stateBuilder = new PlaybackStateCompat.Builder()
                .setActions(PlaybackStateCompat.ACTION_PLAY | PlaybackStateCompat.ACTION_PAUSE |
                        PlaybackStateCompat.ACTION_SKIP_TO_NEXT | PlaybackStateCompat.ACTION_STOP);

        mediaSession.setPlaybackState(stateBuilder.build());

        mediaSession.setCallback(mediaSessionCallback);

        setSessionToken(mediaSession.getSessionToken());

        mediaSession.getController().registerCallback(new MediaControllerCompat.Callback() {
            @Override
            public void onPlaybackStateChanged (PlaybackStateCompat state) {
                notification();
            }

            @Override
            public void onMetadataChanged (MediaMetadataCompat metadata) {
                notification();
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
                int state = exoPlayer.getPlaybackState();
                if (state == Player.STATE_READY && exoPlayer.getPlayWhenReady()) {
                    updatePlaybackState(true, state);
                }

                handler.postDelayed(this, 500);
            }
        }, 500);

        return START_NOT_STICKY;
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

    private void notification () {
        MediaControllerCompat mediaController = mediaSession.getController();
        MediaMetadataCompat metadata = mediaController.getMetadata();

        if (metadata == null && !mediaSession.isActive()) {
            return;
        }

        MediaDescriptionCompat description = metadata.getDescription();

        Intent notificationIntent = getApplicationContext().getPackageManager()
                .getLaunchIntentForPackage(getApplicationContext().getPackageName());
        PendingIntent pendingIntent = PendingIntent.getActivity(
                getApplicationContext(), 0,
                notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT
        );

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel notificationChannel = new NotificationChannel(
                    NOTIFICAION_CHANNEL_ID,  NOTIFICATION_ID,
                    NotificationManager.IMPORTANCE_HIGH
            );

            NotificationManager notificationManager =
                    (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(notificationChannel);

        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(
                getApplicationContext(), NOTIFICAION_CHANNEL_ID);

        // TODO: intent作る　いらない気もする．．．タップして開きたいなら必要
        builder
                .setContentTitle(description.getTitle())
                .setSubText(description.getDescription())
                .setLargeIcon(description.getIconBitmap())

                .setContentIntent(pendingIntent)

                .setDeleteIntent(MediaButtonReceiver.buildMediaButtonPendingIntent(
                        this, PlaybackStateCompat.ACTION_STOP))

                .setVisibility(notificationVisibility)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)

                .setSmallIcon(R.drawable.exo_controls_play)

                .setDefaults(0)
//                .setColor()
//                .setStyle()
        ;

        // add actions
        builder.addAction(new NotificationCompat.Action(
                R.drawable.exo_controls_previous, "prev",
                MediaButtonReceiver.buildMediaButtonPendingIntent(
                        this,
                        PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS
                )
        ));
        builder.addAction(new NotificationCompat.Action(
                R.drawable.exo_controls_next, "next",
                MediaButtonReceiver.buildMediaButtonPendingIntent(this,
                        PlaybackStateCompat.ACTION_SKIP_TO_NEXT))
        );
        if (mediaController.getPlaybackState().getState() == PlaybackStateCompat.STATE_PLAYING) {
            builder.addAction(new NotificationCompat.Action(
                    R.drawable.exo_controls_pause, "pause",
                    MediaButtonReceiver.buildMediaButtonPendingIntent(this,
                            PlaybackStateCompat.ACTION_PAUSE)));
        } else {
            builder.addAction(new NotificationCompat.Action(
                    R.drawable.exo_controls_play, "play",
                    MediaButtonReceiver.buildMediaButtonPendingIntent(this,
                            PlaybackStateCompat.ACTION_PLAY)));
        }

        if (mediaController.getPlaybackState().getState() == PlaybackStateCompat.STATE_PLAYING) {
            // foreground notification (cannot delete)
            startForeground(1, builder.build());
        } else {
            // when not playing, background notification (can delete)
            stopForeground(false);
        }

    }
}
