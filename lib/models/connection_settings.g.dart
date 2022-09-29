// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionSettings _$ConnectionSettingsFromJson(Map<String, dynamic> json) =>
    ConnectionSettings(
      apiKey: json['apiKey'] as String,
      serverName: json['serverName'] as String,
    );

Map<String, dynamic> _$ConnectionSettingsToJson(ConnectionSettings instance) =>
    <String, dynamic>{
      'apiKey': instance.apiKey,
      'serverName': instance.serverName,
    };
