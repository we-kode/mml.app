// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livestream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Livestream _$LivestreamFromJson(Map<String, dynamic> json) => Livestream(
      recordId: json['recordId'] as String?,
      title: json['title'] as String?,
    )
      ..isDeletable = json['isDeletable'] as bool?
      ..isSelectable = json['isSelectable'] as bool?
      ..trackNumber = json['trackNumber'] as int?
      ..date =
          json['date'] == null ? null : DateTime.parse(json['date'] as String)
      ..duration = (json['duration'] as num?)?.toDouble()
      ..artist = json['artist'] as String?
      ..genre = json['genre'] as String?
      ..album = json['album'] as String?
      ..language = json['language'] as String?
      ..checksum = json['checksum'] as String?
      ..cover = json['cover'] as String?;

Map<String, dynamic> _$LivestreamToJson(Livestream instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isDeletable', instance.isDeletable);
  writeNotNull('isSelectable', instance.isSelectable);
  writeNotNull('recordId', instance.recordId);
  writeNotNull('title', instance.title);
  writeNotNull('trackNumber', instance.trackNumber);
  writeNotNull('date', instance.date?.toIso8601String());
  writeNotNull('duration', instance.duration);
  writeNotNull('artist', instance.artist);
  writeNotNull('genre', instance.genre);
  writeNotNull('album', instance.album);
  writeNotNull('language', instance.language);
  writeNotNull('checksum', instance.checksum);
  writeNotNull('cover', instance.cover);
  return val;
}
