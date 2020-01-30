package com.example.riot_quiche;


import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;

import android.content.ContentResolver;

import android.media.browse.MediaBrowser;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaMetadataCompat;

import androidx.annotation.NonNull;

import com.google.android.exoplayer2.Player;

import java.util.LinkedHashMap;


public class QuicheLibrary {
    private String[] projection = {
        MediaStore.Audio.Media._ID,
        MediaStore.Audio.Media.ARTIST,
        MediaStore.Audio.Media.ARTIST_ID,
        MediaStore.Audio.Media.ALBUM,
        MediaStore.Audio.Media.ALBUM_ID,
        MediaStore.Audio.Media.DURATION,
        MediaStore.Audio.Media.TRACK,
        MediaStore.Audio.Media.TITLE,
    };

    private int id_index = 0;
    private int artist_index = 1;
    private int artist_id_index = 2;
    private int album_index = 3;
    private int album_id_index = 4;
    private int duration_index = 5;
    private int track_index = 6;
    private int title_index = 7;

    private ContentResolver contentResolver;

    private LinkedHashMap<String, MediaMetadataCompat> metadataMap;

    private static QuicheLibrary _instance;


    private QuicheLibrary (Context context) {
        contentResolver = context.getContentResolver();
        initializeMetadataMap();
    }

    public static QuicheLibrary createInstance (@NonNull Context context) {
        return _instance = new QuicheLibrary(context);
    }
    public static QuicheLibrary getInstance () throws Exception {
        if (_instance != null) {
            return _instance;
        } else {
            throw new Exception("no instance for QuicheLibrary");
        }
    }

    public LinkedHashMap<String, MediaMetadataCompat> getMetadataMap () {
        return metadataMap;
    }
    public MediaMetadataCompat getMetadataFromMediaId (String mediaId) {
        return metadataMap.get(mediaId);
    }
    public MediaBrowserCompat.MediaItem getMediaItemFromMediaId (String mediaId) {
        return new MediaBrowserCompat.MediaItem(
                metadataMap.get(mediaId).getDescription(),
                MediaBrowserCompat.MediaItem.FLAG_PLAYABLE |
                    MediaBrowserCompat.MediaItem.FLAG_BROWSABLE
        );
    }

    private void initializeMetadataMap () {
        metadataMap = new LinkedHashMap<>();
        Uri source = MediaStore.Audio.Media.INTERNAL_CONTENT_URI;
        Cursor cursor = contentResolver.query(
                source,
                projection, MediaStore.Audio.Media.IS_MUSIC + " != 0", null, null
        );

        if (cursor != null) {
            cursor.moveToFirst();

            Uri mediaUri = ContentUris.withAppendedId(source, cursor.getLong(id_index));
            Uri mediaArtUri = ContentUris.withAppendedId(source, cursor.getLong(id_index));
            Uri mediaAlbumArtUri = ContentUris.withAppendedId(source, cursor.getLong(album_id_index));

            do {
                MediaMetadataCompat metadata = new MediaMetadataCompat.Builder()
                        .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_ID, cursor.getString(id_index))
                        .putString(MediaMetadataCompat.METADATA_KEY_TITLE, cursor.getString(title_index))
                        .putString(MediaMetadataCompat.METADATA_KEY_ARTIST, cursor.getString(artist_index))
                        .putString(MediaMetadataCompat.METADATA_KEY_ALBUM, cursor.getString(album_index))
                        .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, cursor.getLong(duration_index))
                        .putString(MediaMetadataCompat.METADATA_KEY_ART_URI, mediaArtUri.toString())
                        .putString(MediaMetadataCompat.METADATA_KEY_ALBUM_ART_URI, mediaAlbumArtUri.toString())
                        .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_URI, mediaUri.toString())
                        .build();
                metadataMap.put(cursor.getString(id_index), metadata);
            } while (cursor.moveToNext());

            cursor.close();
        }
    }
}