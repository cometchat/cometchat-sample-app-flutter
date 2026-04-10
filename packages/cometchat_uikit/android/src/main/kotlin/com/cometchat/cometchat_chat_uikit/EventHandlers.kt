package com.cometchat.cometchat_chat_uikit

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import java.util.Timer
import java.util.TimerTask


object AudioRecorderEventHandler: EventChannel.StreamHandler {
    var timer: Timer? = null
    @SuppressLint("StaticFieldLeak")
    var audioRecorder: AudioRecorder? = null
    var isPaused: Boolean = false
    private val handler = Handler(Looper.getMainLooper())
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        timer = Timer()
        isPaused = false
        // Send events every 60ms for fast responsive waveform visualization
        timer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                handler.post {
                    if (!isPaused && audioRecorder?.audioRecorder != null) {
                        events?.success(audioRecorder?.audioRecorder!!.maxAmplitude.toDouble() / 32767.0)
                    }
                }
            }
        }, 0, 120)
    }

    override fun onCancel(arguments: Any?) {
        timer?.cancel()
        timer = null
        isPaused = false
    }
    
    fun pauseEvents() {
        isPaused = true
    }
    
    fun resumeEvents() {
        isPaused = false
    }
}
