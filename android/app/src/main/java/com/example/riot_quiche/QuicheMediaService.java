package com.example.riot_quiche;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Parcel;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaDescriptionCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.media.MediaBrowserServiceCompat;
import androidx.media.session.MediaButtonReceiver;

import com.google.android.exoplayer2.DefaultLoadControl;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.Renderer;
import com.google.android.exoplayer2.audio.MediaCodecAudioRenderer;
import com.google.android.exoplayer2.mediacodec.MediaCodecSelector;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;

import java.util.ArrayList;
import java.util.List;

import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;


public class QuicheMediaService extends MediaBrowserServiceCompat {
    private static final String MEDIA_ROOT_ID = "quiche";
    private static final String MEDIA_EMPTY_ROOT_ID = "nirvana";
    private static final String LOG_TAG = "quiche_log";
    private static final String NOTIFICATION_CHANNEL_ID = "riot-quiche";
    private static final String NOTIFICATION_ID = "media-play";

    public QuicheMediaSessionCallback mediaSessionCallback = new QuicheMediaSessionCallback();
    public QuicheLibrary library;

    private int notificationVisibility = NotificationCompat.VISIBILITY_PUBLIC;

    private int isConnect = 0; // false

    private ArrayList<MediaSessionCompat.QueueItem> queueItems = new ArrayList<>();
    private int queueIndex = 0;
    private MediaSessionCompat mediaSession;
    private PlaybackStateCompat.Builder stateBuilder;
    private ExoPlayer exoPlayer;
    private AudioManager audioManager;
    private Handler handler;
    private Player.EventListener exoPlayerEventListener = new Player.EventListener() {

        @Override
        public void onPlayerStateChanged (boolean playWhenReady, int playbackState) {
            updatePlaybackState();
        }
    };

    /*
     * [stateInformationObject]
     * storing playback information
     * = ======================
     * index 0: [long]
     *   The current position
     * index 1: [int]
     *   The current playback state
     * */
    int playbackStateInformationSize = 2;
    private ArrayList<Object> playbackStateInformationObject;


    private int updatePlaybackState () {
        int state;

        switch (exoPlayer.getPlaybackState()) {
            case Player.STATE_IDLE: {
                state = PlaybackStateCompat.STATE_NONE;
                Log.d("updatePlaybackState", "state: PlaybackStateCompat.STATE_NONE");

                break;
            }
            case Player.STATE_BUFFERING: {
                state = PlaybackStateCompat.STATE_BUFFERING;
                Log.d("updatePlaybackState", "state: PlaybackStateCompat.STATE_BUFFERING");
                break;
            }
            case Player.STATE_READY: {
                if (exoPlayer.getPlayWhenReady()) {
                    state = PlaybackStateCompat.STATE_PLAYING;
                    Log.d("updatePlaybackState", "state: PlaybackStateCompat.STATE_PLAYING");
                } else {
                    state = PlaybackStateCompat.STATE_PAUSED;
                    Log.d("updatePlaybackState", "state: PlaybackStateCompat.STATE_PAUSED");
                }
                break;
            }
            case Player.STATE_ENDED: {
                state = PlaybackStateCompat.STATE_STOPPED;
                Log.d("updatePlaybackState", "state: PlaybackStateCompat.STATE_STOPPED");
                break;
            }
            default: {
                state = PlaybackStateCompat.STATE_NONE;
                Log.d("updatePlaybackState", "state: PlaybackStateCompat.STATE_NONE");
                break;
            }
        }

        mediaSession.setPlaybackState(new PlaybackStateCompat.Builder()
                .setActions(
                        PlaybackStateCompat.ACTION_PLAY | PlaybackStateCompat.ACTION_PAUSE | PlaybackStateCompat.ACTION_STOP |
                        PlaybackStateCompat.ACTION_SKIP_TO_NEXT | PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS |
                        PlaybackStateCompat.ACTION_SKIP_TO_QUEUE_ITEM)
                .setState(state, exoPlayer.getCurrentPosition(), exoPlayer.getPlaybackParameters().speed)
                .build()
        );

        return state;
    }

