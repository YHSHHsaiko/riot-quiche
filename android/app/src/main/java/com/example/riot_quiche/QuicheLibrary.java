package com.example.riot_quiche;


import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;

import android.content.ContentResolver;

import android.net.Uri;
import android.provider.MediaStore;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaMetadataCompat;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.LinkedHashMap;

import io.flutter.Log;


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
    public ArrayList<MediaBrowserCompat.MediaItem> getMediaItemList () {
        ArrayList<MediaBrowserCompat.MediaItem> result = new ArrayList<MediaBrowserCompat.MediaItem>();


        for (String mediaId : metadataMap.keySet()) {
            result.add(getMediaItemFromMediaId(mediaId));
        }

        return result;
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

        Uri[] sources = {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
//                MediaStore.Audio.Media.INTERNAL_CONTENT_URI
        };

        for (int i = 0; i < sources.length; ++i) {
            Cursor cursor = null;
            Uri source = sources[i];

            try {
                String selection =
                        MediaStore.Audio.Media.IS_MUSIC + " != 0 AND " +
                        MediaStore.Audio.Media.IS_ALARM + " = 0 AND " +
                        MediaStore.Audio.Media.IS_RINGTONE + " = 0 AND " +
                        MediaStore.Audio.Media.IS_NOTIFICATION + " = 0 AND " +
                        MediaStore.Audio.Media.IS_PODCAST + " = 0";
                cursor = contentResolver.query(
                        source,
                        projection, selection,
                        null, null
                );
            } catch (Exception e) {
                e.printStackTrace();
            }

            Log.d("library", "" + (cursor != null));

            if (cursor != null) {
                cursor.moveToFirst();

                while (!cursor.isAfterLast()) {
                    Uri mediaUri = ContentUris.withAppendedId(source, cursor.getLong(id_index));
                    Uri mediaArtUri = getMediaArtUri(cursor.getLong(album_id_index));

                    String mediaUriString = mediaUri.toString();
                    String mediaArtUriString = (mediaArtUri == null) ? null : mediaArtUri.toString();

                    MediaMetadataCompat metadata = new MediaMetadataCompat.Builder()
                            .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_ID, cursor.getString(id_index))
                            .putString(MediaMetadataCompat.METADATA_KEY_TITLE, cursor.getString(title_index))
                            .putString(MediaMetadataCompat.METADATA_KEY_ARTIST, cursor.getString(artist_index))
                            .putString(MediaMetadataCompat.METADATA_KEY_ALBUM, cursor.getString(album_index))
                            .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, cursor.getLong(duration_index))
                            .putString(MediaMetadataCompat.METADATA_KEY_ART_URI, mediaArtUriString)
                            .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_URI, mediaUriString)
                            .build();
                    Log.d("library", "media URI: " + cursor.getString(title_index));
                    metadataMap.put(mediaUri.toString(), metadata);

                    cursor.moveToNext();
                }

                cursor.close();
            }
        }

    }

    private Uri getMediaArtUri (Long albumId) {
        Uri mediaArtUri = null;

        try {
            mediaArtUri = ContentUris.withAppendedId(Uri.parse("content://media/external/audio/albumart"), albumId);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return mediaArtUri;
    }
}