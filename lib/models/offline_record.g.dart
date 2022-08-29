// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineRecord _$OfflineRecordFromJson(Map<String, dynamic> json) =>
    OfflineRecord(
      id: json['id'] as int?,
      recordId: json['recordId'] as String?,
      title: json['title'] as String?,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      album: json['album'] as String?,
      artist: json['artist'] as String?,
      genre: json['genre'] as String?,
      file: json['file'] as String?,
      playlist: json['playlist'] == null
          ? null
          : Playlist.fromJson(json['playlist'] as Map<String, dynamic>),
      isDeletable: json['isDeletable'] as bool? ?? true,
    );

Map<String, dynamic> _$OfflineRecordToJson(OfflineRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isDeletable', instance.isDeletable);
  writeNotNull('recordId', instance.recordId);
  writeNotNull('title', instance.title);
  writeNotNull('file', instance.file);
  val['duration'] = instance.duration;
  writeNotNull('artist', instance.artist);
  writeNotNull('genre', instance.genre);
  writeNotNull('album', instance.album);
  writeNotNull('playlist', instance.playlist?.toJson());
  writeNotNull('id', instance.id);
  return val;
}
