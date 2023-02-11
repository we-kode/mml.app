// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_view_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordViewSettings _$RecordViewSettingsFromJson(Map<String, dynamic> json) =>
    RecordViewSettings(
      genre: json['genre'] as bool? ?? false,
      album: json['album'] as bool? ?? false,
      language: json['language'] as bool? ?? false,
      tracknumber: json['tracknumber'] as bool? ?? false,
    );

Map<String, dynamic> _$RecordViewSettingsToJson(RecordViewSettings instance) =>
    <String, dynamic>{
      'genre': instance.genre,
      'album': instance.album,
      'language': instance.language,
      'tracknumber': instance.tracknumber,
    };
