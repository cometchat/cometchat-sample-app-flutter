package com.cometchat.cometchat_chat_uikit

import android.Manifest
import android.Manifest.permission.READ_EXTERNAL_STORAGE
import android.Manifest.permission.RECORD_AUDIO
import android.Manifest.permission.WRITE_EXTERNAL_STORAGE
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.os.Environment
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.io.IOException
import java.util.Date
import java.text.SimpleDateFormat
import android.media.AudioAttributes
import android.media.AudioManager

/**
 * AudioRecorder class
 *
 * This class is used to record and play recorded audio
 *
 * @param context the Context of component from where the instance of AudioRecorder is created.
 * @property audioRecorder the object that contains the audioRecorder.
 * @constructor Creates an MediaRecorder object.
 */
class AudioRecorder (private val context: Context, private val activity: Activity) : AudioManager.OnAudioFocusChangeListener{


    // creating a variable for media recorder object class.
    var audioRecorder: MediaRecorder? = null

    // creating a variable for media-player class
    private var audioPlayer: MediaPlayer? = null

    // string variable is created for storing a file name
    private var fileName: String? = null

    private var audioManager: AudioManager? = null // AudioManager for managing audio focus
    private var hasAudioFocus = false // To track audio focus status

//    private var timer: Timer? = null


    /**
     * Requests audio focus before starting playback or recording.
     */
    private fun requestAudioFocus(): Boolean {
        if (audioManager == null) {
            audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        }
        val result = audioManager?.requestAudioFocus(
            this,
            AudioManager.STREAM_MUSIC,
            AudioManager.AUDIOFOCUS_GAIN
        )
        hasAudioFocus = result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        return hasAudioFocus
    }

    /**
     * Releases audio focus after stopping playback or recording.
     */
    private fun releaseAudioFocus() {
        if (hasAudioFocus && audioManager != null) {
            audioManager?.abandonAudioFocus(this)
            hasAudioFocus = false
        }
    }

    /**
     * Handles audio focus changes.
     */
    override fun onAudioFocusChange(focusChange: Int) {
        when (focusChange) {
            AudioManager.AUDIOFOCUS_GAIN -> {
                // Regained focus
                audioPlayer?.start()
            }
            AudioManager.AUDIOFOCUS_LOSS -> {
                // Lost focus permanently, stop playback
                audioPlayer?.pause()
                releaseAudioFocus()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                // Lost focus temporarily, pause playback
                audioPlayer?.pause()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                // Lost focus temporarily, lower the volume
                audioPlayer?.setVolume(0.3f, 0.3f)
            }
        }
    }

    // constant for storing audio permission
    public fun startRecording(): Boolean {
        // check permission method is used to check
        // that the user has granted permission
        // to record and store the audio.
        if (checkPermissions()) {
            // we are here initializing our filename variable
            // with the path of the recorded audio file.
            fileName = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)?.absolutePath

            fileName += "/audio-recording-${SimpleDateFormat("yyyyMMddHHmmss").format(Date())}.m4a"
            Log.e("AudioRecorder","permission granted for audio recording $fileName")

            // below method is used to initialize
            // the media recorder class
            audioRecorder = MediaRecorder()

            // below method is used to set the audio
            // source which we are using a mic.
            audioRecorder?.setAudioSource(MediaRecorder.AudioSource.MIC)

            // below method is used to set
            // the output format of the audio.
            audioRecorder?.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)

