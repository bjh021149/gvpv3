// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudioDto _$StudioDtoFromJson(Map<String, dynamic> json) => _StudioDto(
  id: (json['Id'] as num?)?.toInt(),
  name: json['Name'] as String?,
  imageTags: (json['ImageTags'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$StudioDtoToJson(_StudioDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'ImageTags': instance.imageTags,
    };

_PersonDto _$PersonDtoFromJson(Map<String, dynamic> json) => _PersonDto(
  id: json['Id'] as String?,
  name: json['Name'] as String?,
  role: json['Role'] as String?,
  type: json['Type'] as String?,
  primaryImageTag: json['PrimaryImageTag'] as String?,
);

Map<String, dynamic> _$PersonDtoToJson(_PersonDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Role': instance.role,
      'Type': instance.type,
      'PrimaryImageTag': instance.primaryImageTag,
    };

_BaseItemDto _$BaseItemDtoFromJson(Map<String, dynamic> json) => _BaseItemDto(
  id: json['Id'] as String?,
  name: json['Name'] as String?,
  type: json['Type'] as String?,
  premiereDate: json['PremiereDate'] == null
      ? null
      : DateTime.parse(json['PremiereDate'] as String),
  officialRating: json['OfficialRating'] as String?,
  communityRating: (json['CommunityRating'] as num?)?.toDouble(),
  criticRating: (json['CriticRating'] as num?)?.toDouble(),
  imageTags: (json['ImageTags'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  backdropImageTags: (json['BackdropImageTags'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  overview: json['Overview'] as String?,
  genres: (json['Genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
  providerIds: (json['ProviderIds'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  studios: (json['Studios'] as List<dynamic>?)
      ?.map((e) => StudioDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  runTimeTicks: (json['RunTimeTicks'] as num?)?.toInt(),
  productionYear: (json['ProductionYear'] as num?)?.toInt(),
  isFolder: json['IsFolder'] as bool?,
  parentId: json['ParentId'] as String?,
  seriesId: json['SeriesId'] as String?,
  seriesName: json['SeriesName'] as String?,
  seasonName: json['SeasonName'] as String?,
  indexNumber: (json['IndexNumber'] as num?)?.toInt(),
  parentIndexNumber: (json['ParentIndexNumber'] as num?)?.toInt(),
  people:
      (json['People'] as List<dynamic>?)
          ?.map((e) => PersonDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  mediaSources:
      (json['MediaSources'] as List<dynamic>?)
          ?.map((e) => MediaSourceInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  userData: json['UserData'] == null
      ? null
      : UserItemDataDto.fromJson(json['UserData'] as Map<String, dynamic>),
  collectionType: json['CollectionType'] as String?,
  childCount: (json['ChildCount'] as num?)?.toInt(),
  status: json['Status'] as String?,
);

Map<String, dynamic> _$BaseItemDtoToJson(_BaseItemDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Type': instance.type,
      'PremiereDate': instance.premiereDate?.toIso8601String(),
      'OfficialRating': instance.officialRating,
      'CommunityRating': instance.communityRating,
      'CriticRating': instance.criticRating,
      'ImageTags': instance.imageTags,
      'BackdropImageTags': instance.backdropImageTags,
      'Overview': instance.overview,
      'Genres': instance.genres,
      'ProviderIds': instance.providerIds,
      'Studios': instance.studios,
      'RunTimeTicks': instance.runTimeTicks,
      'ProductionYear': instance.productionYear,
      'IsFolder': instance.isFolder,
      'ParentId': instance.parentId,
      'SeriesId': instance.seriesId,
      'SeriesName': instance.seriesName,
      'SeasonName': instance.seasonName,
      'IndexNumber': instance.indexNumber,
      'ParentIndexNumber': instance.parentIndexNumber,
      'People': instance.people,
      'MediaSources': instance.mediaSources,
      'UserData': instance.userData,
      'CollectionType': instance.collectionType,
      'ChildCount': instance.childCount,
      'Status': instance.status,
    };
