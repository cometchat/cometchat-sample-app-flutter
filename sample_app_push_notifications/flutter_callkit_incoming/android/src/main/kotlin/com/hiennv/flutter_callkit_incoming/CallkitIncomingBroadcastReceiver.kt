package com.hiennv.flutter_callkit_incoming

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log

class CallkitIncomingBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "CallkitIncomingReceiver"
        var silenceEvents = false

        fun getIntent(context: Context, action: String, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                this.action = "${context.packageName}.${action}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentIncoming(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_INCOMING}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentStart(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_START}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentAccept(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_ACCEPT}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentDecline(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_DECLINE}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentEnded(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_ENDED}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentTimeout(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_TIMEOUT}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentCallback(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_CALLBACK}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentHeldByCell(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_HELD}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentUnHeldByCell(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_UNHELD}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }

        fun getIntentConnected(context: Context, data: Bundle?) =
            Intent(context, CallkitIncomingBroadcastReceiver::class.java).apply {
                action = "${context.packageName}.${CallkitConstants.ACTION_CALL_CONNECTED}"
                putExtra(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA, data)
            }
    }

    private val callkitNotificationManager: CallkitNotificationManager? = FlutterCallkitIncomingPlugin.getInstance()?.getCallkitNotificationManager()


    @SuppressLint("MissingPermission")
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val data = intent.extras?.getBundle(CallkitConstants.EXTRA_CALLKIT_INCOMING_DATA) ?: return
        when (action) {
            "${context.packageName}.${CallkitConstants.ACTION_CALL_INCOMING}" -> {
                try {
                    callkitNotificationManager?.showIncomingNotification(data)
                    sendEventFlutter(CallkitConstants.ACTION_CALL_INCOMING, data)
                    addCall(context, Data.fromBundle(data))
                } catch (error: Exception) {
                    Log.e(TAG, null, error)
                }
            }

            "${context.packageName}.${CallkitConstants.ACTION_CALL_START}" -> {
                try {
                    // start service and show ongoing call when call is accepted
                    CallkitNotificationService.startServiceWithAction(
                        context,
                        CallkitConstants.ACTION_CALL_START,
                        data
                    )
                    sendEventFlutter(CallkitConstants.ACTION_CALL_START, data)
                    addCall(context, Data.fromBundle(data), true)
                } catch (error: Exception) {
                    Log.e(TAG, null, error)
                }
            }

            "${context.packageName}.${CallkitConstants.ACTION_CALL_ACCEPT}" -> {
                try {
                    // start service and show ongoing call when call is accepted
                    CallkitNotificationService.startServiceWithAction(
                        context,
                        CallkitConstants.ACTION_CALL_ACCEPT,
                        data
                    )
                    sendEventFlutter(CallkitConstants.ACTION_CALL_ACCEPT, data)
                    addCall(context, Data.fromBundle(data), true)
                } catch (error: Exception) {
                    Log.e(TAG, null, error)
                }
            }

            "${context.packageName}.${CallkitConstants.ACTION_CALL_DECLINE}" -> {
                try {
                    // clear notification
                    callkitNotificationManager?.clearIncomingNotification(data, false)
                    sendEventFlutter(CallkitConstants.ACTION_CALL_DECLINE, data)
                    removeCall(context, Data.fromBundle(data))
                } catch (error: Exception) {
                    Log.e(TAG, null, error)
                }
            }

            "${context.packageName}.${CallkitConstants.ACTION_CALL_ENDED}" -> {
                try {
                    // clear notification and stop service
                    callkitNotificationManager?.clearIncomingNotification(data, false)
                    CallkitNotificationService.stopService(context)
                    sendEventFlutter(CallkitConstants.ACTION_CALL_ENDED, data)
                    removeCall(context, Data.fromBundle(data))
                } catch (error: Exception) {
                    Log.e(TAG, null, error)
                }
            }

            "${context.packageName}.${CallkitConstants.ACTION_CALL_TIMEOUT}" -> {
                try {
                    // clear notification and show miss notification
                    callkitNotificationManager?.clearIncomingNotification(data, false)
                    callkitNotificationManager?.showMissCallNotification(data)
                    sendEventFlutter(CallkitConstants.ACTION_CALL_TIMEOUT, data)
                    removeCall(context, Data.fromBundle(data))
                } catch (error: Exception) {
                    Log.e(TAG, null, error)
                }
            }

            "${context.packageName}.${CallkitConstants.ACTION_CALL_CONNECTED}" -> {
                try {
                    // update notification on going connected
                    callkitNotificationManager?.showOngoingCallNotification(data, true)
                    sendEventFlutter(CallkitConstants.ACTION_CALL_CONNECTED, data)
                } catch (error: Exception) {
                    Log.e(TAG, null, error)
                }
            }

            "${context.packageName}.${CallkitConstants.ACTION_CALL_CALLBACK}" -> {
                try {
                    callkitNotificationManager?.clearMissCallNotification(data)
                    sendEventFlutter(CallkitConstants.ACTION_CALL_CALLBACK, data)
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                        val closeNotificationPanel = Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
                        context.sendBroadcast(closeNotificationPanel)
                    }
                } catch (error: Exception) {
                    Log.e(TAG, null, error)
                }
            }
        }
    }

    private fun sendEventFlutter(event: String, data: Bundle) {
        if (silenceEvents) return

        val android = mapOf(
            "isCustomNotification" to data.getBoolean(
                CallkitConstants.EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION,
                false
            ),
            "isCustomSmallExNotification" to data.getBoolean(
                CallkitConstants.EXTRA_CALLKIT_IS_CUSTOM_SMALL_EX_NOTIFICATION,
                false
            ),
            "ringtonePath" to data.getString(CallkitConstants.EXTRA_CALLKIT_RINGTONE_PATH, ""),
            "backgroundColor" to data.getString(
                CallkitConstants.EXTRA_CALLKIT_BACKGROUND_COLOR,
                ""
            ),
            "backgroundUrl" to data.getString(CallkitConstants.EXTRA_CALLKIT_BACKGROUND_URL, ""),
            "actionColor" to data.getString(CallkitConstants.EXTRA_CALLKIT_ACTION_COLOR, ""),
            "textColor" to data.getString(CallkitConstants.EXTRA_CALLKIT_TEXT_COLOR, ""),
            "incomingCallNotificationChannelName" to data.getString(
                CallkitConstants.EXTRA_CALLKIT_INCOMING_CALL_NOTIFICATION_CHANNEL_NAME,
                ""
            ),
            "missedCallNotificationChannelName" to data.getString(
                CallkitConstants.EXTRA_CALLKIT_MISSED_CALL_NOTIFICATION_CHANNEL_NAME,
                ""
            ),
            "isImportant" to data.getBoolean(CallkitConstants.EXTRA_CALLKIT_IS_IMPORTANT, true),
            "isBot" to data.getBoolean(CallkitConstants.EXTRA_CALLKIT_IS_BOT, false),
        )
        val missedCallNotification = mapOf(
            "id" to data.getInt(CallkitConstants.EXTRA_CALLKIT_MISSED_CALL_ID),
            "showNotification" to data.getBoolean(CallkitConstants.EXTRA_CALLKIT_MISSED_CALL_SHOW),
            "count" to data.getInt(CallkitConstants.EXTRA_CALLKIT_MISSED_CALL_COUNT),
            "subtitle" to data.getString(CallkitConstants.EXTRA_CALLKIT_MISSED_CALL_SUBTITLE),
            "callbackText" to data.getString(CallkitConstants.EXTRA_CALLKIT_MISSED_CALL_CALLBACK_TEXT),
            "isShowCallback" to data.getBoolean(CallkitConstants.EXTRA_CALLKIT_MISSED_CALL_CALLBACK_SHOW),
        )
        val callingNotification = mapOf(
            "id" to data.getString(CallkitConstants.EXTRA_CALLKIT_CALLING_ID),
            "showNotification" to data.getBoolean(CallkitConstants.EXTRA_CALLKIT_CALLING_SHOW),
            "subtitle" to data.getString(CallkitConstants.EXTRA_CALLKIT_CALLING_SUBTITLE),
            "callbackText" to data.getString(CallkitConstants.EXTRA_CALLKIT_CALLING_HANG_UP_TEXT),
            "isShowCallback" to data.getBoolean(CallkitConstants.EXTRA_CALLKIT_CALLING_HANG_UP_SHOW),
        )
        val forwardData = mapOf(
            "id" to data.getString(CallkitConstants.EXTRA_CALLKIT_ID, ""),
            "nameCaller" to data.getString(CallkitConstants.EXTRA_CALLKIT_NAME_CALLER, ""),
            "avatar" to data.getString(CallkitConstants.EXTRA_CALLKIT_AVATAR, ""),
            "number" to data.getString(CallkitConstants.EXTRA_CALLKIT_HANDLE, ""),
            "type" to data.getInt(CallkitConstants.EXTRA_CALLKIT_TYPE, 0),
            "duration" to data.getLong(CallkitConstants.EXTRA_CALLKIT_DURATION, 0L),
            "textAccept" to data.getString(CallkitConstants.EXTRA_CALLKIT_TEXT_ACCEPT, ""),
            "textDecline" to data.getString(CallkitConstants.EXTRA_CALLKIT_TEXT_DECLINE, ""),
            "extra" to data.getSerializable(CallkitConstants.EXTRA_CALLKIT_EXTRA),
            "missedCallNotification" to missedCallNotification,
            "callingNotification" to callingNotification,
            "android" to android
        )
        FlutterCallkitIncomingPlugin.sendEvent(event, forwardData)
    }
}