            // below method is used to set the
            // audio encoder for our recorded audio.
            audioRecorder?.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)

            // below method is used to set the
            // output file location for our recorded audio
            audioRecorder?.setOutputFile(fileName)
            Log.e("AudioRecorder","lower version permission granted for audio recording $fileName")

            try {
                // below method will prepare
                // our audio recorder class
                audioRecorder?.prepare()
            } catch (e: IOException) {
                Log.e("TAG", "prepare() failed")
            }
            // start method will start
            // the audio recording.
            if (requestAudioFocus()) { // Request audio focus before starting recording
                audioRecorder?.start()
                return true
            } else {
                Log.e("AudioRecorder", "Failed to gain audio focus")
                return false
            }
        } else {
//             if audio recording permissions are
//             not granted by user below method will
//             ask for runtime permission for mic and storage.

            requestPermissions()
            Log.e("AudioRecorder","permission not granted for audio recording or write to external storage so request permission")
            return false
        }
    }


    private fun requestPermissions() {
        // this method is used to request
        // the permission for audio recording and storage.
        if (ContextCompat.checkSelfPermission(context, RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            Log.e("AudioRecorder","in requestPermissions permission not granted for audio recording so request permission")
            ActivityCompat.requestPermissions(activity,  arrayOf<String>(RECORD_AUDIO), 101);
        }

    }

    private  fun checkPermissions(): Boolean {
        // this method is used to check permission
        val audioRecordAccess = ContextCompat.checkSelfPermission(context, RECORD_AUDIO)
        return   audioRecordAccess == PackageManager.PERMISSION_GRANTED
    }


    fun playAudio(): Boolean {
        // Check if we have a valid file to play
        if (fileName.isNullOrEmpty()) {
            Log.e("AudioRecorder", "No file to play - fileName is null or empty")
            return false
        }
        
        // Check if file exists
        val file = java.io.File(fileName!!)
        if (!file.exists()) {
            Log.e("AudioRecorder", "File does not exist: $fileName")
            return false
        }
        
        // If recording is still active (paused), we need to stop it first to finalize the file
        if (audioRecorder != null) {
            try {
                audioRecorder?.stop()
                audioRecorder?.release()
                audioRecorder = null
            } catch (e: Exception) {
                Log.e("AudioRecorder", "Error stopping recorder before playback: ${e.message}")
            }
        }

        // If there's already an existing MediaPlayer, release it before initializing a new one.
        audioPlayer?.let {
            try {
                it.stop() // Stop any ongoing playback.
                it.release() // Release the existing MediaPlayer resources.
            } catch (e: Exception) {
                Log.e("AudioRecorder", "Error releasing existing MediaPlayer: ${e.message}")
            }
        }
        audioPlayer = null

        return try {
            // Now create and initialize the new MediaPlayer instance
            audioPlayer = MediaPlayer().apply {
                setDataSource(fileName) // Set the data source to the recorded file.
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                prepare() // Prepare the MediaPlayer for playback.

                // Request audio focus before starting playback
                if (requestAudioFocus()) {
                    start() // Start playback.

                    setOnCompletionListener {
                        stopPlaying() // Handle completion of playback.
                        releaseAudioFocus() // Release audio focus after playback completes.
                    }
                } else {
                    Log.e("AudioRecorder", "Failed to gain audio focus for playback")
                }
            }
            true
        } catch (e: Exception) {
            Log.e("AudioRecorder", "Error playing audio: ${e.message}")
            false
        }
    }

    public fun pauseRecording():String? {

        // below method will stop
        // the audio recording.
        audioRecorder?.stop()


        // below method will release
        // the media recorder class.
        audioRecorder?.release()
        audioRecorder = null
        releaseAudioFocus()
        return fileName
    }

    /**
     * Pause recording without stopping - only works on API 24+
     * Returns true if paused successfully, false otherwise
     */
    fun pauseRecordingOnly(): Boolean {
        return try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                audioRecorder?.pause()
                true
            } else {
                // Older APIs don't support pause, just return false
                false
            }
        } catch (e: Exception) {
            Log.e("AudioRecorder", "Error pausing recording: ${e.message}")
            false
        }
    }

    /**
     * Resume recording - only works on API 24+ if paused with pauseRecordingOnly
     * Returns true if resumed successfully, false otherwise
     */
    fun resumeRecording(): Boolean {
        return try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N && audioRecorder != null) {
                audioRecorder?.resume()
                true
            } else {
                // Need to restart recording
                false
            }
        } catch (e: Exception) {
            Log.e("AudioRecorder", "Error resuming recording: ${e.message}")
            false
        }
    }

    fun pausePlaying() {
        audioPlayer?.pause()
    }

    /**
     * Resume playing from current position
     * Returns true if resumed successfully
     */
    fun resumePlaying(): Boolean {
        return try {
            if (audioPlayer != null) {
                if (requestAudioFocus()) {
                    audioPlayer?.start()
                    true
                } else {
                    Log.e("AudioRecorder", "Failed to gain audio focus for resume")
                    false
                }
            } else {
                false
            }
        } catch (e: Exception) {
            Log.e("AudioRecorder", "Error resuming playback: ${e.message}")
            false
        }
    }

    /**
     * Seek to a specific position in the audio playback
     * @param positionMs position in milliseconds
     * Returns true if seek was successful
     */
    fun seekTo(positionMs: Int): Boolean {
        return try {
            if (audioPlayer != null) {
                audioPlayer?.seekTo(positionMs)
                // If not playing, start playback after seeking
                if (audioPlayer?.isPlaying == false) {
                    audioPlayer?.start()
                }
                true
            } else {
                // Player not initialized, need to create it first
                if (fileName.isNullOrEmpty()) {
                    Log.e("AudioRecorder", "No file to seek - fileName is null or empty")
                    return false
                }
                
                val file = java.io.File(fileName!!)
                if (!file.exists()) {
                    Log.e("AudioRecorder", "File does not exist: $fileName")
                    return false
                }
                
                // Stop recorder if active
                if (audioRecorder != null) {
                    try {
                        audioRecorder?.stop()
                        audioRecorder?.release()
                        audioRecorder = null
                    } catch (e: Exception) {
                        Log.e("AudioRecorder", "Error stopping recorder: ${e.message}")
                    }
                }
                
                // Create and prepare player
                audioPlayer = MediaPlayer().apply {
                    setDataSource(fileName)
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                    prepare()
                    seekTo(positionMs)
                    
                    if (requestAudioFocus()) {
                        start()
                        setOnCompletionListener {
                            stopPlaying()
                            releaseAudioFocus()
                        }
                    }
                }
                true
            }
        } catch (e: Exception) {
            Log.e("AudioRecorder", "Error seeking audio: ${e.message}")
            false
        }
    }

    /**
     * Get the current playback status
     * Returns a map with isPlaying, currentPosition, and duration
     */
    fun getPlaybackStatus(): HashMap<String, Any> {
        val status = HashMap<String, Any>()
        try {
            if (audioPlayer != null) {
                status["isPlaying"] = audioPlayer?.isPlaying ?: false
                status["currentPosition"] = audioPlayer?.currentPosition ?: 0
                status["duration"] = audioPlayer?.duration ?: 0
            } else {
                status["isPlaying"] = false
                status["currentPosition"] = 0
                status["duration"] = 0
            }
        } catch (e: Exception) {
            Log.e("AudioRecorder", "Error getting playback status: ${e.message}")
            status["isPlaying"] = false
            status["currentPosition"] = 0
            status["duration"] = 0
        }
        return status
    }

    /**
     * Extract waveform data from the recorded audio file
     * Returns an array of amplitude values (0.0 to 1.0) representing the audio waveform
     * @param sampleCount number of amplitude samples to extract
     */
    fun extractWaveform(sampleCount: Int = 50): List<Double> {
        if (fileName.isNullOrEmpty()) {
            Log.e("AudioRecorder", "No file to extract waveform - fileName is null or empty")
            return emptyList()
        }
        
        val file = java.io.File(fileName!!)
        if (!file.exists()) {
            Log.e("AudioRecorder", "File does not exist: $fileName")
            return emptyList()
        }
        
        return try {
            val amplitudes = mutableListOf<Double>()
            
            // Use MediaExtractor to read audio samples
            val extractor = android.media.MediaExtractor()
            extractor.setDataSource(fileName!!)
            
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
                Log.e("AudioRecorder", "No audio track found in file")
                extractor.release()
                return emptyList()
            }
            
            extractor.selectTrack(audioTrackIndex)
            val format = extractor.getTrackFormat(audioTrackIndex)
            
            // Get audio properties
            val sampleRate = format.getInteger(android.media.MediaFormat.KEY_SAMPLE_RATE)
            val channelCount = format.getInteger(android.media.MediaFormat.KEY_CHANNEL_COUNT)
            val duration = if (format.containsKey(android.media.MediaFormat.KEY_DURATION)) {
                format.getLong(android.media.MediaFormat.KEY_DURATION)
            } else {
                0L
            }
            
            if (duration <= 0) {
                extractor.release()
                return emptyList()
            }
            
            // Calculate chunk duration in microseconds
            val chunkDuration = duration / sampleCount
            
            // Create decoder
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
                // Feed input
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
                
                // Get output
                val outputBufferIndex = decoder.dequeueOutputBuffer(bufferInfo, 10000)
                if (outputBufferIndex >= 0) {
                    val outputBuffer = decoder.getOutputBuffer(outputBufferIndex)
                    
                    if (outputBuffer != null && bufferInfo.size > 0) {
                        // Read PCM samples (16-bit)
                        val shortBuffer = outputBuffer.asShortBuffer()
                        val samples = ShortArray(shortBuffer.remaining())
                        shortBuffer.get(samples)
                        
                        // Calculate RMS for samples
                        for (sample in samples) {
                            val normalizedSample = sample.toDouble() / Short.MAX_VALUE
                            chunkSampleSum += normalizedSample * normalizedSample
                            chunkSampleCount++
                        }
                        
                        // Check if we've completed a chunk
                        val currentTime = bufferInfo.presentationTimeUs
                        if (currentTime - lastChunkTime >= chunkDuration && chunkSampleCount > 0) {
                            val rms = kotlin.math.sqrt(chunkSampleSum / chunkSampleCount)
                            
                            // Normalize and amplify for visual appeal
                            var normalizedAmplitude = rms * 3.0
                            
                            // Apply curve for better visual representation
                            normalizedAmplitude = when {
                                normalizedAmplitude < 0.1 -> 0.15 + normalizedAmplitude * 2.0
                                normalizedAmplitude < 0.4 -> 0.35 + (normalizedAmplitude - 0.1) * 1.17
                                else -> 0.7 + (normalizedAmplitude - 0.4) * 0.5
                            }
                            
                            amplitudes.add(normalizedAmplitude.coerceIn(0.15, 1.0))
                            
                            // Reset for next chunk
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
                } else if (outputBufferIndex == android.media.MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    // Format changed, continue
                }
            }
            
            // Add remaining chunk if any
            if (chunkSampleCount > 0 && currentChunk < sampleCount) {
                val rms = kotlin.math.sqrt(chunkSampleSum / chunkSampleCount)
                var normalizedAmplitude = rms * 3.0
                normalizedAmplitude = when {
                    normalizedAmplitude < 0.1 -> 0.15 + normalizedAmplitude * 2.0
                    normalizedAmplitude < 0.4 -> 0.35 + (normalizedAmplitude - 0.1) * 1.17
                    else -> 0.7 + (normalizedAmplitude - 0.4) * 0.5
                }
                amplitudes.add(normalizedAmplitude.coerceIn(0.15, 1.0))
            }
            
            decoder.stop()
            decoder.release()
            extractor.release()
            
            amplitudes
        } catch (e: Exception) {
            Log.e("AudioRecorder", "Error extracting waveform: ${e.message}")
            emptyList()
        }
    }

    ///[stopPlaying] stops the audio player
    private fun stopPlaying(){
        audioPlayer?.stop()
        audioPlayer?.release()
        audioPlayer = null
        releaseAudioFocus()
    }

    /// release all media resources
    fun releaseMediaResources(){
        if (audioRecorder!=null ){
            pauseRecording()
        }
        if (audioPlayer!=null || audioPlayer?.isPlaying == true){
            stopPlaying()
        }
    }
}
