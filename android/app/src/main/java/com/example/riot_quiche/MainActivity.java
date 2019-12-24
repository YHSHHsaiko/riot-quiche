package com.example.riot_quiche;

import android.app.PictureInPictureParams;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    /* register SamplePlugin */
    SamplePlugin.registerWith(
            this.registrarFor("com.example.riot_quiche.SamplePlugin")
    );
  }


}
