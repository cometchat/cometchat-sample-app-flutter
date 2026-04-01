package com.cometchat.cometchat_uikit_shared

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.util.Timer
import java.util.TimerTask


object AudioRecorderEventHandler: EventChannel.StreamHandler {
//    private var eventSink: EventChannel.EventSink? = null
 var timer: Timer? = null
    @SuppressLint("StaticFieldLeak")
    var audioRecorder: AudioRecorder? = null
    // Handle event in main thread.
    private val handler = Handler(Looper.getMainLooper())
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        timer = Timer()
        // Start the Timer to run every one second (1000 milliseconds)
        timer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                // Add your logic to do something every second here
                // For example, you can send a value to the EventSink
                handler.post {
                    if (audioRecorder?.audioRecorder!=null){
                        events?.success(audioRecorder?.audioRecorder!!.maxAmplitude.toDouble()/32767.0)
                    }
                    Log.e("onAttachedToEngine","EventChannel cometchat_uikit_shared_audio_intensity event is emitted")
                }
            }
        }, 0, 100)
    }

    override fun onCancel(arguments: Any?) {
        // Clean up any resources (if needed)
        timer?.cancel()
        timer = null
        Log.e("onAttachedToEngine","EventChannel cometchat_uikit_shared_audio_intensity event is cancelled")
    }


}