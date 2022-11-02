// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Playlist _$PlaylistFromJson(Map<String, dynamic> json) => Playlist(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isDeletable: json['isDeletable'] as bool? ?? true,
    )..isSelectable = json['isSelectable'] as bool?;

Map<String, dynamic> _$PlaylistToJson(Playlist instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isDeletable', instance.isDeletable);
  writeNotNull('isSelectable', instance.isSelectable);
  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  return val;
}
