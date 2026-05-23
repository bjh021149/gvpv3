// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_item_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserItemDataDto _$UserItemDataDtoFromJson(Map<String, dynamic> json) =>
    _UserItemDataDto(
      playbackPositionTicks: (json['PlaybackPositionTicks'] as num?)?.toInt(),
      isFavorite: json['IsFavorite'] as bool?,
      likes: json['Likes'] as bool?,
      played: json['Played'] as bool?,
      playedPercentage: (json['PlayedPercentage'] as num?)?.toDouble(),
      unplayedItemCount: (json['UnplayedItemCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserItemDataDtoToJson(_UserItemDataDto instance) =>
    <String, dynamic>{
      'PlaybackPositionTicks': instance.playbackPositionTicks,
      'IsFavorite': instance.isFavorite,
      'Likes': instance.likes,
      'Played': instance.played,
      'PlayedPercentage': instance.playedPercentage,
      'UnplayedItemCount': instance.unplayedItemCount,
    };
