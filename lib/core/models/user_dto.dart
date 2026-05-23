// lib/core/models/user_dto.dart

import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// {@template user_configuration}
/// User-specific display and behavior configuration.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
@freezed
abstract class UserConfiguration with _$UserConfiguration {
  /// {@macro user_configuration}
  const factory UserConfiguration({
    /// Audio language preference (ISO code).
    String? audioLanguagePreference,

    /// Whether to play the default audio track regardless of language.
    bool? playDefaultAudioTrack,

    /// Subtitle language preference (ISO code).
    String? subtitleLanguagePreference,

    /// Whether to display subtitles by default.
    bool? displayMissingEpisodes,

    /// Grouped folders configuration.
    @Default([]) List<String> groupedFolders,

    /// Subtitle playback mode.
    String? subtitleMode,

    /// Whether to display collections within the media library.
    bool? displayCollectionsView,

    /// Whether to display the "My Media" section on the home screen.
    bool? displayMyMedia,
  }) = _UserConfiguration;

  /// Creates a [UserConfiguration] from JSON.
  factory UserConfiguration.fromJson(Map<String, dynamic> json) =>
      _$UserConfigurationFromJson(json);
}

/// {@template user_policy}
/// Administrative policy settings for a user.
///
/// Controls access permissions, feature availability,
/// and content restrictions for the user account.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
@freezed
abstract class UserPolicy with _$UserPolicy {
  /// {@macro user_policy}
  const factory UserPolicy({
    /// Whether the user is an administrator.
    bool? isAdministrator,

    /// Whether the user is hidden from login screens.
    bool? isHidden,

    /// Whether the user's activity is disabled.
    bool? isDisabled,

    /// Maximum allowed bitrate for streaming.
    int? maxBitrate,

    /// Allowed tags for content access control.
    @Default([]) List<String> allowedTags,

    /// Blocked tags that the user cannot access.
    @Default([]) List<String> blockedTags,

    /// Whether the user can manage the server settings.
    bool? enableMediaPlayback,

    /// Whether the user can manage live TV.
    bool? enableLiveTvManagement,

    /// Whether the user can access live TV.
    bool? enableLiveTvAccess,

    /// Whether the user can manage other users.
    bool? enableUserPreferenceAccess,

    /// Allowed device identifiers for this user.
    @Default([]) List<String> enabledDevices,
  }) = _UserPolicy;

  /// Creates a [UserPolicy] from JSON.
  factory UserPolicy.fromJson(Map<String, dynamic> json) =>
      _$UserPolicyFromJson(json);
}

/// {@template user_dto}
/// Represents an Emby user account.
///
/// Contains user identity, authentication status, and
/// associated configuration/policy settings.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
@freezed
abstract class UserDto with _$UserDto {
  /// {@macro user_dto}
  const factory UserDto({
    /// Unique identifier for the user.
    String? id,

    /// Display name of the user.
    String? name,

    /// Server identifier the user belongs to.
    String? serverId,

    /// Whether the user account has a password set.
    bool? hasPassword,

    /// Whether the user has configured a password.
    bool? hasConfiguredPassword,

    /// Whether the user has configured an easy PIN password.
    bool? hasConfiguredEasyPassword,

    /// User display and behavior configuration.
    UserConfiguration? configuration,

    /// Administrative policy settings for the user.
    UserPolicy? policy,
  }) = _UserDto;

  /// Creates a [UserDto] from JSON.
  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
