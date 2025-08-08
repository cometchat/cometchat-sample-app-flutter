package com.cometchat.sampleapp.flutter.android

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.cometchat.sampleapp"
    private var initialCallIntent: MutableMap<String, String>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i("[MainActivity]", "[onCreate] Called with intent: $intent")
        processIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        Log.i("[MainActivity]", "[onNewIntent] New intent received with action: ${intent.action}")
        processIntent(intent)
    }

    private fun processIntent(intent: Intent?) {
        if (intent != null) {
            // Standard extraction at top level FIRST
            var callId = intent.getStringExtra("call_id")
            var callType = intent.getStringExtra("call_type")
            var callAction = intent.getStringExtra("call_action")

            // Fallback: Extract from nested bundle if any are null
            if ((callId.isNullOrEmpty() || callType.isNullOrEmpty() || callAction.isNullOrEmpty())
                && intent.hasExtra("EXTRA_CALLKIT_CALL_DATA")) {

                val callkitBundle = intent.getBundleExtra("EXTRA_CALLKIT_CALL_DATA")
                val extractedId = callkitBundle?.getString("EXTRA_CALLKIT_ID")
                val typeInt = callkitBundle?.getInt("EXTRA_CALLKIT_TYPE", 0) ?: 0
                val extractedType = if (typeInt == 0) "audio" else "video"
                val extractedAction = when (intent.action) {
                    "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT" -> "accept"
                    "com.hiennv.flutter_callkit_incoming.ACTION_CALL_DECLINE" -> "decline"
                    else -> "unknown"
                }

                if (!extractedId.isNullOrEmpty() && !extractedType.isNullOrEmpty() && extractedAction != "unknown") {
                    initialCallIntent = mutableMapOf(
                        "call_id" to extractedId,
                        "call_type" to extractedType,
                        "call_action" to extractedAction
                    )
                    Log.i("[MainActivity]", "[processIntent] ✅ Extracted from bundle -> ID: $extractedId, Type: $extractedType, Action: $extractedAction")
                    return
                }
            }

            // If not handled above, warn
            Log.w("[MainActivity]", "[processIntent] ❌ No valid call intent found (even after bundle extract).")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.i("[MainActivity]", "[configureFlutterEngine] Setting up MethodChannel")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "get_initial_call_intent" -> {
                    Log.i(
                        "[MainActivity]",
                        "[MethodChannel] get_initial_call_intent called. Returning: $initialCallIntent"
                    )
                    result.success(initialCallIntent)
                    initialCallIntent = null // Prevent duplicate read
                }
                "saveAppSettings" -> {
                    val appID = call.argument<String>("appID")
                    val region = call.argument<String>("region")

                    if (appID != null && region != null) {
                        val sharedPref = getSharedPreferences("cometchat_prefs", MODE_PRIVATE)
                        with(sharedPref.edit()) {
                            putString("appID", appID)
                            putString("region", region)
                            apply()
                        }
                        result.success("Saved successfully")
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing appID or region", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
