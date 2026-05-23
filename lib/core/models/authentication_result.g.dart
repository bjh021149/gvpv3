// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthenticationResult _$AuthenticationResultFromJson(
  Map<String, dynamic> json,
) => _AuthenticationResult(
  accessToken: json['AccessToken'] as String?,
  serverId: json['ServerId'] as String?,
  user: json['User'] == null
      ? null
      : UserDto.fromJson(json['User'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthenticationResultToJson(
  _AuthenticationResult instance,
) => <String, dynamic>{
  'AccessToken': instance.accessToken,
  'ServerId': instance.serverId,
  'User': instance.user,
};
