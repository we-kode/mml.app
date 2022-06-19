// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientRegistration _$ClientRegistrationFromJson(Map<String, dynamic> json) =>
    ClientRegistration(
      token: json['token'] as String,
      endpoint: json['endpoint'] as String,
      appKey: json['appKey'] as String,
    );

Map<String, dynamic> _$ClientRegistrationToJson(ClientRegistration instance) =>
    <String, dynamic>{
      'token': instance.token,
      'endpoint': instance.endpoint,
      'appKey': instance.appKey,
    };
