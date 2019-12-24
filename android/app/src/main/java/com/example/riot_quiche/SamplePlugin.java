package com.example.riot_quiche;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static androidx.core.content.ContextCompat.startForegroundService;


public class SamplePlugin implements MethodCallHandler {

    private Activity _activity;


    private SamplePlugin (Activity activity) {
        _activity = activity;
    }

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "test_channel");
        channel.setMethodCallHandler(new SamplePlugin(registrar.activity()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        List<Object> arguments = call.arguments();

        if (call.method != null) {
            switch (call.method) {
                case "hello": {
                    System.out.println("Hello! Im Java!");

                    Intent intent = new Intent(_activity, SampleForeGroundService.class);

                    if (!SampleForeGroundService.isAlreadyStarted()) {
                        startForegroundService(_activity, intent);
                    }

                    break;
                }
                case "coldSleep": {
                    int delay = (Integer)arguments.get(0);

                    SampleForeGroundService.coldSleep(delay);

                    break;
                }

                default: {
                    result.notImplemented();
                    break;
                }
            }
        }
    }
}
