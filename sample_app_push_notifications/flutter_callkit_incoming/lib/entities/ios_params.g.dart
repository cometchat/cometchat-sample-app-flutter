// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ios_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IOSParams _$IOSParamsFromJson(Map<String, dynamic> json) => IOSParams(
      iconName: json['iconName'] as String?,
      handleType: json['handleType'] as String?,
      supportsVideo: json['supportsVideo'] as bool?,
      maximumCallGroups: json['maximumCallGroups'] as int?,
      maximumCallsPerCallGroup: json['maximumCallsPerCallGroup'] as int?,
      audioSessionMode: json['audioSessionMode'] as String?,
      audioSessionActive: json['audioSessionActive'] as bool?,
      audioSessionPreferredSampleRate:
          (json['audioSessionPreferredSampleRate'] as num?)?.toDouble(),
      audioSessionPreferredIOBufferDuration:
          (json['audioSessionPreferredIOBufferDuration'] as num?)?.toDouble(),
      configureAudioSession: json['configureAudioSession'] as bool?,
      supportsDTMF: json['supportsDTMF'] as bool?,
      supportsHolding: json['supportsHolding'] as bool?,
      supportsGrouping: json['supportsGrouping'] as bool?,
      supportsUngrouping: json['supportsUngrouping'] as bool?,
      ringtonePath: json['ringtonePath'] as String?,
    );

Map<String, dynamic> _$IOSParamsToJson(IOSParams instance) => <String, dynamic>{
      'iconName': instance.iconName,
      'handleType': instance.handleType,
      'supportsVideo': instance.supportsVideo,
      'maximumCallGroups': instance.maximumCallGroups,
      'maximumCallsPerCallGroup': instance.maximumCallsPerCallGroup,
      'audioSessionMode': instance.audioSessionMode,
      'audioSessionActive': instance.audioSessionActive,
      'audioSessionPreferredSampleRate':
          instance.audioSessionPreferredSampleRate,
      'audioSessionPreferredIOBufferDuration':
          instance.audioSessionPreferredIOBufferDuration,
      'configureAudioSession': instance.configureAudioSession,
      'supportsDTMF': instance.supportsDTMF,
      'supportsHolding': instance.supportsHolding,
      'supportsGrouping': instance.supportsGrouping,
      'supportsUngrouping': instance.supportsUngrouping,
      'ringtonePath': instance.ringtonePath,
    };
