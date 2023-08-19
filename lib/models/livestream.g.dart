// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livestream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Livestream _$LivestreamFromJson(Map<String, dynamic> json) => Livestream(
      livestreamId: json['livestreamId'] as String?,
      displayName: json['displayName'] as String?,
    )
      ..isDeletable = json['isDeletable'] as bool?
      ..isSelectable = json['isSelectable'] as bool?
      ..title = json['displayName'] as String?
      ..trackNumber = json['trackNumber'] as int?
      ..date =
          json['date'] == null ? null : DateTime.parse(json['date'] as String)
      ..duration = (json['duration'] as num?)?.toDouble()
      ..artist = json['artist'] as String?
      ..genre = json['genre'] as String?
      ..album = json['album'] as String?
      ..language = json['language'] as String?
      ..checksum = json['checksum'] as String?;

Map<String, dynamic> _$LivestreamToJson(Livestream instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isDeletable', instance.isDeletable);
  writeNotNull('isSelectable', instance.isSelectable);
  writeNotNull('title', instance.title);
  writeNotNull('trackNumber', instance.trackNumber);
  writeNotNull('date', instance.date?.toIso8601String());
  writeNotNull('duration', instance.duration);
  writeNotNull('artist', instance.artist);
  writeNotNull('genre', instance.genre);
  writeNotNull('album', instance.album);
  writeNotNull('language', instance.language);
  writeNotNull('checksum', instance.checksum);
  writeNotNull('livestreamId', instance.livestreamId);
  writeNotNull('displayName', instance.displayName);
  return val;
}
