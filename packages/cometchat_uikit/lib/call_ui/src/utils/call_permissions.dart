import 'dart:developer' as developer;
import 'package:permission_handler/permission_handler.dart';

/// Utility to request microphone/camera permissions before starting a call.
///
/// On Android 6+ and iOS, [Permission.microphone] and [Permission.camera]
/// are runtime permissions that must be granted before WebRTC can access
/// the hardware. Without this, the Calls SDK throws `SecurityError:
/// Permission denied` when creating audio/video tracks.
class CallPermissions {
  CallPermissions._();

  /// Request microphone permission (audio calls).
  /// Returns `true` if granted or already granted.
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      developer.log('CallPermissions: microphone permission denied ($status)');
    }
    return status.isGranted;
  }

  /// Request microphone + camera permissions (video calls).
  /// Returns `true` if both are granted.
  static Future<bool> requestMicrophoneAndCamera() async {
    final statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
    final camGranted = statuses[Permission.camera]?.isGranted ?? false;

    if (!micGranted || !camGranted) {
      developer.log(
        'CallPermissions: mic=$micGranted, camera=$camGranted',
      );
    }
    return micGranted && camGranted;
  }

  /// Request the appropriate permissions for a call type.
  /// [isVideoCall] — if true, requests both microphone and camera.
  static Future<bool> requestForCallType({required bool isVideoCall}) {
    return isVideoCall ? requestMicrophoneAndCamera() : requestMicrophone();
  }
}
