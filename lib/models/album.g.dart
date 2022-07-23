// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
      albumId: json['albumId'] as String?,
      albumName: json['albumName'] as String?,
    );

Map<String, dynamic> _$AlbumToJson(Album instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('albumId', instance.albumId);
  writeNotNull('albumName', instance.albumName);
  return val;
}
