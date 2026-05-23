// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserConfiguration _$UserConfigurationFromJson(Map<String, dynamic> json) =>
    _UserConfiguration(
      audioLanguagePreference: json['AudioLanguagePreference'] as String?,
      playDefaultAudioTrack: json['PlayDefaultAudioTrack'] as bool?,
      subtitleLanguagePreference: json['SubtitleLanguagePreference'] as String?,
      displayMissingEpisodes: json['DisplayMissingEpisodes'] as bool?,
      groupedFolders:
          (json['GroupedFolders'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      subtitleMode: json['SubtitleMode'] as String?,
      displayCollectionsView: json['DisplayCollectionsView'] as bool?,
      displayMyMedia: json['DisplayMyMedia'] as bool?,
    );

Map<String, dynamic> _$UserConfigurationToJson(_UserConfiguration instance) =>
    <String, dynamic>{
      'AudioLanguagePreference': instance.audioLanguagePreference,
      'PlayDefaultAudioTrack': instance.playDefaultAudioTrack,
      'SubtitleLanguagePreference': instance.subtitleLanguagePreference,
      'DisplayMissingEpisodes': instance.displayMissingEpisodes,
      'GroupedFolders': instance.groupedFolders,
      'SubtitleMode': instance.subtitleMode,
      'DisplayCollectionsView': instance.displayCollectionsView,
      'DisplayMyMedia': instance.displayMyMedia,
    };

_UserPolicy _$UserPolicyFromJson(Map<String, dynamic> json) => _UserPolicy(
  isAdministrator: json['IsAdministrator'] as bool?,
  isHidden: json['IsHidden'] as bool?,
  isDisabled: json['IsDisabled'] as bool?,
  maxBitrate: (json['MaxBitrate'] as num?)?.toInt(),
  allowedTags:
      (json['AllowedTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  blockedTags:
      (json['BlockedTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  enableMediaPlayback: json['EnableMediaPlayback'] as bool?,
  enableLiveTvManagement: json['EnableLiveTvManagement'] as bool?,
  enableLiveTvAccess: json['EnableLiveTvAccess'] as bool?,
  enableUserPreferenceAccess: json['EnableUserPreferenceAccess'] as bool?,
  enabledDevices:
      (json['EnabledDevices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserPolicyToJson(_UserPolicy instance) =>
    <String, dynamic>{
      'IsAdministrator': instance.isAdministrator,
      'IsHidden': instance.isHidden,
      'IsDisabled': instance.isDisabled,
      'MaxBitrate': instance.maxBitrate,
      'AllowedTags': instance.allowedTags,
      'BlockedTags': instance.blockedTags,
      'EnableMediaPlayback': instance.enableMediaPlayback,
      'EnableLiveTvManagement': instance.enableLiveTvManagement,
      'EnableLiveTvAccess': instance.enableLiveTvAccess,
      'EnableUserPreferenceAccess': instance.enableUserPreferenceAccess,
      'EnabledDevices': instance.enabledDevices,
    };

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['Id'] as String?,
  name: json['Name'] as String?,
  serverId: json['ServerId'] as String?,
  hasPassword: json['HasPassword'] as bool?,
  hasConfiguredPassword: json['HasConfiguredPassword'] as bool?,
  hasConfiguredEasyPassword: json['HasConfiguredEasyPassword'] as bool?,
  configuration: json['Configuration'] == null
      ? null
      : UserConfiguration.fromJson(
          json['Configuration'] as Map<String, dynamic>,
        ),
  policy: json['Policy'] == null
      ? null
      : UserPolicy.fromJson(json['Policy'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'Id': instance.id,
  'Name': instance.name,
  'ServerId': instance.serverId,
  'HasPassword': instance.hasPassword,
  'HasConfiguredPassword': instance.hasConfiguredPassword,
  'HasConfiguredEasyPassword': instance.hasConfiguredEasyPassword,
  'Configuration': instance.configuration,
  'Policy': instance.policy,
};
