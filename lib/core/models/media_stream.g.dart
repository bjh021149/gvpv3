// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaStream _$MediaStreamFromJson(Map<String, dynamic> json) => _MediaStream(
  index: (json['Index'] as num?)?.toInt(),
  type: json['Type'] as String?,
  codec: json['Codec'] as String?,
  language: json['Language'] as String?,
  title: json['Title'] as String?,
  isDefault: json['IsDefault'] as bool?,
  isExternal: json['IsExternal'] as bool?,
  path: json['Path'] as String?,
  displayTitle: json['DisplayTitle'] as String?,
  height: (json['Height'] as num?)?.toInt(),
  width: (json['Width'] as num?)?.toInt(),
  channelLayout: json['ChannelLayout'] as String?,
);

Map<String, dynamic> _$MediaStreamToJson(_MediaStream instance) =>
    <String, dynamic>{
      'Index': instance.index,
      'Type': instance.type,
      'Codec': instance.codec,
      'Language': instance.language,
      'Title': instance.title,
      'IsDefault': instance.isDefault,
      'IsExternal': instance.isExternal,
      'Path': instance.path,
      'DisplayTitle': instance.displayTitle,
      'Height': instance.height,
      'Width': instance.width,
      'ChannelLayout': instance.channelLayout,
    };
