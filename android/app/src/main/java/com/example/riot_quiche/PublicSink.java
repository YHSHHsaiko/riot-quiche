package com.example.riot_quiche;

import android.util.EventLog;

import io.flutter.plugin.common.EventChannel;

public class PublicSink {
    private static final PublicSink instance = new PublicSink();
    private EventChannel.EventSink publicSink;

    public static PublicSink getInstance () {
        return instance;
    }

    private PublicSink() {
        publicSink = null;
    }

    public void setSink (EventChannel.EventSink sink) {
        publicSink = sink;
    }

    public EventChannel.EventSink getSink () {
        return publicSink;
    }
}
