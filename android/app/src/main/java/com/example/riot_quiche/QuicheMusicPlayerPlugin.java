package com.example.riot_quiche;

import android.app.Activity;
import android.content.Intent;

import java.util.ArrayList;
import java.util.List;

import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


public class QuicheMusicPlayerPlugin implements MethodCallHandler, StreamHandler  {

    private MainActivity _activity;

    private String _currentMediaId;

    private QuicheMusicPlayerPlugin(Activity activity) {
        _activity = (MainActivity)activity;
    }

    private static final String METHOD_CHANNEL = "test_channel";
    private static final String EVENT_CHANNEL = "event_channel";

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        QuicheMusicPlayerPlugin instance = new QuicheMusicPlayerPlugin(registrar.activity());

        final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL);
        methodChannel.setMethodCallHandler(instance);

        final EventChannel eventChannel = new EventChannel(registrar.messenger(), EVENT_CHANNEL);
        eventChannel.setStreamHandler(instance);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method != null) {
            switch (call.method) {
                case "requestPermissions": {
                    Log.d("plugin", "requestPermissions: onMethodCall");
                    boolean res = false;
                    try {
                        res = requestPermissions();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    result.success(res);
                    break;
                }
                case "butterflyEffect": {
                    ArrayList<String> res = new ArrayList<>();
                    try {
                        res = butterflyEffect(call);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    result.success(res);
                    break;
                }
                case "init": {
                    boolean res = false;
                    try {
                        res = init(call);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    result.success(res);
                    break;
                }

                case "play": {
                    boolean res = false;
                    try {
                        res = play(call);
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
        Object _obj = (obj == null) ? "null" : obj;
        Log.d("plugin", "on listen: StreamHandler");
        Log.d("plugin", _obj.toString());

        sink.success(_obj);
    }

    @Override
    public void onCancel (Object obj) {
        Object _obj = (obj == null) ? "null" : obj;
        Log.d("plugin", "on cancel: StreamHandler");
        Log.d("plugin", _obj.toString());
    }

    private boolean requestPermissions() {
        // TODO: request permission
        return true;
    }

    private ArrayList<String> butterflyEffect (MethodCall call) {
        try {
            return new ArrayList<String>(QuicheLibrary.getInstance().getMetadataMap().keySet());
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<String>();
        }
    }

    private boolean init (MethodCall call) {
        List<Object> arguments = call.arguments();
        String mediaId = (String)arguments.get(0);

        _currentMediaId = mediaId;
        return true;
    }

    private boolean play (MethodCall call) {
        if (_currentMediaId != null) {
            _activity.playFromMediaId(_currentMediaId);

            return true;
        } else {
            return false;
        }
    }
}
