// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_kit_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallKitParams _$CallKitParamsFromJson(Map<String, dynamic> json) =>
    CallKitParams(
      id: json['id'] as String?,
      nameCaller: json['nameCaller'] as String?,
      appName: json['appName'] as String?,
      avatar: json['avatar'] as String?,
      handle: json['handle'] as String?,
      type: json['type'] as int?,
      normalHandle: json['normalHandle'] as int?,
      duration: json['duration'] as int?,
      textAccept: json['textAccept'] as String?,
      textDecline: json['textDecline'] as String?,
      callingNotification: json['callingNotification'] == null
          ? null
          : NotificationParams.fromJson(
              json['callingNotification'] as Map<String, dynamic>),
      missedCallNotification: json['missedCallNotification'] == null
          ? null
          : NotificationParams.fromJson(
              json['missedCallNotification'] as Map<String, dynamic>),
      extra: json['extra'] as Map<String, dynamic>?,
      headers: json['headers'] as Map<String, dynamic>?,
      android: json['android'] == null
          ? null
          : AndroidParams.fromJson(json['android'] as Map<String, dynamic>),
      ios: json['ios'] == null
          ? null
          : IOSParams.fromJson(json['ios'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CallKitParamsToJson(CallKitParams instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameCaller': instance.nameCaller,
      'appName': instance.appName,
      'avatar': instance.avatar,
      'handle': instance.handle,
      'type': instance.type,
      'normalHandle': instance.normalHandle,
      'duration': instance.duration,
      'textAccept': instance.textAccept,
      'textDecline': instance.textDecline,
      'missedCallNotification': instance.missedCallNotification?.toJson(),
      'callingNotification': instance.callingNotification?.toJson(),
      'extra': instance.extra,
      'headers': instance.headers,
      'android': instance.android?.toJson(),
      'ios': instance.ios?.toJson(),
    };
