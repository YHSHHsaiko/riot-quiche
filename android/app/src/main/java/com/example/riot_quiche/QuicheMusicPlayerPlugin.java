package com.example.riot_quiche;

import android.app.Activity;
import android.app.usage.UsageEvents;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.support.v4.media.MediaMetadataCompat;
import android.util.EventLog;

import java.io.UnsupportedEncodingException;
import java.lang.reflect.Array;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


public class QuicheMusicPlayerPlugin implements MethodCallHandler, StreamHandler  {

    private MainActivity.PluginAPI pluginAPI;
    private MainActivity.PlayerAPI playerAPI;

    public final MethodAPI methodAPI = new MethodAPI();
    public final EventAPI eventAPI = new EventAPI();

    private QuicheMusicPlayerPlugin(Activity activity) {
        pluginAPI = ((MainActivity)activity).pluginAPI;
        playerAPI = ((MainActivity)activity).playerAPI;
    }

    private static final String METHOD_CHANNEL = "test_channel";
    private static final String EVENT_CHANNEL = "event_channel";

    // function names
    public static class MethodCalls {
        public static final String butterflyEffect = "butterflyEffect";
        public static final String setQueue = "setQueue";
        public static final String setCurrentQueueIndex = "setCurrentQueueIndex";
        public static final String setCurrentMediaId = "setCurrentMediaId";
        public static final String playFromCurrentMediaId = "playFromCurrentMediaId";
        public static final String playFromCurrentQueueIndex = "playFromCurrentQueueIndex";

    }
    public static class EventCalls {
        public static final String requestPermissions = "requestPermissions";
        public static final String trigger = "trigger";
        public static final String cancelEvent = "cancelEvent";
    }
    //

    // variables: take _ the head of the variable name
    private String _currentMediaId;
    private long _currentQueueIndex;
    //


    /** Plugin registration. */
    public static QuicheMusicPlayerPlugin registerWith(Registrar registrar) {
        QuicheMusicPlayerPlugin instance = new QuicheMusicPlayerPlugin(registrar.activity());

        final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL);
        methodChannel.setMethodCallHandler(instance);

        final EventChannel eventChannel = new EventChannel(registrar.messenger(), EVENT_CHANNEL);
        eventChannel.setStreamHandler(instance);

