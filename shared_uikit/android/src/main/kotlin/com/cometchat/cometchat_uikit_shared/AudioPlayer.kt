package com.cometchat.cometchat_uikit_shared

import android.content.Context
import android.content.res.AssetManager
import android.media.AudioAttributes
import android.media.MediaMetadataRetriever
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.Vibrator
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.media.AudioManager
import java.io.IOException
import android.util.Log


class AudioPlayer : AudioManager.OnAudioFocusChangeListener{


    private var audioManager: AudioManager? = null
    private var hasAudioFocus = false
    private var isPrepared = false



    // ✅ Companion object to ensure only ONE instance of MediaPlayer exists
    companion object {
        private var mMediaPlayer: MediaPlayer? = null
    }

    // Request audio focus for playback
    private fun requestAudioFocus(context: Context): Boolean {
        audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val result = audioManager?.requestAudioFocus(
            this,
            AudioManager.STREAM_MUSIC,
            AudioManager.AUDIOFOCUS_GAIN
        )
        hasAudioFocus = result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        return hasAudioFocus
    }

    // Release audio focus
    private fun releaseAudioFocus() {
        if (hasAudioFocus && audioManager != null) {
            audioManager?.abandonAudioFocus(this)
            hasAudioFocus = false
        }
    }

    override fun onAudioFocusChange(focusChange: Int) {
        when (focusChange) {
            AudioManager.AUDIOFOCUS_GAIN -> {
                if (mMediaPlayer != null && isPrepared && !mMediaPlayer!!.isPlaying) {
                    try {
                        mMediaPlayer?.start()
                    } catch (e: IllegalStateException) {
                        Log.e("AudioPlayer", "Error during resume: ${e.message}")
                    }
                }
            }
            AudioManager.AUDIOFOCUS_LOSS -> {
                if (mMediaPlayer != null && isPrepared && mMediaPlayer!!.isPlaying) {
                    try {
                        mMediaPlayer?.pause()
                    } catch (e: IllegalStateException) {
                        Log.e("AudioPlayer", "Error during pause: ${e.message}")
                    }
                }
                releaseAudioFocus()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                if (mMediaPlayer != null && isPrepared && mMediaPlayer!!.isPlaying) {
                    try {
                        mMediaPlayer?.pause()
                    } catch (e: IllegalStateException) {
                        Log.e("AudioPlayer", "Error during transient pause: ${e.message}")
                    }
                }
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                if (mMediaPlayer != null && isPrepared) {
                    mMediaPlayer?.setVolume(0.3f, 0.3f)
                }
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    @Synchronized
    fun playCustomSound(call: MethodCall, result: MethodChannel.Result, context: Context ) {
        val assetAudioPath: String = call.argument("assetAudioPath") ?: ""
        val isLooping: Boolean = call.argument("isLooping") ?: false  // Get isLooping flag

        Log.d("AudioPlayer", "Playing audio from asset: $assetAudioPath")
        Log.d("AudioPlayer", "Looping: $isLooping")
        // Release previous MediaPlayer instance if it's still active
        mMediaPlayer?.let {
            if (it.isPlaying) {
                it.stop()
            }
            it.release()
            mMediaPlayer = null
            isPrepared = false
        }

        mMediaPlayer = MediaPlayer()

        try {
            // Open the asset file and set the data source
            val afd = context.assets.openFd("flutter_assets/$assetAudioPath")
            try {
                mMediaPlayer?.setDataSource(afd.fileDescriptor, afd.startOffset, afd.declaredLength)
            } catch (e: IOException) {
                e.printStackTrace()
            } finally {
                afd.close()
            }

            // Set the audio attributes for playback
            mMediaPlayer?.setAudioAttributes(
                AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )

            // Request audio focus before starting playback
            if (requestAudioFocus(context)) {
                mMediaPlayer?.setOnPreparedListener {
                    Log.d("AudioPlayer", "MediaPlayer is prepared")
                    isPrepared = true
                    mMediaPlayer?.isLooping = isLooping

                    // Request focus AFTER media is prepared
                    if (requestAudioFocus(context)) {
                        try {
                            mMediaPlayer?.start()
                        } catch (e: IllegalStateException) {
                            Log.e("AudioPlayer", "Error during start after preparation: ${e.message}")
                        }
                    } else {
                        Log.e("AudioPlayer", "Failed to get audio focus after preparation")
                        result.error("AUDIO_FOCUS_FAILED", "Could not gain audio focus", null)
                    }
                }


                mMediaPlayer?.setOnCompletionListener { mediaPlayer ->
                    mediaPlayer.release()
                    releaseAudioFocus()
                    mMediaPlayer = null
                    result.success("Sound Played")
                }

                mMediaPlayer?.prepareAsync() // Start preparing the media player
            } else {
                result.error("AUDIO_FOCUS_FAILED", "Could not gain audio focus", null)
            }
        } catch (e: IOException) {
            Log.e("AudioPlayer", "Error setting up MediaPlayer: ${e.message}")
            result.error("MEDIA_PLAYER_ERROR", "Failed to prepare the audio", null)
        }
    }

    // Method to stop the audio player and release resources
    fun stopPlayer(result: MethodChannel.Result) {
        try {
            mMediaPlayer?.let {
                try {
                    if (it.isPlaying) {
                        it.isLooping = false
                        it.stop()
                    }
                } catch (e: IllegalStateException) {
                    Log.e("AudioPlayer", "IllegalStateException during stop: ${e.message}")
                }
                try {
                    it.release()
                } catch (e: Exception) {
                    Log.e("AudioPlayer", "Error during release: ${e.message}")
                }
                mMediaPlayer = null
                isPrepared = false
                releaseAudioFocus()
            }
        } catch (e: Exception) {
            Log.e("AudioPlayer", "Error stopping the player: ${e.message}")
        }
        result.success("Player Stopped")
    }
}