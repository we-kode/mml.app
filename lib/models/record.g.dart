// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Record _$RecordFromJson(Map<String, dynamic> json) => Record(
      recordId: json['recordId'] as String?,
      title: json['title'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      album: json['album'] as String?,
      artist: json['artist'] as String?,
      genre: json['genre'] as String?,
    );

Map<String, dynamic> _$RecordToJson(Record instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('recordId', instance.recordId);
  writeNotNull('title', instance.title);
  writeNotNull('date', instance.date?.toIso8601String());
  val['duration'] = instance.duration;
  writeNotNull('artist', instance.artist);
  writeNotNull('genre', instance.genre);
  writeNotNull('album', instance.album);
  return val;
}
