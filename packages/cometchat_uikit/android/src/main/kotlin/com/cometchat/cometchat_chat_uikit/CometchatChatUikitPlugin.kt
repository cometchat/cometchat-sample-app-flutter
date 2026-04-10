package com.cometchat.cometchat_chat_uikit

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.os.*
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.ArrayList
import java.util.HashMap
import android.content.Intent.ACTION_SEND
import android.graphics.Bitmap
import android.graphics.Rect
import android.net.Uri
import android.provider.MediaStore
import android.view.ViewTreeObserver
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.SimpleTarget
import com.bumptech.glide.request.transition.Transition

/** ✅ SINGLE FINAL WORKING PLUGIN */
class CometchatChatUikitPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {

    companion object {
        private const val CHANNEL = "cometchat_chat_uikit"
        private const val KEYBOARD_HEIGHT_CHANNEL = "com.cometchat.keyboard_height_channel"
        private const val REQ_CAMERA = 201
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    private var filePickerDelegate: CometChatFilePickerDelegate? = null
    private var cameraPermissionResult: MethodChannel.Result? = null
    
    // Keyboard height tracking
    private var keyboardHeightEventChannel: EventChannel? = null
    private var keyboardHeightEventSink: EventChannel.EventSink? = null
    private var keyboardLayoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null

    // ----------------------------------------------------------
    // ENGINE
    // ----------------------------------------------------------

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)

        EventChannel(
            binding.binaryMessenger,
            "cometchat_uikit_shared_audio_intensity"
        ).setStreamHandler(AudioRecorderEventHandler)
        