        return instance;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method != null) {
            switch (call.method) {

                case MethodCalls.butterflyEffect: {
                    ArrayList<Music> pupa = new ArrayList<>();
                    try {
                        pupa = methodAPI.butterflyEffect(call);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    ArrayList<ArrayList<Object>> butterfly = new ArrayList<>();
                    if (pupa != null) {
                        for (Music music : pupa) {
                            ArrayList<Object> musicObject = new ArrayList<>();

                            musicObject.add(music.getId());
                            musicObject.add(music.getTitle());
                            musicObject.add(music.getArtist());
                            musicObject.add(music.getAlbum());
                            musicObject.add(music.getDuration());
                            musicObject.add(music.getArtUri());

                            butterfly.add(musicObject);
                        }
                    }
                    result.success(butterfly);
                    break;
                }
                case MethodCalls.setQueue: {
                    boolean res = false;
                    try {
                        res = methodAPI.setQueue(call);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    result.success(res);
                    break;
                }

                case MethodCalls.setCurrentQueueIndex: {
                    boolean res = false;
                    try {
                        res = methodAPI.setCurrentQueueIndex(call);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    result.success(res);
                    break;
                }

                case MethodCalls.setCurrentMediaId: {
                    boolean res = false;
                    try {
                        res = methodAPI.setCurrentMediaId(call);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    result.success(res);
                    break;
                }

                case MethodCalls.playFromCurrentMediaId: {
                    boolean res = false;
                    try {
                        res = methodAPI.playFromCurrentMediaId(call);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    result.success(res);
                    break;
                }

                case MethodCalls.playFromCurrentQueueIndex: {
                    boolean res = false;
                    try {
                        res = methodAPI.playFromCurrentQueueIndex(call);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    result.success(res);
                    break;
                }

                default: {
                    result.notImplemented();
                    break;
                }
            }
        }
    }

    @Override
    public void onListen (Object obj, EventChannel.EventSink sink) {
        if (obj == null) sink.success(null);

        ArrayList<Object> _obj = (ArrayList<Object>)obj;

        Log.d("plugin", "on listen: StreamHandler");
        Log.d("plugin", _obj.toString());

        String method = (String)_obj.get(0);
        ArrayList<Object> arguments = (_obj.size() > 1) ? new ArrayList<Object>(_obj.subList(1,_obj.size())) : null;
        switch (method) {
            case EventCalls.requestPermissions: {
                try {
                    eventAPI.requestPermissions(arguments, sink);
                } catch (Exception e) {
                    e.printStackTrace();
                    sink.error(EventCalls.requestPermissions, "", null);
                }
                break;
            }
            case EventCalls.trigger: {
                try {
                    eventAPI.trigger(sink);
                } catch (Exception e) {
                    e.printStackTrace();
                    sink.error(EventCalls.trigger, "", null);
                }
                break;
            }
            case EventCalls.cancelEvent: {
                try {
                    eventAPI.cancelEvent(arguments, sink);
                } catch (Exception e) {
                    e.printStackTrace();
                    sink.error(EventCalls.cancelEvent, "", null);
                }
                break;
            }

            default: {
                sink.success(null);
                break;
            }
        }
    }

    @Override
    public void onCancel (Object obj) {
        if (obj == null) return;

        eventAPI.cancel(obj);
    }

    public class MethodAPI {
        public ArrayList<Music> butterflyEffect (MethodCall call) {
            try {
                ArrayList<MediaMetadataCompat> metadatas =
                        new ArrayList<MediaMetadataCompat>(QuicheLibrary.getInstance().getMetadataMap().values());
                ArrayList<Music> musics = new ArrayList<Music>();

                QuicheLibrary library = QuicheLibrary.getInstance();
                for (MediaMetadataCompat metadata : metadatas) {

                    String id = metadata.getString(MediaMetadataCompat.METADATA_KEY_MEDIA_URI);
                    String title = metadata.getString(MediaMetadataCompat.METADATA_KEY_TITLE);
                    String artist = metadata.getString(MediaMetadataCompat.METADATA_KEY_ARTIST);
                    String album = metadata.getString(MediaMetadataCompat.METADATA_KEY_ALBUM);
                    Long duration = metadata.getLong(MediaMetadataCompat.METADATA_KEY_DURATION);
                    String artUri = metadata.getString(MediaMetadataCompat.METADATA_KEY_ART_URI);

                    Uri.Builder uriBuilder = new Uri.Builder();
                    Uri uri = uriBuilder.scheme("content").path(artUri).build();
                    artUri = library.getFilePathFromUri(uri);

                    Music music = new Music(id, title, artist, album, duration, artUri);
                    musics.add(music);
                }

                return musics;

            } catch (Exception e) {
                e.printStackTrace();
                return null;
            }
        }

        public boolean setQueue (MethodCall call) {
            List<Object> arguments = call.arguments();

            ArrayList<String> mediaIdList = new ArrayList<>();
            for (int i = 0; i < arguments.size(); ++i) {
                String mediaId = (String)arguments.get(i);
                mediaIdList.add(mediaId);
            }
            playerAPI.setQueue(mediaIdList);

            return true;
        }

        public boolean setCurrentQueueIndex (MethodCall call) {
            List<Object> arguments = call.arguments();

            long index = (long)arguments.get(0);
            _currentQueueIndex = (int)index;

            return true;
        }

        public boolean setCurrentMediaId (MethodCall call) {
            List<Object> arguments = call.arguments();

            String mediaId = (String)arguments.get(0);
            _currentMediaId = mediaId;

            return true;
        }

        public boolean playFromCurrentMediaId (MethodCall call) {
            if (_currentMediaId != null) {
                playerAPI.playFromMediaId(_currentMediaId);
                return true;
            } else {
                return false;
            }
        }

        public boolean playFromCurrentQueueIndex (MethodCall call) {
            if (_currentMediaId != null) {
                playerAPI.playFromQueueIndex(_currentQueueIndex);
                return true;
            } else {
                return false;
            }
        }

    }

    public class EventAPI {
        private final HashMap<Object, Runnable> listeners = new HashMap<>();
        // for one-to-one and async methods
        private final HashMap<String, Object> eventResults = new HashMap<String, Object>();


        public void cancel (Object obj) {
            listeners.remove(obj);
        }

        private void requestPermissions (ArrayList<Object> permissions, EventChannel.EventSink sink) {
            ArrayList<String> permissionIdentifiers = new ArrayList<String>();

            for (Object permission : permissions) {
                int permissionInteger = (int)permission;

                switch (permissionInteger) {
                    // associated with Dart code: Permissions[enum] index
                    case 0: {
                        permissionIdentifiers.add(QuicheRequiredPermissions.READ_EXTERNAL_STORAGE);
                        break;
                    }
                    default: {
                        Log.w("plugin", "[permission] this index will be ignored: " + permissionInteger);
                        break;
                    }
                }
            }

            pluginAPI.requestPermissions(permissionIdentifiers);

            final Handler handler = new Handler();
            listeners.put(permissions, new Runnable() {
                @Override
                public void run () {
                    try {
                        Log.d("runnable", EventCalls.requestPermissions);
                        if (listeners.containsKey(permissions)) {
                            if (eventResults.containsKey(EventCalls.requestPermissions)) {
                                HashMap<String, Boolean> permissionResult =
                                        (HashMap<String, Boolean>) eventResults.get(EventCalls.requestPermissions);
                                int[] result = new int[permissionResult.size()];

                                for (int i = 0; i < permissionIdentifiers.size(); ++i) {
                                    String permissionIdentifier = permissionIdentifiers.get(i);
                                    if (permissionResult.containsKey(permissionIdentifier)) {
//                                        result[i] = permissionResult.get(permissionIdentifier);
                                        result[i] = permissionResult.get(permissionIdentifier) ? 1 : 0;
                                    } else {
                                        result[i] = 1;
                                    }
                                }

                                sink.success(result);
                                eventResults.remove(EventCalls.requestPermissions);
                                cancel(permissions);
                            } else {
                                handler.postDelayed(this, 100);
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });

            handler.postDelayed(listeners.get(permissions), 100);
        }

        public void trigger (EventChannel.EventSink sink) {
            pluginAPI.trigger();

            final Handler handler = new Handler();
            String triggerObject = "triggerObject";
            listeners.put(triggerObject, new Runnable() {
                @Override
                public void run () {
                    try {
                        Log.d("runnable", EventCalls.trigger);
                        if (listeners.containsKey(triggerObject)) {
                            if (eventResults.containsKey(EventCalls.trigger)) {
                                boolean connectionResult = (boolean)eventResults.get(EventCalls.trigger);

                                sink.success(connectionResult);
                                eventResults.remove(EventCalls.trigger);
                                cancel(triggerObject);
                            } else {
                                handler.postDelayed(this, 100);
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });

            handler.postDelayed(listeners.get(triggerObject), 100);
        }

        public void cancelEvent (ArrayList<Object> objects, EventChannel.EventSink sink) {
            for (Object obj : objects) {
                cancel(obj);
            }

            sink.success(true);
        }

        public void receiveResult (String id, Object obj) {
            eventResults.put(id, obj);
        }
    }

}
