// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_source_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaSourceInfo _$MediaSourceInfoFromJson(Map<String, dynamic> json) =>
    _MediaSourceInfo(
      id: json['Id'] as String?,
      name: json['Name'] as String?,
      path: json['Path'] as String?,
      protocol: json['Protocol'] as String?,
      type: json['Type'] as String?,
      size: (json['Size'] as num?)?.toInt(),
      container: json['Container'] as String?,
      directStreamUrl: json['DirectStreamUrl'] as String?,
      transcodingUrl: json['TranscodingUrl'] as String?,
      supportsDirectStream: json['SupportsDirectStream'] as bool?,
      supportsTranscoding: json['SupportsTranscoding'] as bool?,
      mediaStreams:
          (json['MediaStreams'] as List<dynamic>?)
              ?.map((e) => MediaStream.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      videoType: json['VideoType'] as String?,
    );

Map<String, dynamic> _$MediaSourceInfoToJson(_MediaSourceInfo instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Path': instance.path,
      'Protocol': instance.protocol,
      'Type': instance.type,
      'Size': instance.size,
      'Container': instance.container,
      'DirectStreamUrl': instance.directStreamUrl,
      'TranscodingUrl': instance.transcodingUrl,
      'SupportsDirectStream': instance.supportsDirectStream,
      'SupportsTranscoding': instance.supportsTranscoding,
      'MediaStreams': instance.mediaStreams,
      'VideoType': instance.videoType,
    };
