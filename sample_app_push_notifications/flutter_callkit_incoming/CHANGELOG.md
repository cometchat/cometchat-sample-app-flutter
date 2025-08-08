## 2.5.5
* Fix bug duplicate permission Android

## 2.5.4
* Fix bug custom permission Android
* Remove calling notification when task remove
* Fixed calling notification show
* Fixed some bugs.

## 2.5.3
* Update Android 14+ compatibility(force CallStyle/`FOREGROUND_SERVICE_PHONE_CALL` for https://developer.android.com/about/versions/14/behavior-changes-all#non-dismissable-notifications)
* Change structure Notification/Sound on Android
* Update get avatar from assets(Android), thanks @Ricky-yu https://github.com/hiennguyen92/flutter_callkit_incoming/pull/674
* Add `isAccepted` properties for iOS and only show facetime button if support video, thank @td2thinh https://github.com/hiennguyen92/flutter_callkit_incoming/pull/673
* Fixed some bugs.

## 2.5.3-alpha
* Update Android 14+ compatibility(force CallStyle/`FOREGROUND_SERVICE_PHONE_CALL` for https://developer.android.com/about/versions/14/behavior-changes-all#non-dismissable-notifications)
* Fixed some bugs.

## 2.5.2
* Add notification calling for Android `callingNotification`, thank @ebsangam https://github.com/hiennguyen92/flutter_callkit_incoming/pull/662
* Add `logoUrl` properties (inside android prop) 
* Fixed issue DMTF IOS, thank @minn-ee https://github.com/hiennguyen92/flutter_callkit_incoming/issues/577
* Fixed issue duplicate missing notification Android
* Fixed some bugs.

## 2.5.1
* Fix issue security Android, thanks @datpt11 https://github.com/hiennguyen92/flutter_callkit_incoming/issues/651

## 2.5.0
* update jvmToolchain(17) for Android

## 2.0.4+2
* add func `requestFullIntentPermission` (Android 14+) thank @Spyspyspy https://github.com/hiennguyen92/flutter_callkit_incoming/pull/584
* set Notification call style (Android) thank @AAkira https://github.com/hiennguyen92/flutter_callkit_incoming/pull/553
* Many other issues
    1. add prop `accepted` in activeCalls (iOS) thank @vasilich6107

## 2.0.4+1
* Removed `Telecom Framework` (Android)

## 2.0.4
* Removed `Telecom Framework` (Android)
* Fixed hide notification for action `CallBack` (Android)

## 2.0.3
* Fixed linked func `hideCallkitIncoming`

## 2.0.2+2
* Fixed linked func `hideCallkitIncoming`

## 2.0.2+1
* Fixed linked func `hideCallkitIncoming`

## 2.0.2
* Add func `hideCallkitIncoming` clear the incoming notification/ring (after accept/decline/timeout)
* Add props `isShowFullLockedScreen` on Android
* Fixed example/Fixed update android 14

## 2.0.1+2
* Add Action for onDecline
* Add Action for onEnd
* add android props `isShowCallID`

## 2.0.1+1
* Add Callback AVAudioSession for WebRTC setup
* Fix issue no audio for using WebRTC

## 2.0.1-dev.2
* Add Action for onAccept

## 2.0.1-dev.1
* Add AVAudioSession Appdelegate(iOS)

## 2.0.1-dev
* Add AVAudioSession Appdelegate(iOS)

## 2.0.1

* Fixed some bugs.
* `Android` using Telecom Framework
* Add `silenceEvents`
* Add `normalHandle` props https://github.com/hiennguyen92/flutter_callkit_incoming/pull/403
* Android add `textColor` props https://github.com/hiennguyen92/flutter_callkit_incoming/pull/398
* Android invisible avatar for default https://github.com/hiennguyen92/flutter_callkit_incoming/pull/393
* Add Method for call API when accept/decline/end/timeout

## 2.0.0+2

* Fixed some bugs.
* Support request permission for Android 13+ `requestNotificationPermission`

## 2.0.0+1

* Fixed some bugs.
* Add `landscape` for tablet
* Fix issue head-up for redmi / xiaomi devices

## 2.0.0

* Fixed some bugs.
* Adapt flutter_lints and use lowerCamelCase to Event enum
* Rename properties 
        `textMisssedCall` -> `subtitle`,
        `textCallback` -> `callbackText`,
        `isShowMissedCallNotification` -> `showNotification`,
* Move inside properties `missedCallNotification {showNotification, isShowCallback, subtitle, callbackText}`
* Add setCallConnected option iOS `await FlutterCallkitIncoming.setCallConnected(this._currentUuid)`
* Add hold option iOS
* Add mute call option iOS
* Many other issues
    1. Thank @ryojiro
    https://github.com/hiennguyen92/flutter_callkit_incoming/pull/263
    https://github.com/hiennguyen92/flutter_callkit_incoming/pull/264
    https://github.com/hiennguyen92/flutter_callkit_incoming/pull/262
    2. Many Thank @mouEsam
    https://github.com/hiennguyen92/flutter_callkit_incoming/pull/227
    3. ...


## 1.0.3+3

* Update README.md
* Fixed some bugs.

## 1.0.3+2

* REMOVED

## 1.0.3+1

* Dart class models instead using dynamic types and Maps (thank @icodelifee - https://github.com/hiennguyen92/flutter_callkit_incoming/pull/180)
* Allow to call from native Android (thank @fabiocody - https://github.com/hiennguyen92/flutter_callkit_incoming/pull/185)
* Add android notification channel name `incomingCallNotificationChannelName` `missedCallNotificationChannelName` (thank @AAkira - https://github.com/hiennguyen92/flutter_callkit_incoming/pull/177)
* Adding the feature to change template of notification to small `isCustomSmallExNotification` (thank @anocean2 - https://github.com/hiennguyen92/flutter_callkit_incoming/pull/196)
* Fixed ringtone sound not playing in Release mode on Android (thank @mschudt - https://github.com/hiennguyen92/flutter_callkit_incoming/pull/204)
* Fixed some bugs.

## 1.0.3

* REMOVED

## 1.0.2+2

* Fix notification Android 12
* Fix sound notification
* Support `backgroundUrl` using path assets
* Fixed some bugs.

## 1.0.2+1

* Issue no audio when Accept(iOS)
* Duplicate sound notification(Android)
* Support Flutter 3
* Fixed some bugs.

## 1.0.2

* Fixed issue open app(terminated/background state - Android).
* Completed Example  
* Fixed some bugs.

## 1.0.1+8

* Add props `isShowMissedCallNotification` using show Missed call notification(Android)
* Fixed issue decline(terminated/background state - there will be about 3 seconds to call the api before the app is closed.)
* Fixed some bugs.

## 1.0.1+7

* Fixed issue open app(terminated/background state).
* Fixed some bugs.

## 1.0.1+6

* Add props for text
* Fixed issue open app(terminated/background state).
* Fixed some bugs.

## 1.0.1+5

* Update custom miss call notification
* Fixed issue open app(terminated/background state).

## 1.0.1+4

* add `showMissCallNotification` only for Android, using show miss call notification 
* Fixed some bugs.

## 1.0.1+3

* add props `isShowCallback` using show Callback for miss call(Android)
* public props data call for Object-C/Swift
* Example using FCM(Android)
* Fixed some bugs.

## 1.0.1+2

* Fixed issue default ringtone(Android)
* Fixed issue vibration(Android)
* Fixed issue sound play type ringtone volumn system(Android)
* Fixed flow incomming screen(Android)
* Fixed some bugs.

## 1.0.1+1

* Switch using Service for Ringtone(Android)
* Fixed issue vibration(Android)
* Add `getDevicePushTokenVoIP()` feature
* Fixed some bugs.

## 1.0.1

* Pustkit and VoIP setup instructions (PUSHKIT.md)
* Callback from Recent History IOS
* Using System ringtone for default
* Fixed func `endAllCalls()` Android
* Bugs Android 12.
* Fixed some bugs.

## 1.0.0+8

* Share func call from native(iOS)

## 1.0.0+7

* Add custom `headers` using for avatar/background image (only for Android)

## 1.0.0+6

* Fixed func `activeCalls()` Get active calls

## 1.0.0+5

* Fixed endCall
* Bugs Targeting Android 12 (Android).
* Bugs `audio session` (iOS)
* Fixed some bugs.

## 1.0.0+4

* Update README.md.
* Add func `activeCalls()` Get active calls
* Remove notification when click action `Call back` (Android).
* Bugs `no activation of the audio session` (iOS)
* Fixed some bugs.

## 1.0.0+3

* Update README.md.
* Add props android `isShowLogo`.
* Fixed some bugs.

## 1.0.0+2

* Update README.md.
* Update documentation.

## 1.0.0+1

* Update README.md.
* Fixed some bugs.

## 1.0.0

* Initial release.
