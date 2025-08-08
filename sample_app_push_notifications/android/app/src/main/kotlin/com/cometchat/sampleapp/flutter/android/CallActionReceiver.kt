package com.cometchat.sampleapp.flutter.android

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.cometchat.chat.constants.CometChatConstants
import com.cometchat.chat.core.Call
import com.cometchat.chat.core.CometChat
import com.cometchat.chat.exceptions.CometChatException
import com.cometchat.chat.core.AppSettings.AppSettingsBuilder
import android.os.Build
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat




class CallActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.i("[FCM-MKAP]", "Intent: $intent")
        Log.i("[CallActionReceiver]", "🚨 onReceive triggered! Action: ${intent.action}")
        val extras = intent.extras
        if (extras != null) {
            for (key in extras.keySet()) {
                Log.i("[CallActionReceiver]", "Intent extra: $key = ${extras.get(key)}")
            }
        } else {
            Log.i("[CallActionReceiver]", "No extras in intent.")
        }

        val receivedAction = intent.action
        val callId = intent.getStringExtra("id")
        Log.i("[CallActionReceiver]", "receivedAction=$receivedAction, callId=$callId")
        if (callId == null) {
            return // or handle gracefully
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            Log.i("[CallActionReceiver]", "❗️ Decline action matched. Handling decline!")

            val permissionCheck = ContextCompat.checkSelfPermission(
                context,
                android.Manifest.permission.FOREGROUND_SERVICE_PHONE_CALL
            )
            if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
                Log.i("[CallActionReceiver]", "Decline logic completed, not launching Activity for UI.")
                return
            }
        }
        val callType = when (intent.getIntExtra("type", 0)) {
            0 -> "audio"
            1 -> "video"
            else -> "audio"
        }


        if (receivedAction?.endsWith("ACTION_CALL_DECLINE") == true){

            val prefs = context.getSharedPreferences("cometchat_prefs", Context.MODE_PRIVATE)
            val appID = prefs.getString("appID", null)
            val region = prefs.getString("region", null)
            val tag = "CallActionReceiver"

            if (appID != null && region != null) {
                val appSetting = AppSettingsBuilder()
                    .setRegion(region)
                    .subscribePresenceForAllUsers()
                    .autoEstablishSocketConnection(true)
                    .build()

                CometChat.init(context, appID, appSetting, object : CometChat.CallbackListener<String>() {
                    override fun onSuccess(p0: String?) {
                        if (callId != null) {
                            CometChat.rejectCall(callId, CometChatConstants.CALL_STATUS_BUSY,
                                object : CometChat.CallbackListener<Call>() {
                                    override fun onSuccess(call: Call?) {
                                        Log.i("[CallActionReceiver]", "Call rejected as busy successfully.")
                                    }

                                    override fun onError(e: CometChatException?) {
                                        Log.e("[CallActionReceiver]", "❌ Failed to reject call: ${e?.message}")
                                    }
                                })
                        }
                    }

                    override fun onError(e: CometChatException?) {
                        Log.e("CallActionReceiver", "CometChat Init Error: ${e?.message}")
                    }
                })
            } else {
                Log.e("CallActionReceiver", "App ID or Region not found in SharedPreferences")
            }
            return // Don't need to launch the app
        }

        val nameCaller = intent.getStringExtra("nameCaller") // Optional
        val callAction = if (intent.action?.contains("ACCEPT") == true) "accept" else "decline"
        Log.i(
            "[CallActionReceiver]",
            "Action received: $receivedAction, CallId=$callId, Type=$callType, Action=$callAction"
        )

        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            putExtra("call_id", callId)
            putExtra("call_type", callType)
            putExtra("call_action", callAction)
        }

        Log.i("[CallActionReceiver]", "Starting MainActivity with intent extras.")
        context.startActivity(launchIntent)
    }
}