    @Override
    public void onCreate () {
        super.onCreate();

        Log.d("QUicheMediaBrowserService", "onCreate");

        // initialize properties
        playbackStateInformationObject = new ArrayList<>();
        for (int i = 0; i < playbackStateInformationSize; ++i) {
            playbackStateInformationObject.add(null);
        }

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
                .setActions(
                        PlaybackStateCompat.ACTION_PLAY | PlaybackStateCompat.ACTION_PAUSE | PlaybackStateCompat.ACTION_STOP |
                        PlaybackStateCompat.ACTION_SKIP_TO_NEXT | PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS |
                        PlaybackStateCompat.ACTION_SKIP_TO_QUEUE_ITEM);

        mediaSession.setPlaybackState(stateBuilder.build());

        mediaSession.setCallback(mediaSessionCallback);

        setSessionToken(mediaSession.getSessionToken());

        mediaSession.getController().registerCallback(new MediaControllerCompat.Callback() {
            @Override
            public void onPlaybackStateChanged (PlaybackStateCompat state) {
                Notification notification = getNotification();
                if (notification != null && isConnect == 1) {
                    startForeground(1, notification);
                } else if (notification != null && isConnect == 0) {
                    stopForeground(false);
                }
            }

            @Override
            public void onMetadataChanged (MediaMetadataCompat metadata) {
                Notification notification = getNotification();
                if (notification != null && isConnect == 1) {
                    startForeground(1, notification);
                } else if (notification != null && isConnect == 0) {
                    stopForeground(false);
                }
            }
        });

        // initialize exoPlayer
        int bufferUnit = 1024;
        DefaultLoadControl loadControl = new DefaultLoadControl.Builder()
                .setBufferDurationsMs(
                        32*bufferUnit,
                        64*bufferUnit,
                        bufferUnit,
                        bufferUnit
                ).createDefaultLoadControl();
        MediaCodecAudioRenderer renderer = new MediaCodecAudioRenderer(
                getApplicationContext(),
                MediaCodecSelector.DEFAULT
        );
        exoPlayer = ExoPlayerFactory.newInstance(
                new Renderer[]{renderer},
                new DefaultTrackSelector(),
                loadControl
        );
        exoPlayer.addListener(exoPlayerEventListener);

        // create async handler
        handler = new Handler();
        handler.postDelayed(new Runnable () {
            @Override
            public void run () {
//                if (exoPlayer.getPlaybackState() == Player.STATE_READY && exoPlayer.getPlayWhenReady()) {
//                    updatePlaybackState();
//                }
                int currentState = updatePlaybackState();
                long currentPosition = exoPlayer.getCurrentPosition();

                /* retrieve current position */
                playbackStateInformationObject.set(0, currentPosition);

                /* retrieve current playback state */
                playbackStateInformationObject.set(1, currentState);

                /* call red shift-taste function */
                EventChannel.EventSink redShiftSink = PublicSink.getInstance().getSink();
                if (redShiftSink != null) {
                    redShiftSink.success(playbackStateInformationObject);
                }

                if (handler != null) {
                    handler.postDelayed(this, 500);
                }
            }
        }, 500);
    }

    @Override
    public int onStartCommand (Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);
        Log.d("QUicheMediaBrowserService", "onStartCommand");

