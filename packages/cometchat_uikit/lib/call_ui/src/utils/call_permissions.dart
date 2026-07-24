import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

/// Utility to request microphone/camera permissions before starting a call.
///
/// On Android 6+ and iOS, [Permission.microphone] and [Permission.camera]
/// are runtime permissions that must be granted before WebRTC can access
/// the hardware. Without this, the Calls SDK throws `SecurityError:
/// Permission denied` when creating audio/video tracks.
///
/// On Web, the browser handles permissions via its own getUserMedia prompt
/// when the WebRTC session starts — native permission_handler is not
/// supported. We return `true` immediately on web.
class CallPermissions {
  CallPermissions._();

  /// Request microphone permission (audio calls).
  /// Returns `true` if granted or already granted.
  static Future<bool> requestMicrophone() async {
    // On web, the browser prompts for permissions when WebRTC starts.
    // permission_handler does not support web — skip native request.
    if (kIsWeb) return true;

    final before = await Permission.microphone.status;
    developer.log(
      'CallPermissions.requestMicrophone: status before request = $before',
    );
    final status = await Permission.microphone.request();
    developer.log(
      'CallPermissions.requestMicrophone: status after request = $status',
    );
    if (!status.isGranted) {
      developer.log('CallPermissions: microphone permission denied ($status)');
    }
    return status.isGranted;
  }

  /// Request microphone + camera permissions (video calls).
  /// Returns `true` if both are granted.
  static Future<bool> requestMicrophoneAndCamera() async {
    // On web, the browser prompts for permissions when WebRTC starts.
    // permission_handler does not support web — skip native request.
    if (kIsWeb) return true;

    final micBefore = await Permission.microphone.status;
    final camBefore = await Permission.camera.status;
    developer.log(
      'CallPermissions.requestMicrophoneAndCamera: before mic=$micBefore cam=$camBefore',
    );
    final statuses = await [Permission.microphone, Permission.camera].request();

    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
    final camGranted = statuses[Permission.camera]?.isGranted ?? false;
    developer.log(
      'CallPermissions.requestMicrophoneAndCamera: after mic=${statuses[Permission.microphone]} cam=${statuses[Permission.camera]}',
    );

    if (!micGranted || !camGranted) {
      developer.log('CallPermissions: mic=$micGranted, camera=$camGranted');
    }
    return micGranted && camGranted;
  }

  /// Request the appropriate permissions for a call type.
  /// [isVideoCall] — if true, requests both microphone and camera.
  static Future<bool> requestForCallType({required bool isVideoCall}) {
    return isVideoCall ? requestMicrophoneAndCamera() : requestMicrophone();
  }
}
