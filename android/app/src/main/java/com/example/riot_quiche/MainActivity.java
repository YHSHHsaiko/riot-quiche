package com.example.riot_quiche;

import android.app.PictureInPictureParams;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.RemoteException;
import android.provider.MediaStore;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaDescriptionCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.PlaybackStateCompat;

import androidx.annotation.NonNull;

import java.util.LinkedHashMap;
import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {
    private MediaBrowserCompat mediaBrowser;
    private MediaControllerCompat mediaController;
    private MediaBrowserCompat.ConnectionCallback connectionCallback = new MediaBrowserCompat.ConnectionCallback() {
        @Override
        public void onConnected () {
            try {
                mediaController = new MediaControllerCompat(MainActivity.this, mediaBrowser.getSessionToken());
                mediaController.registerCallback(controllerCallback);

                // if a media has already played
                if (mediaController.getPlaybackState() != null &&
                        mediaController.getPlaybackState().getState() == PlaybackStateCompat.STATE_PLAYING) {
                    controllerCallback.onMetadataChanged(mediaController.getMetadata());
                    controllerCallback.onPlaybackStateChanged(mediaController.getPlaybackState());
                }
            } catch (RemoteException e) {
                e.printStackTrace();
            }

            mediaBrowser.subscribe(mediaBrowser.getRoot(), subscriptionCallback);
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

        /* register SamplePlugin */
        SamplePlugin.registerWith(
                this.registrarFor("com.example.riot_quiche.SamplePlugin")
        );

        // start media foreground service
        startService(new Intent(this, QuicheMediaService.class));

        // initialize mediabrowser
        mediaBrowser = new MediaBrowserCompat(
                this,
                new ComponentName(this, QuicheMediaService.class),
                connectionCallback,
                null
        );
    }


}
