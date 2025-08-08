package com.hiennv.flutter_callkit_incoming

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.*
import android.text.TextUtils

class CallkitSoundPlayerManager(private val context: Context) {

    private var vibrator: Vibrator? = null
    private var audioManager: AudioManager? = null

    private var mediaPlayer: MediaPlayer? = null

    fun play(data: Bundle) {
        this.prepare()
        this.playSound(data)
        this.playVibrator()
    }

    fun stop() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        vibrator?.cancel()

        mediaPlayer = null
        vibrator = null
    }

    fun destroy() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        vibrator?.cancel()

        mediaPlayer = null
        vibrator = null
    }

    private fun prepare() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        vibrator?.cancel()
    }

    private fun playVibrator() {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager =
                context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        when (audioManager?.ringerMode) {
            AudioManager.RINGER_MODE_SILENT -> {
            }

            else -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator?.vibrate(
                        VibrationEffect.createWaveform(
                            longArrayOf(0L, 1000L, 1000L),
                            0
                        )
                    )
                } else {
                    vibrator?.vibrate(longArrayOf(0L, 1000L, 1000L), 0)
                }
            }
        }
    }

    private fun playSound(data: Bundle?) {
        val sound = data?.getString(
            CallkitConstants.EXTRA_CALLKIT_RINGTONE_PATH,
            ""
        )
        val uri = sound?.let { getRingtoneUri(it) }
        if (uri == null) {
            // Failed to get ringtone url, can't play sound
            return
        }
        try {
            mediaPlayer(uri)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun mediaPlayer(uri: Uri) {
        mediaPlayer = MediaPlayer()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val attribution = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                .setLegacyStreamType(AudioManager.STREAM_RING)
                .build()
            mediaPlayer?.setAudioAttributes(attribution)
        } else {
            mediaPlayer?.setAudioStreamType(AudioManager.STREAM_RING)
        }
        setDataSource(uri)
        mediaPlayer?.prepare()
        mediaPlayer?.isLooping = true
        mediaPlayer?.start()
    }

    private fun setDataSource(uri: Uri) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val assetFileDescriptor =
                context.contentResolver.openAssetFileDescriptor(uri, "r")
            if (assetFileDescriptor != null) {
                mediaPlayer?.setDataSource(assetFileDescriptor)
            }
            return
        }
        mediaPlayer?.setDataSource(context, uri)
    }

    private fun getRingtoneUri(fileName: String): Uri? {
        if (TextUtils.isEmpty(fileName)) {
            return getDefaultRingtoneUri()
        }
        
        // If system_ringtone_default is explicitly requested, bypass resource check
        if (fileName.equals("system_ringtone_default", true)) {
            return getDefaultRingtoneUri(useSystemDefault = true)
        }

        try {
            val resId = context.resources.getIdentifier(fileName, "raw", context.packageName)
            if (resId != 0) {
                return Uri.parse("android.resource://${context.packageName}/$resId")
            }

            // For any other unresolved filename, return the default ringtone
            return getDefaultRingtoneUri()
        } catch (e: Exception) {
            // If anything fails, try to return the system default ringtone
            return getDefaultRingtoneUri()
        }
    }

    private fun getDefaultRingtoneUri(useSystemDefault: Boolean = false): Uri? {
        try {
            if (!useSystemDefault) {
                // First try to use ringtone_default resource if it exists
                val resId = context.resources.getIdentifier("ringtone_default", "raw", context.packageName)
                if (resId != 0) {
                    return Uri.parse("android.resource://${context.packageName}/$resId")
                }
            }

            // Fall back to system default ringtone
            return RingtoneManager.getActualDefaultRingtoneUri(
                context,
                RingtoneManager.TYPE_RINGTONE
            )
        } catch (e: Exception) {
            // getActualDefaultRingtoneUri can throw an exception on some devices
            // for custom ringtones
            return null
        }
    }
}