package com.example.riot_quiche;

import android.util.EventLog;

import java.util.LinkedHashMap;

import io.flutter.plugin.common.EventChannel;

public class PublicSink {
    public static final int RED_SHIFT_KEY = 0;
    public static final int QUIETUS_RAY_KEY = 1;

    private static final PublicSink instance = new PublicSink();
    private LinkedHashMap<Integer, EventChannel.EventSink>  publicSink;

    public static PublicSink getInstance () {
        return instance;
    }

    private PublicSink() {
        publicSink = new LinkedHashMap<Integer, EventChannel.EventSink>();
    }

    public void setSink (int key, EventChannel.EventSink sink) {
        publicSink.put(key, sink);
    }

    public LinkedHashMap<Integer, EventChannel.EventSink> getSink () {
        return publicSink;
    }

    public EventChannel.EventSink getSink (int key) {
        return publicSink.get(key);
    }
}
