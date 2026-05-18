# CometChat Calls SDK — classes referenced by cometchat_sdk but provided
# at runtime by cometchat_calls_sdk. Suppress R8 missing class warnings.
-dontwarn com.cometchat.calls.CometChatRTCView$CometChatRTCViewBuilder
-dontwarn com.cometchat.calls.CometChatRTCView
-dontwarn com.cometchat.calls.CometChatRTCViewListener
-dontwarn com.cometchat.calls.model.AnalyticsSettings
-dontwarn com.cometchat.calls.model.RTCCallback
-dontwarn com.cometchat.calls.model.RTCReceiver

# Flutter Play Store split install (deferred components — not used in this app)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Keep CometChat classes from being stripped
-keep class com.cometchat.** { *; }
-keep interface com.cometchat.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
