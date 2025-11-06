package com.cometchat.sampleapp.flutter.android

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.cometchat.sampleapp"
    private var initialCallIntent: MutableMap<String, String>? = null
    private var wasDeviceLockedBeforeCall = false
    private var keyguardLock: android.app.KeyguardManager.KeyguardLock? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i("[MainActivity]", "[onCreate] Called with intent: $intent")

        // Check if device was locked when call came in
        checkIfDeviceWasLocked()

        // Check if this is a call-related intent and setup lock screen temporarily
        if (intent?.action == "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT" ||
            intent?.getStringExtra("call_action") == "accept") {
            setupTemporaryLockScreenBypass()
        }

        processIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        Log.i("[MainActivity]", "[onNewIntent] New intent received with action: ${intent.action}")

        // Check if this is a call-related intent and setup lock screen temporarily
        if (intent.action == "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT" ||
            intent.getStringExtra("call_action") == "accept") {
            checkIfDeviceWasLocked()
            setupTemporaryLockScreenBypass()
        }

        processIntent(intent)
    }

    private fun checkIfDeviceWasLocked() {
        try {
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as android.app.KeyguardManager
            wasDeviceLockedBeforeCall = keyguardManager.isKeyguardLocked
            Log.i("[MainActivity]", "[checkIfDeviceWasLocked] Device was locked: $wasDeviceLockedBeforeCall")
        } catch (e: Exception) {
            Log.e("[MainActivity]", "Failed to check keyguard state: ${e.message}")
            wasDeviceLockedBeforeCall = true // Assume locked for safety
        }
    }

    private fun setupTemporaryLockScreenBypass() {
        if (!wasDeviceLockedBeforeCall) {
            Log.i("[MainActivity]", "[setupTemporaryLockScreenBypass] Device wasn't locked, no need to bypass")
            return
        }

        Log.i("[MainActivity]", "[setupTemporaryLockScreenBypass] Setting up temporary lock screen bypass for call")

        // Set window flags for call display over lock screen
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }

        // Temporarily disable keyguard only for older Android versions
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            try {
                val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as android.app.KeyguardManager
                keyguardLock = keyguardManager.newKeyguardLock("CometChat Call")
                keyguardLock?.disableKeyguard()
            } catch (e: Exception) {
                Log.e("[MainActivity]", "Failed to disable keyguard temporarily: ${e.message}")
            }
        }
    }

    private fun restoreLockScreen() {
        if (!wasDeviceLockedBeforeCall) {
            Log.i("[MainActivity]", "[restoreLockScreen] Device wasn't locked originally, nothing to restore")
            return
        }

        Log.i("[MainActivity]", "[restoreLockScreen] Restoring lock screen after call")

        try {
            // Clear the lock screen bypass flags
            window.clearFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(false)
                setTurnScreenOn(false)
            }

            // Re-enable keyguard for older versions
            keyguardLock?.reenableKeyguard()
            keyguardLock = null

            // Lock the device by turning off screen and showing keyguard
            val powerManager = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // For Android 9 and above, we need to finish the activity to return to lock screen
                finishAndRemoveTask()
            } else {
                // For older versions, just finish the activity
                finish()
            }

        } catch (e: Exception) {
            Log.e("[MainActivity]", "Failed to restore lock screen: ${e.message}")
        }

        wasDeviceLockedBeforeCall = false
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

            // If we have valid call data from standard extraction
            if (!callId.isNullOrEmpty() && !callType.isNullOrEmpty() && !callAction.isNullOrEmpty()) {
                initialCallIntent = mutableMapOf(
                    "call_id" to callId,
                    "call_type" to callType,
                    "call_action" to callAction
                )
                Log.i("[MainActivity]", "[processIntent] ✅ Standard extraction -> ID: $callId, Type: $callType, Action: $callAction")
                return
            }

            // If not handled above, warn
            Log.w("[MainActivity]", "[processIntent] ❌ No valid call intent found (even after bundle extract).")
        }
    }

    private fun bringAppToForegroundForCall() {
        Log.i("[MainActivity]", "[bringAppToForegroundForCall] Launching dedicated call activity")

        val intent = Intent(this, CallActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        startActivity(intent)
    }

    private fun moveTaskToFront() {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        startActivity(intent)
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
                "setupLockScreenForCall" -> {
                    setupTemporaryLockScreenBypass()
                    result.success("Lock screen flags set for call")
                }
                "restoreLockScreenAfterCall" -> {
                    restoreLockScreen()
                    result.success("Lock screen restored after call")
                }
                "bringAppToForegroundForCall" -> {
                    bringAppToForegroundForCall()
                    result.success("App brought to foreground for call")
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