        return START_STICKY;
    }

    @Override
    public void onDestroy () {
        Log.d("QuicheMediaService", "onDestroy");

        handler = null;
        library = null;
        exoPlayer.stop();
        exoPlayer.removeListener(exoPlayerEventListener);
        mediaSession.release();
        stopForeground(true);

        stopSelf();
        super.onDestroy();
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

    private Notification getNotification () {
        Log.d("NOTIFICATION", "create start");

        MediaControllerCompat mediaController = mediaSession.getController();
        MediaMetadataCompat metadata = mediaController.getMetadata();

        if (metadata == null && !mediaSession.isActive()) {
            Log.d("NOTIFICATION", "no longer recreated");
            return null;
        }

        MediaDescriptionCompat description = metadata.getDescription();

        Intent notificationIntent = getApplicationContext().getPackageManager()
                .getLaunchIntentForPackage(getApplicationContext().getPackageName());
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0,
                notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT
        );

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel notificationChannel = new NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,  NOTIFICATION_ID,
                    NotificationManager.IMPORTANCE_LOW
            );

            notificationChannel.setSound(null, null);

            NotificationManager notificationManager =
                    (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(notificationChannel);

        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(
                getApplicationContext(), NOTIFICATION_CHANNEL_ID);

//        Intent deleteIntent = new Intent(this, QuicheMediaService.class);
//        PendingIntent deletePendingIntent = PendingIntent.getService(
//                this,
//                0, deleteIntent, PendingIntent.FLAG_CANCEL_CURRENT
//        );

        PendingIntent deletePendingIntent = MediaButtonReceiver.buildMediaButtonPendingIntent(
                this, PlaybackStateCompat.ACTION_STOP);

        builder
                .setContentTitle(description.getTitle())
                .setSubText(description.getDescription())
                .setLargeIcon(description.getIconBitmap())

                .setContentIntent(pendingIntent)

                .setDeleteIntent(deletePendingIntent)

                .setVisibility(notificationVisibility)
                .setPriority(NotificationCompat.PRIORITY_LOW)

                .setSmallIcon(R.drawable.exo_controls_play)

                .setDefaults(0)
//                .setColor()
//                .setStyle()
        ;

        builder.addAction(new NotificationCompat.Action(
                R.drawable.exo_controls_previous, "prev",
                MediaButtonReceiver.buildMediaButtonPendingIntent(
                        this,
                        PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS
                )
        ));
        builder.addAction(new NotificationCompat.Action(
                R.drawable.exo_controls_next, "next",
                MediaButtonReceiver.buildMediaButtonPendingIntent(
                        this,
                        PlaybackStateCompat.ACTION_SKIP_TO_NEXT)
                )
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

        return builder.build();
    }

    public class QuicheMediaSessionCallback extends MediaSessionCompat.Callback {
        public static final String CUSTOM_ACTION_SET_QUEUE = "SET_QUEUE";
        public static final String CUSTOM_ACTION_STOP_SERVICE = "STOP_SERVICE";
        public static final String CUSTOM_ACTION_STOP_FOREGROUND = "STOP_FOREGROUND";
        public static final String CUSTOM_ACTION_SET_CONNECT = "CUSTOM_ACTION_SET_CONNECT";

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

            Log.d("service", "onPlayFromMediaId: play [" + uri.toString() + "]");
            onPlay();

            mediaSession.setMetadata(library.getMetadataFromMediaId(mediaId));

        }

        @Override
        public void onPlay () {
            if (audioManager.requestAudioFocus(audioFocusRequest) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                Log.d("onPlay", "on PLAY granted.");
                startService(new Intent(getApplicationContext(), QuicheMediaService.class));
                // activate media session
                mediaSession.setActive(true);
                exoPlayer.setPlayWhenReady(true);
            }
        }

        @Override
        public void onStop () {
            stopSelf();
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
            queueIndex++;
            if (queueIndex >= queueItems.size()) {
                queueIndex = 0;
            }
            Log.d("next", queueItems.get(queueIndex).getDescription().toString());

            onPlayFromMediaId(queueItems.get(queueIndex).getDescription().getMediaId(), null);
        }

        @Override
        public void onSkipToPrevious () {
            queueIndex--;
            if (queueIndex < 0) {
                queueIndex = queueItems.size() - 1;
            }
            Log.d("previous", queueItems.get(queueIndex).getDescription().toString());

            onPlayFromMediaId(queueItems.get(queueIndex).getDescription().getMediaId(), null);
        }

        @Override
        public void onSkipToQueueItem (long i) {
            queueIndex = (int)i;
            onPlayFromMediaId(queueItems.get(queueIndex).getDescription().getMediaId(), null);
        }

        @Override
        public void onCustomAction (String action, Bundle extras) {
            Log.d("on CustomAction", action);

            switch (action) {
                case QuicheMediaService.QuicheMediaSessionCallback.CUSTOM_ACTION_SET_QUEUE: {
                    setQueue(extras.getStringArrayList("mediaIdList"));
                    break;
                }
                case QuicheMediaService.QuicheMediaSessionCallback.CUSTOM_ACTION_STOP_SERVICE: {
                    stopSelf();
                    break;
                }
                case QuicheMediaSessionCallback.CUSTOM_ACTION_STOP_FOREGROUND: {
                    stopForeground(false);
                    break;
                }
                case QuicheMediaService.QuicheMediaSessionCallback.CUSTOM_ACTION_SET_CONNECT: {
                    isConnect = extras.getInt("connection");
                    break;
                }
                default: {
                    break;
                }
            }
        }

        private void setQueue (ArrayList<String> mediaIdList) {
            queueItems.clear();
            queueIndex = 0;

            for (int i = 0; i < mediaIdList.size(); ++i) {
                String mediaId = mediaIdList.get(i);
                queueItems.add(new MediaSessionCompat.QueueItem(library.getMediaItemFromMediaId(mediaId).getDescription(), i));
            }

            mediaSession.setQueue(queueItems);
        }
    }
}

