// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Playlist _$PlaylistFromJson(Map<String, dynamic> json) => Playlist(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  isDeletable: json['isDeletable'] as bool? ?? true,
)..isSelectable = json['isSelectable'] as bool?;

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
  'isDeletable': ?instance.isDeletable,
  'isSelectable': ?instance.isSelectable,
  'id': ?instance.id,
  'name': ?instance.name,
};
