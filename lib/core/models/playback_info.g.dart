// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaybackInfo _$PlaybackInfoFromJson(Map<String, dynamic> json) =>
    _PlaybackInfo(
      mediaSources:
          (json['MediaSources'] as List<dynamic>?)
              ?.map((e) => MediaSourceInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      errorCode: json['ErrorCode'] as String?,
    );

Map<String, dynamic> _$PlaybackInfoToJson(_PlaybackInfo instance) =>
    <String, dynamic>{
      'MediaSources': instance.mediaSources,
      'ErrorCode': instance.errorCode,
    };
