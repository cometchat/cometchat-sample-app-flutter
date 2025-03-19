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

    private var mMediaPlayer = MediaPlayer()

    private var audioManager: AudioManager? = null
    private var hasAudioFocus = false


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
                // Regained focus, resume playback
                mMediaPlayer?.start()
            }
            AudioManager.AUDIOFOCUS_LOSS -> {
                // Lost focus permanently, stop playback
                mMediaPlayer?.pause()
                releaseAudioFocus()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                // Lost focus temporarily, pause playback
                mMediaPlayer?.pause()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                // Lost focus temporarily, lower the volume
                mMediaPlayer?.setVolume(0.3f, 0.3f)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun playCustomSound(call: MethodCall, result: MethodChannel.Result, context: Context) {
        val assetAudioPath: String = call.argument("assetAudioPath") ?: ""

        // Release previous MediaPlayer instance if it's still active
        mMediaPlayer?.let {
            it.stop()
            it.release()
        }

        mMediaPlayer = MediaPlayer()

        try {
            // Open the asset file and set the data source
            val afd = context.assets.openFd("flutter_assets/$assetAudioPath")
            mMediaPlayer?.setDataSource(afd.fileDescriptor, afd.startOffset, afd.declaredLength)
            afd.close()

            // Set the audio attributes for playback
            mMediaPlayer?.setAudioAttributes(
                AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )

            // Request audio focus before starting playback
            if (requestAudioFocus(context)) {
                mMediaPlayer?.setOnPreparedListener {
                    mMediaPlayer?.start()
                    mMediaPlayer?.setOnCompletionListener { mediaPlayer ->
                        mediaPlayer.stop()
                        mediaPlayer.release()
                        releaseAudioFocus()

                        // Notify the UI to refresh or handle completion (audio bubble refresh)
                        result.success("Sound Played")
                    }
                }

                mMediaPlayer?.prepare() // Start preparing the media player
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
                if (it.isPlaying) {
                    it.stop()
                    releaseAudioFocus() // Release the audio focus after stopping playback
                }
            }
        } catch (e: Exception) {
            Log.e("AudioPlayer", "Error stopping the player: ${e.message}")
        }
        result.success("Player Stopped")
    }
}