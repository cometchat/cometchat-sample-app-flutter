import 'package:json_annotation/json_annotation.dart';

part 'android_params.g.dart';

/// Object config for Android.
@JsonSerializable(explicitToJson: true)
class AndroidParams {
  const AndroidParams({
    this.isCustomNotification,
    this.isCustomSmallExNotification,
    this.isShowLogo,
    this.logoUrl,
    this.isShowCallID,
    this.ringtonePath,
    this.backgroundColor,
    this.backgroundUrl,
    this.actionColor,
    this.textColor,
    this.incomingCallNotificationChannelName,
    this.missedCallNotificationChannelName,
    this.isShowFullLockedScreen,
    this.isImportant,
    this.isBot,
  });

  /// Using custom notifications.
  final bool? isCustomNotification;

  /// Using custom notification small on some devices clipped out in android.
  final bool? isCustomSmallExNotification;

  /// Show logo app inside full screen.
  final bool? isShowLogo;

  /// Logo aoo inside full screen, example: http://... https://... or "assets/abc.png"
  final String? logoUrl;

  /// Show call id app inside full screen.
  final bool? isShowCallID;

  /// File name ringtone, put file into /android/app/src/main/res/raw/ringtone_default.mp3 -> value: `ringtone_default`
  final String? ringtonePath;

  /// Incoming call screen background color.
  final String? backgroundColor;

  /// Using image background for Incoming call screen. example: http://... https://... or "assets/abc.png"
  final String? backgroundUrl;

  /// Color used in button/text on notification.
  final String? actionColor;

  /// Color used for the text in the full screen notification
  final String? textColor;

  /// Notification channel name of incoming call.
  final String? incomingCallNotificationChannelName;

  /// Notification channel name of missed call.
  final String? missedCallNotificationChannelName;

  /// Show full locked screen.
  final bool? isShowFullLockedScreen;

  /// Caller is important to the user of this device with regards to how frequently they interact.
  /// https://developer.android.com/reference/androidx/core/app/Person#isImportant()
  final bool? isImportant;

  /// Used primarily to identify automated tooling.
  /// https://developer.android.com/reference/androidx/core/app/Person#isBot()
  final bool? isBot;

  factory AndroidParams.fromJson(Map<String, dynamic> json) =>
      _$AndroidParamsFromJson(json);

  Map<String, dynamic> toJson() => _$AndroidParamsToJson(this);
}
