package com.example.riot_quiche;

import android.content.ComponentName;
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

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ExecutionException;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {
    public PlayerAPI playerAPI = new PlayerAPI();
    public PluginAPI pluginAPI = new PluginAPI();

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

                // send result to plugin
                pluginAPI.sendResult(QuicheMusicPlayerPlugin.EventCalls.trigger, connectionResult);

                mediaBrowser.subscribe(mediaBrowser.getRoot(), subscriptionCallback);

            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onConnectionFailed () {
            Log.e("MainActivity.connectionCallback", "MediaBrowserCompat: connection failed.");
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
            MediaDescriptionCompat description = metadata.getDescription();

            String title = (String)description.getTitle();
            Uri artUri = description.getIconUri();
        }

        // when the state of the player is changed
        @Override
        public void onPlaybackStateChanged (PlaybackStateCompat state) {
            switch (state.getState()) {
                case PlaybackStateCompat.STATE_PLAYING: {
                    // TODO: 「プレイしてる」アイコンにするように知らせる
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
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        /* register QuicheMusicPlayerPlugin */
        QuicheMusicPlayerPlugin plugin = QuicheMusicPlayerPlugin.registerWith(
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
        super.onDestroy();

        // unbind service
        if (mediaBrowser != null) {
            eventAPI.blueShift();
            mediaBrowser.disconnect();
        }
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

    private void startServiceAndConnect () {
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
    }

    // Player APIs
    public class PlayerAPI {
        public void playFromMediaId (String mediaId) {
            mediaController.getTransportControls().playFromMediaId(mediaId, null);
        }

        public void playFromQueueIndex (long index) {
            mediaController.getTransportControls().skipToQueueItem(index);
        }

        public void setQueue (ArrayList<String> mediaIdList) {
            Bundle extras = new Bundle();
            extras.putStringArrayList("mediaIdList", mediaIdList);

            mediaController.getTransportControls().sendCustomAction(
                    QuicheMediaService.QuicheMediaSessionCallback.CUSTOM_ACTION_SET_QUEUE,
                    extras
            );

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

        public void trigger () {
            try {
                startServiceAndConnect();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        ////////////////////////////////////////////////////////
        public void sendResult (String id, Object obj) {
            eventAPI.receiveResult(id, obj);
        }
        ////////////////////////////////////////////////////////
    }

}
