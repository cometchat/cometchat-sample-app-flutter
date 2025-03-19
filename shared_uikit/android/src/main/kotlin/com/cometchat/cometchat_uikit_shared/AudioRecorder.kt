package com.cometchat.cometchat_uikit_shared

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


    fun playAudio() {
        // If there's already an existing MediaPlayer, release it before initializing a new one.
        audioPlayer?.let {
            try {
                it.stop() // Stop any ongoing playback.
                it.release() // Release the existing MediaPlayer resources.
            } catch (e: Exception) {
                Log.e("AudioRecorder", "Error releasing existing MediaPlayer: ${e.message}")
            }
        }

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

    fun pausePlaying() {
        audioPlayer?.pause()
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
