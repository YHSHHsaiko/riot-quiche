package com.example.riot_quiche;

import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.RemoteException;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaDescriptionCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.EventLog;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import androidx.annotation.NonNull;
import androidx.core.content.res.ResourcesCompat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ExecutionException;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {
    private QuicheMusicPlayerPlugin plugin;

    public PlayerAPI playerAPI = new PlayerAPI();
    public PluginAPI pluginAPI = new PluginAPI();

    private boolean isConnected = false;

    private QuicheMusicPlayerPlugin.EventAPI eventAPI;

    private MediaBrowserCompat mediaBrowser;
    private MediaControllerCompat mediaController;
    private MediaBrowserCompat.ConnectionCallback connectionCallback = new MediaBrowserCompat.ConnectionCallback() {
        @Override
        public void onConnected () {
            Log.d("onConnected", "trying to startService");
            boolean connectionResult = false;

            try {
                mediaController = new MediaControllerCompat(MainActivity.this, mediaBrowser.getSessionToken());
                mediaController.registerCallback(controllerCallback);

                // if a media has already played
                if (mediaController.getPlaybackState() != null &&
                        mediaController.getPlaybackState().getState() == PlaybackStateCompat.STATE_PLAYING) {
                    controllerCallback.onMetadataChanged(mediaController.getMetadata());
                    controllerCallback.onPlaybackStateChanged(mediaController.getPlaybackState());
                }

                connectionResult = true;
                isConnected = true;

                mediaBrowser.subscribe(mediaBrowser.getRoot(), subscriptionCallback);

            } catch (RemoteException e) {
                isConnected = false;
                e.printStackTrace();
            }

            // send result to plugin
            pluginAPI.sendResult(QuicheMusicPlayerPlugin.EventCalls.trigger, connectionResult);

            if (isConnected) {
                Bundle extra = new Bundle();
                extra.putInt("connection", 1);
                mediaController.getTransportControls().sendCustomAction(
                        QuicheMediaService.QuicheMediaSessionCallback.CUSTOM_ACTION_SET_CONNECT,
                        extra
                );
            }
        }

        @Override
        public void onConnectionFailed () {
            Log.e("MainActivity.connectionCallback", "MediaBrowserCompat: connection failed.");
            isConnected = false;
        }
    };
    private MediaBrowserCompat.SubscriptionCallback subscriptionCallback = new MediaBrowserCompat.SubscriptionCallback() {
        @Override
        public void onChildrenLoaded(@NonNull String parentId, @NonNull List<MediaBrowserCompat.MediaItem> children) {
            super.onChildrenLoaded(parentId, children);
        }

        @Override
        public void onError(@NonNull String parentId, @NonNull Bundle options) {
            super.onError(parentId, options);
        }

        @Override
        public void onError(@NonNull String parentId) {
            super.onError(parentId);
        }
    };
    private MediaControllerCompat.Callback controllerCallback = new MediaControllerCompat.Callback() {
        // when an information of the playing media is changed
        @Override
        public void onMetadataChanged (MediaMetadataCompat metadata) {
            // TODO: なんとかしてDartに変更を伝える．もしくは変数に入れておく？
           //  MediaDescriptionCompat description = metadata.getDescription();

           //  String title = (String)description.getTitle();
           //  Uri artUri = description.getIconUri();
        }

        // when the state of the player is changed
        @Override
        public void onPlaybackStateChanged (PlaybackStateCompat state) {
            switch (state.getState()) {
                case PlaybackStateCompat.STATE_PLAYING: {
                    // TODO: 「プレイしてる」アイコンにするように知らせる
                    break;
                }
                case PlaybackStateCompat.STATE_NONE: {
                    break;
                }
                default: {
                    // TODO: ここで「止まる」アイコンにしていいと思う．
                    break;
                }
            }

            /// TODO: set the progress of the seek bar of Flutter code.
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d("Activity", "onCreate");

        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        /* register QuicheMusicPlayerPlugin */
        plugin = QuicheMusicPlayerPlugin.registerWith(
                this.registrarFor("com.example.riot_quiche.QuicheMusicPlayerPlugin")
        );
        eventAPI = plugin.eventAPI;

        try {
            QuicheLibrary library = QuicheLibrary.getInstance();
            library.initialize(getApplicationContext());
        } catch (Exception e) {}
    }

    @Override
    protected void onDestroy () {
        Log.d("activity", "onDestroy()");

        // blueShift
        EventChannel.EventSink redShiftSink = PublicSink.getInstance().getSink(PublicSink.RED_SHIFT_KEY);
        if (redShiftSink != null) {
            Log.d("activity", "onDestroy::blueShift");
            redShiftSink.endOfStream();
            PublicSink.getInstance().setSink(PublicSink.RED_SHIFT_KEY, null);
        }
        for (EventChannel.EventSink sink : eventAPI.eventSinks.keySet()) {
            if (sink != null) {
                Log.d("activity", "onDestroy::endSink");
                sink.endOfStream();
            }
        }

        // clean up plugin's handler
        plugin.clean();

        if (mediaController != null) {
            // pause
            mediaController.getTransportControls().pause();
            mediaController.getTransportControls().sendCustomAction(
                    QuicheMediaService.QuicheMediaSessionCallback.CUSTOM_ACTION_STOP_FOREGROUND,
                    null
            );

            // unbind service
            if (mediaBrowser != null) {
                Log.d("activity", "onDestroy::unbindService");
                Bundle extra = new Bundle();
                extra.putInt("connection", 0);
                mediaController.getTransportControls().sendCustomAction(
                        QuicheMediaService.QuicheMediaSessionCallback.CUSTOM_ACTION_SET_CONNECT,
                        extra
                );

                // mediaController.unregisterCallback(controllerCallback);
                isConnected = false;

                mediaBrowser.disconnect();
                Log.d("isConnected", mediaBrowser.isConnected() + "");
            }
        }

        super.onDestroy();
    }

    @Override
    public void onRequestPermissionsResult (int requestCode, String[] permissions, int[] grantResults) {
        HashMap<String, Boolean> result = new HashMap<String, Boolean>();

        for (int i = 0; i < permissions.length; ++i) {
            String permission = permissions[i];
            int grantResult = grantResults[i];

            if (grantResult == PackageManager.PERMISSION_GRANTED) {
                result.put(permission, true);
            } else {
                result.put(permission, false);
            }
        }

        pluginAPI.sendResult(QuicheMusicPlayerPlugin.EventCalls.requestPermissions, result);
    }

    private boolean startServiceAndConnect () {
        boolean hasAlreadyStarted = isMyServiceRunning(QuicheMediaService.class);

        // start media foreground service
        startService(new Intent(getApplicationContext(), QuicheMediaService.class));

        // initialize media browser
        mediaBrowser = new MediaBrowserCompat(
                this,
                new ComponentName(this, QuicheMediaService.class),
                connectionCallback,
                null
        );

        mediaBrowser.connect();

        return hasAlreadyStarted;
    }

    @SuppressWarnings("deprecation")
    private boolean isMyServiceRunning (Class<?> serviceClass) {
        ActivityManager manager = (ActivityManager) getSystemService(ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }

    // Player APIs
    public class PlayerAPI {
        public void playFromMediaId (String mediaId, Boolean isForce) {
            Bundle extras = new Bundle();
            extras.putByte("isForce", isForce.booleanValue() ? (byte)1 : (byte)0);

            mediaController.getTransportControls().playFromMediaId(mediaId, extras);
        }

        public void playFromQueueIndex (long index, Boolean isForce) {
            Bundle extras = new Bundle();
            extras.putLong("index", index);
            extras.putByte("isForce", isForce.booleanValue() ? (byte)1 : (byte)0);

            // mediaController.getTransportControls().skipToQueueItem(index, extras);
            mediaController.getTransportControls().sendCustomAction(
                    QuicheMediaService.QuicheMediaSessionCallback.CUSTOM_ACTION_PLAY_FROM_QUEUE_INDEX,
                    extras
            );
        }

        public void setQueue (ArrayList<String> mediaIdList) {
            Bundle extras = new Bundle();
            extras.putStringArrayList("mediaIdList", mediaIdList);

            mediaController.getTransportControls().sendCustomAction(
                    QuicheMediaService.QuicheMediaSessionCallback.CUSTOM_ACTION_SET_QUEUE,
                    extras
            );

        }

        public boolean play () {
            boolean res = false;
            try {
                mediaController.getTransportControls().play();
                res = true;
            } catch (Exception e) {
                e.printStackTrace();
            }

            return res;
        }

        public boolean pause () {
            boolean res = false;
            try {
                mediaController.getTransportControls().pause();
                res = true;
            } catch (Exception e) {
                e.printStackTrace();
            }

            return res;
        }

        public boolean seekTo (long position) {
            boolean res = false;
            try {
                mediaController.getTransportControls().seekTo(position);
                res = true;
            } catch (Exception e) {
                e.printStackTrace();
            }

            return res;
        }

    }

    // plugin APIs
    public class PluginAPI {
        public void requestPermissions (ArrayList<String> permissionIdentifiers) {
            int MY_PERMISSIONS_REQUEST_READ_EXTERNAL_STORAGE = 1;

            ArrayList<String> notGrantedPermissionIdentifiers = new ArrayList<>();
            for (String permissionIdentifier : permissionIdentifiers) {
                if (checkSelfPermission(permissionIdentifier) != PackageManager.PERMISSION_GRANTED) {
                    notGrantedPermissionIdentifiers.add(permissionIdentifier);
                }
            }

            if (notGrantedPermissionIdentifiers.size() == 0) {
                HashMap<String, Boolean> result = new HashMap<String, Boolean>();
                for (String permissionIdentifier : permissionIdentifiers) {
                    result.put(permissionIdentifier, true);
                }
                sendResult(QuicheMusicPlayerPlugin.EventCalls.requestPermissions, result);
            } else {

                // MY_PERMISSIONS_REQUEST_READ_EXTERNAL_STORAGE is an
                // app-defined int constant that should be quite unique
                String[] requestedPermissions = new String[notGrantedPermissionIdentifiers.size()];
                notGrantedPermissionIdentifiers.toArray(requestedPermissions);
                MainActivity.this.requestPermissions(
                        requestedPermissions,
                        MY_PERMISSIONS_REQUEST_READ_EXTERNAL_STORAGE
                );
            }
        }

        public boolean trigger () {
            boolean result = false;

            try {
                result = startServiceAndConnect();
            } catch (Exception e) {
                e.printStackTrace();
            }
            
//            sendResult(QuicheMusicPlayerPlugin.EventCalls.trigger, result);
            return result;
        }

        ////////////////////////////////////////////////////////
        public void sendResult (String id, Object obj) {
            eventAPI.receiveResult(id, obj);
        }
        ////////////////////////////////////////////////////////
    }

}
