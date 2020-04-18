package com.example.riot_quiche;


import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;

import android.content.ContentResolver;

import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.util.Pair;

import androidx.annotation.NonNull;

import java.io.File;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

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
        MediaStore.Audio.Media.DATA
    };

    private int id_index = 0;
    private int artist_index = 1;
    private int artist_id_index = 2;
    private int album_index = 3;
    private int album_id_index = 4;
    private int duration_index = 5;
    private int track_index = 6;
    private int title_index = 7;
    private int data_index = 8;
    private int album_art_index = 9;

    private ContentResolver contentResolver;

    private LinkedHashMap<String, MediaMetadataCompat> metadataMap;
    private LinkedHashMap<String, byte[]> artMap;

    private static QuicheLibrary _instance;


    private QuicheLibrary (Context context) {
        initialize(context);
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

    public void initialize (Context context) {
        contentResolver = context.getContentResolver();
        initializeArtMap();
        initializeMetadataMap();
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
    public LinkedHashMap<String, byte[]> getArtMap () {
        return artMap;
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
                        null, MediaStore.Audio.Media.ALBUM + " ASC"
                );
            } catch (Exception e) {
                e.printStackTrace();
            }

            Log.d("library", "" + (cursor != null));

            if (cursor != null) {
                cursor.moveToFirst();

                Log.d("THREAD_COUNT", Thread.activeCount() + "");
                int pairListCapacity = 20;
                ArrayList<Pair<String, String>> PairList_ID_filePath = new ArrayList<Pair<String, String>>(pairListCapacity);
                HashMap<String, Integer> albumIdMap = new HashMap<>();
                ExecutorService executorService = Executors.newFixedThreadPool(4);
                Collection<Future<LinkedHashMap<String, byte[]>>> imageRetrievers = new LinkedList<>();
                while (!cursor.isAfterLast()) {
                    Uri mediaUri = ContentUris.withAppendedId(source, cursor.getLong(id_index));
                    Uri mediaArtUri = getMediaArtUri(cursor.getLong(album_id_index));

                    String mediaUriString = mediaUri.toString();
                    String mediaArtUriString = mediaArtUri.toString();

                    MediaMetadataCompat metadata = new MediaMetadataCompat.Builder()
                            .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_ID, cursor.getString(id_index))
                            // TODO: 仕方なく，METADATA_KEY_COMPOSERをキーとして使用している
                            .putString(MediaMetadataCompat.METADATA_KEY_COMPOSER, cursor.getString(album_id_index))
                            // TODO: 仕方なく，METADATA_KEY_AUTHORをキーとして使用している
                            .putString(MediaMetadataCompat.METADATA_KEY_AUTHOR, cursor.getString(artist_id_index))
                            .putString(MediaMetadataCompat.METADATA_KEY_TITLE, cursor.getString(title_index))
                            .putString(MediaMetadataCompat.METADATA_KEY_ARTIST, cursor.getString(artist_index))
                            .putString(MediaMetadataCompat.METADATA_KEY_ALBUM, cursor.getString(album_index))
//                            .putString(MediaMetadataCompat.METADATA_KEY_ALBUM_ART_URI, cursor.getString(album_art_index))
                            .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, cursor.getLong(duration_index))
                            .putString(MediaMetadataCompat.METADATA_KEY_ART_URI, mediaArtUriString)
                            .putString(MediaMetadataCompat.METADATA_KEY_MEDIA_URI, mediaUriString)
                            // TODO: 仕方なく，METADATA_KEY_GENREをキーとして使用している
                            .putString(MediaMetadataCompat.METADATA_KEY_GENRE, cursor.getString(data_index))
                            .build();
                    Log.d("library", "media URI: " + cursor.getString(title_index));
                    metadataMap.put(cursor.getString(id_index), metadata);

                    String id = cursor.getString(id_index);
                    String filePath = cursor.getString(data_index);
                    PairList_ID_filePath.add(new Pair<String, String>(id, filePath));

                    if (PairList_ID_filePath.size() >= pairListCapacity) {
                        Future<LinkedHashMap<String, byte[]>> imageRetriever = executorService.submit(
                                new AsyncImageRetriever(new ArrayList<>(PairList_ID_filePath))
                        );
                        imageRetrievers.add(imageRetriever);

                        PairList_ID_filePath.clear();
                    }

                    cursor.moveToNext();
                }
                cursor.close();

                if (PairList_ID_filePath.size() > 0) {
                    Future<LinkedHashMap<String, byte[]>> imageRetriever = executorService.submit(
                            new AsyncImageRetriever(new ArrayList<>(PairList_ID_filePath))
                    );
                    imageRetrievers.add(imageRetriever);
                }

                Log.d("get futures", "* start *");
                for (Future<LinkedHashMap<String, byte[]>> imageRetriever : imageRetrievers) {
                    try {
                        LinkedHashMap<String, byte[]> subMap = imageRetriever.get();
                        Log.d("asyncImageRetriever", "result map size: " + subMap.size());
                        artMap.putAll(subMap);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                Log.d("get futures", "* end *");

                executorService.shutdown();
            }
        }

    }

    private void initializeArtMap () {
        artMap = new LinkedHashMap<>();
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

    // async Image Retriever
    class AsyncImageRetriever implements Callable<LinkedHashMap<String, byte[]>> {
        private ArrayList<Pair<String, String>> id_filePaths;

        AsyncImageRetriever (ArrayList<Pair<String, String>> PairList_ID_filePath) {
            id_filePaths = PairList_ID_filePath;
        }

        @Override
        public LinkedHashMap<String, byte[]> call () {
            Log.d("AsyncImageRetriever", Thread.currentThread().getId() + "");

            LinkedHashMap<String, byte[]> result = new LinkedHashMap<String, byte[]>();

            MediaMetadataRetriever metadataRetriever = new MediaMetadataRetriever();
            for (Pair<String, String> Pair_ID_filePath : id_filePaths) {
                try { // to avoid crash, we must catch exception at this block

                    metadataRetriever.setDataSource(Pair_ID_filePath.second);
                    byte[] artArray = metadataRetriever.getEmbeddedPicture();
                    if (artArray != null) {
                        result.put(Pair_ID_filePath.first, artArray);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            return result;
        }
    }

}