        // Keyboard height event channel
        keyboardHeightEventChannel = EventChannel(binding.binaryMessenger, KEYBOARD_HEIGHT_CHANNEL)
        keyboardHeightEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                keyboardHeightEventSink = events
                setupKeyboardHeightListener()
            }
            
            override fun onCancel(arguments: Any?) {
                keyboardHeightEventSink = null
                removeKeyboardHeightListener()
            }
        })
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        keyboardHeightEventChannel?.setStreamHandler(null)
        removeKeyboardHeightListener()
    }

    // ----------------------------------------------------------
    // ACTIVITY
    // ----------------------------------------------------------

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity

        filePickerDelegate = CometChatFilePickerDelegate(activity)
        binding.addActivityResultListener(filePickerDelegate!!)
        binding.addRequestPermissionsResultListener(filePickerDelegate!!)
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivityForConfigChanges() {}

    // ----------------------------------------------------------
    // METHOD CHANNEL
    // ----------------------------------------------------------

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            // 🧹 CACHE
            "clear" -> result.success(clearCache())

            // 🔊 AUDIO
            "playCustomSound" ->
                AudioPlayer().playCustomSound(call, result, context)

            "stopPlayer" ->
                AudioPlayer().stopPlayer(result)

            // 🎙 AUDIO RECORDING
            "startRecordingAudio" -> {
                AudioRecorderEventHandler.audioRecorder =
                    AudioRecorder(context, activity)
                result.success(
                    AudioRecorderEventHandler.audioRecorder?.startRecording()
                )
            }

            "stopRecordingAudio" ->
                result.success(
                    AudioRecorderEventHandler.audioRecorder?.pauseRecording()
                )

            "playRecordedAudio" -> {
                val success = AudioRecorderEventHandler.audioRecorder?.playAudio() ?: false
                result.success(success)
            }

            "pausePlayingRecordedAudio" -> {
                AudioRecorderEventHandler.audioRecorder?.pausePlaying()
                result.success(true)
            }

            "resumePlayingRecordedAudio" -> {
                val success = AudioRecorderEventHandler.audioRecorder?.resumePlaying() ?: false
                result.success(success)
            }

            "seekRecordedAudio" -> {
                val position = call.argument<Int>("position") ?: 0
                val success = AudioRecorderEventHandler.audioRecorder?.seekTo(position) ?: false
                result.success(success)
            }

            "getPlaybackStatus" -> {
                val status = AudioRecorderEventHandler.audioRecorder?.getPlaybackStatus()
                result.success(status)
            }

            "extractWaveform" -> {
                val sampleCount = call.argument<Int>("sampleCount") ?: 50
                val amplitudes = AudioRecorderEventHandler.audioRecorder?.extractWaveform(sampleCount) ?: emptyList<Double>()
                result.success(amplitudes)
            }

            "extractWaveformFromFile" -> {
                val filePath = call.argument<String>("filePath")
                val sampleCount = call.argument<Int>("sampleCount") ?: 40
                if (filePath.isNullOrEmpty()) {
                    result.success(emptyList<Double>())
                } else {
                    Thread {
                        val amplitudes = extractWaveformFromFile(filePath, sampleCount)
                        Handler(Looper.getMainLooper()).post {
                            result.success(amplitudes)
                        }
                    }.start()
                }
            }

            "pauseRecordingAudio" -> {
                AudioRecorderEventHandler.pauseEvents()
                val paused = AudioRecorderEventHandler.audioRecorder?.pauseRecordingOnly() ?: false
                result.success(paused)
            }

            "resumeRecordingAudio" -> {
                AudioRecorderEventHandler.resumeEvents()
                val resumed = AudioRecorderEventHandler.audioRecorder?.resumeRecording() ?: false
                if (!resumed) {
                    // Need to restart recording on older APIs - this creates a NEW file
                    // Return false to indicate it's a fresh start, not a true resume
                    AudioRecorderEventHandler.audioRecorder = AudioRecorder(context, activity)
                    val started = AudioRecorderEventHandler.audioRecorder?.startRecording() ?: false
                    // Return false even if started successfully - it's still a fresh start
                    result.success(false)
                } else {
                    // True resume - same file continues
                    result.success(true)
                }
            }

            "releaseAudioRecorderResources" -> {
                AudioRecorderEventHandler.audioRecorder?.releaseMediaResources()
                AudioRecorderEventHandler.audioRecorder = null
                result.success(null)
            }

            "releaseMediaResources" -> {
                AudioRecorderEventHandler.audioRecorder?.releaseMediaResources()
                AudioRecorderEventHandler.audioRecorder = null
                result.success(true)
            }

            // 📁 FILE PICKER
            "pickFile" -> {
                val args = call.arguments as HashMap<*, *>

                filePickerDelegate?.startFileExplorer(
                    resolveType(args["type"] as String),
                    args["allowMultipleSelection"] as Boolean,
                    args["withData"] as Boolean,
                    CometChatFileUtils.getMimeTypes(
                        args["allowedExtensions"] as? ArrayList<String>
                    ),
                    result
                ) ?: result.error(
                    "NO_ACTIVITY",
                    "Plugin not attached to activity",
                    null
                )
            }

            // 📂 OPEN FILE
            "open_file" ->
                OpenFile.openFile(call, result, context, activity)

            // 📤 SHARE
            "shareMessage" ->
                shareMessage(call)

            // ⬇️ DOWNLOAD
            "download" ->
                download(call)

            // 📷 CAMERA PERMISSION
            "checkCameraPermission" ->
                checkCameraPermission(result)

            else -> result.notImplemented()
        }
    }

    // ----------------------------------------------------------
    // HELPERS
    // ----------------------------------------------------------

    private fun clearCache(): Boolean =
        try {
            val dir = File(context.cacheDir, "file_picker")
            dir.listFiles()?.forEach { it.delete() }
            true
        } catch (e: Exception) {
            false
        }

    private fun resolveType(type: String): String? =
        when (type) {
            "audio" -> "audio/*"
            "image" -> "image/*"
            "video" -> "video/*"
            "media" -> "image/*,video/*"
            "file" -> "*/*"
            "any", "custom" -> "*/*"
            "dir" -> "dir"
            else -> null
        }

    // ----------------------------------------------------------
    // SHARE
    // ----------------------------------------------------------

    private fun shareMessage(call: MethodCall) {
        val args = call.arguments as HashMap<String, String>
        val type = args["type"]

        val intent = Intent(ACTION_SEND)

        if (type == "text") {
            intent.type = "text/plain"
            intent.putExtra(Intent.EXTRA_TEXT, args["message"])
            val chooser = Intent.createChooser(intent, "Share")
            chooser.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(chooser)
        } else {
            Glide.with(context).asBitmap()
                .load(Uri.parse(args["fileUrl"]))
                .into(object : SimpleTarget<Bitmap>() {
                    override fun onResourceReady(
                        resource: Bitmap,
                        transition: Transition<in Bitmap>?
                    ) {
                        val path = MediaStore.Images.Media.insertImage(
                            context.contentResolver,
                            resource,
                            args["mediaName"],
                            "Media"
                        )
                        intent.type = args["mimeType"]
                        intent.putExtra(Intent.EXTRA_STREAM, Uri.parse(path))
                        val chooser = Intent.createChooser(intent, "Share")
                        chooser.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        context.startActivity(chooser)
                    }
                })
        }
    }

    // ----------------------------------------------------------
    // DOWNLOAD
    // ----------------------------------------------------------

    private fun download(call: MethodCall) {
        val url = call.argument<String>("fileUrl") ?: return

        Thread {
            try {
                val conn = URL(url).openConnection() as HttpURLConnection
                val file = File(
                    context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS),
                    url.substringAfterLast("/")
                )
                conn.inputStream.use { input ->
                    FileOutputStream(file).use { output ->
                        input.copyTo(output)
                    }
                }
                toast("Download Success")
            } catch (e: Exception) {
                toast("Download Failed")
            }
        }.start()
    }

    // ----------------------------------------------------------
    // CAMERA PERMISSION
    // ----------------------------------------------------------

    private fun checkCameraPermission(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
        } else {
            cameraPermissionResult = result
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.CAMERA),
                REQ_CAMERA
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == REQ_CAMERA) {
            val granted =
                grantResults.isNotEmpty() &&
                        grantResults[0] == PackageManager.PERMISSION_GRANTED
            cameraPermissionResult?.success(granted)
            cameraPermissionResult = null
        }
        return true
    }

    private fun toast(msg: String) {
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(context, msg, Toast.LENGTH_SHORT).show()
        }
    }
    
    // ----------------------------------------------------------
    // WAVEFORM EXTRACTION
    // ----------------------------------------------------------
    
    private fun extractWaveformFromFile(filePath: String, sampleCount: Int): List<Double> {
        val file = File(filePath)
        if (!file.exists()) {
            return emptyList()
        }
        
        return try {
            val amplitudes = mutableListOf<Double>()
            
            val extractor = android.media.MediaExtractor()
            extractor.setDataSource(filePath)
            
            // Find audio track
            var audioTrackIndex = -1
            for (i in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(android.media.MediaFormat.KEY_MIME)
                if (mime?.startsWith("audio/") == true) {
                    audioTrackIndex = i
                    break
                }
            }
            
            if (audioTrackIndex < 0) {
                extractor.release()
                return emptyList()
            }
            
            extractor.selectTrack(audioTrackIndex)
            val format = extractor.getTrackFormat(audioTrackIndex)
            
            val duration = if (format.containsKey(android.media.MediaFormat.KEY_DURATION)) {
                format.getLong(android.media.MediaFormat.KEY_DURATION)
            } else {
                0L
            }
            
            if (duration <= 0) {
                extractor.release()
                return emptyList()
            }
            
            val chunkDuration = duration / sampleCount
            
            val mime = format.getString(android.media.MediaFormat.KEY_MIME)
            val decoder = android.media.MediaCodec.createDecoderByType(mime!!)
            decoder.configure(format, null, null, 0)
            decoder.start()
            
            val bufferInfo = android.media.MediaCodec.BufferInfo()
            var inputDone = false
            var outputDone = false
            var currentChunk = 0
            var chunkSampleSum = 0.0
            var chunkSampleCount = 0
            var lastChunkTime = 0L
            
            while (!outputDone && currentChunk < sampleCount) {
                if (!inputDone) {
                    val inputBufferIndex = decoder.dequeueInputBuffer(10000)
                    if (inputBufferIndex >= 0) {
                        val inputBuffer = decoder.getInputBuffer(inputBufferIndex)
                        val sampleSize = extractor.readSampleData(inputBuffer!!, 0)
                        
                        if (sampleSize < 0) {
                            decoder.queueInputBuffer(inputBufferIndex, 0, 0, 0, 
                                android.media.MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            decoder.queueInputBuffer(inputBufferIndex, 0, sampleSize, 
                                extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }
                
                val outputBufferIndex = decoder.dequeueOutputBuffer(bufferInfo, 10000)
                if (outputBufferIndex >= 0) {
                    val outputBuffer = decoder.getOutputBuffer(outputBufferIndex)
                    
                    if (outputBuffer != null && bufferInfo.size > 0) {
                        val shortBuffer = outputBuffer.asShortBuffer()
                        val samples = ShortArray(shortBuffer.remaining())
                        shortBuffer.get(samples)
                        
                        for (sample in samples) {
                            val normalizedSample = sample.toDouble() / Short.MAX_VALUE
                            chunkSampleSum += normalizedSample * normalizedSample
                            chunkSampleCount++
                        }
                        
                        val currentTime = bufferInfo.presentationTimeUs
                        if (currentTime - lastChunkTime >= chunkDuration && chunkSampleCount > 0) {
                            val rms = kotlin.math.sqrt(chunkSampleSum / chunkSampleCount)
                            
                            // For silent audio, rms will be very low (< 0.01)
                            // Scale appropriately - silent audio should show flat/low bars
                            val normalizedAmplitude = if (rms < 0.01) {
                                // Silent or near-silent - show minimal bar
                                0.15 + rms * 5.0
                            } else if (rms < 0.1) {
                                // Quiet audio
                                0.2 + rms * 3.0
                            } else if (rms < 0.3) {
                                // Normal audio
                                0.5 + (rms - 0.1) * 2.0
                            } else {
                                // Loud audio
                                0.9 + (rms - 0.3) * 0.33
                            }
                            
                            amplitudes.add(normalizedAmplitude.coerceIn(0.15, 1.0))
                            
                            chunkSampleSum = 0.0
                            chunkSampleCount = 0
                            lastChunkTime = currentTime
                            currentChunk++
                        }
                    }
                    
                    decoder.releaseOutputBuffer(outputBufferIndex, false)
                    
                    if (bufferInfo.flags and android.media.MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                        outputDone = true
                    }
                }
            }
            
            // Add remaining chunk
            if (chunkSampleCount > 0 && currentChunk < sampleCount) {
                val rms = kotlin.math.sqrt(chunkSampleSum / chunkSampleCount)
                val normalizedAmplitude = if (rms < 0.01) {
                    0.15 + rms * 5.0
                } else if (rms < 0.1) {
                    0.2 + rms * 3.0
                } else if (rms < 0.3) {
                    0.5 + (rms - 0.1) * 2.0
                } else {
                    0.9 + (rms - 0.3) * 0.33
                }
                amplitudes.add(normalizedAmplitude.coerceIn(0.15, 1.0))
            }
            
            decoder.stop()
            decoder.release()
            extractor.release()
            
            amplitudes
        } catch (e: Exception) {
            emptyList()
        }
    }
    
    // ----------------------------------------------------------
    // KEYBOARD HEIGHT
    // ----------------------------------------------------------
    
    private fun setupKeyboardHeightListener() {
        if (!::activity.isInitialized) return
        
        val rootView = activity.window?.decorView?.rootView ?: return
        
        keyboardLayoutListener = ViewTreeObserver.OnGlobalLayoutListener {
            val r = Rect()
            rootView.getWindowVisibleDisplayFrame(r)
            
            val screenHeight = rootView.height
            var keypadHeight = screenHeight - r.bottom
            
            val displayMetrics = activity.resources?.displayMetrics
            val density = displayMetrics?.density ?: 1f
            
            // Get safe area bottom (navigation bar height in logical pixels)
            val safeAreaBottom = getSafeAreaBottom() / density
            
            // Keyboard height calculation:
            // When keyboard is open, keypadHeight includes both keyboard AND navigation bar
            // We want just the keyboard height (without nav bar) because the keyboard covers the nav bar
            // But we send safeAreaBottom separately so Flutter knows what to use when keyboard is closed
            val logicalKeypadHeight = keypadHeight / density
            
            // Create data map with both values
            // keyboardHeight: the raw height from screen bottom to visible area (includes nav bar when keyboard open)
            // safeAreaBottom: the navigation bar height (for when keyboard is closed)
            val data = hashMapOf<String, Any>(
                "keyboardHeight" to if (keypadHeight > screenHeight * 0.15) logicalKeypadHeight.toDouble() else 0.0,
                "safeAreaBottom" to safeAreaBottom.toDouble()
            )
            
            keyboardHeightEventSink?.success(data)
        }
        
        rootView.viewTreeObserver?.addOnGlobalLayoutListener(keyboardLayoutListener)
    }
    
    private fun getSafeAreaBottom(): Int {
        if (!::activity.isInitialized) return 0
        
        val decorView = activity.window?.decorView ?: return 0
        
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val windowInsets = decorView.rootWindowInsets
            val insets = windowInsets?.getInsets(android.view.WindowInsets.Type.systemBars())
            insets?.bottom ?: 0
        } else {
            @Suppress("DEPRECATION")
            decorView.rootWindowInsets?.systemWindowInsetBottom ?: 0
        }
    }
    
    private fun removeKeyboardHeightListener() {
        if (!::activity.isInitialized) return
        
        val rootView = activity.window?.decorView?.rootView ?: return
        keyboardLayoutListener?.let {
            rootView.viewTreeObserver?.removeOnGlobalLayoutListener(it)
        }
        keyboardLayoutListener = null
    }
    
    private fun getNavigationBarHeight(): Int {
        if (!::activity.isInitialized) return 0
        
        val resourceId = activity.resources?.getIdentifier(
            "navigation_bar_height", "dimen", "android"
        )
        return if (resourceId != null && resourceId > 0) {
            activity.resources?.getDimensionPixelSize(resourceId) ?: 0
        } else {
            0
        }
    }
    
    private fun isNavigationBarVisible(): Boolean {
        if (!::activity.isInitialized) return false
        
        val decorView = activity.window?.decorView
        val rootWindowInsets = decorView?.rootWindowInsets ?: return false
        
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            rootWindowInsets.isVisible(android.view.WindowInsets.Type.navigationBars())
        } else {
            @Suppress("DEPRECATION")
            rootWindowInsets.systemWindowInsetBottom > 0
        }
    }
}
