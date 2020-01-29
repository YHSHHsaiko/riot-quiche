package com.example.riot_quiche;

import android.app.Activity;
import android.content.Intent;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static androidx.core.content.ContextCompat.startForegroundService;


public class QuicheMusicPlayerPlugin implements MethodCallHandler {

    private MainActivity _activity;

    private String _currentMediaId;


    private QuicheMusicPlayerPlugin(Activity activity) {
        _activity = (MainActivity)activity;
    }

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "test_channel");
        channel.setMethodCallHandler(new QuicheMusicPlayerPlugin(registrar.activity()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        List<Object> arguments = call.arguments();

        if (call.method != null) {
            switch (call.method) {
                case "butterflyEffect": {
                    ArrayList<String> res = new ArrayList<String>();
                    try {
                        res = butterflyEffect();
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
                    System.out.println("method call: play");
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

    private ArrayList<String> butterflyEffect () {
        try {
            return new ArrayList<String>(QuicheLibrary.getInstance().getMetadataMap().keySet());
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<String>();
        }
    }

}
