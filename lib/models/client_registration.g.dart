// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientRegistration _$ClientRegistrationFromJson(Map<String, dynamic> json) =>
    ClientRegistration(
      token: json['token'] as String,
      serverName: json['serverName'] as String,
      appKey: json['appKey'] as String,
    );

Map<String, dynamic> _$ClientRegistrationToJson(ClientRegistration instance) =>
    <String, dynamic>{
      'token': instance.token,
      'serverName': instance.serverName,
      'appKey': instance.appKey,
    };
