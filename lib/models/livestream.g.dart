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
      ..trackNumber = (json['trackNumber'] as num?)?.toInt()
      ..date =
          json['date'] == null ? null : DateTime.parse(json['date'] as String)
      ..duration = (json['duration'] as num?)?.toDouble()
      ..artist = json['artist'] as String?
      ..genre = json['genre'] as String?
      ..album = json['album'] as String?
      ..language = json['language'] as String?
      ..checksum = json['checksum'] as String?
      ..cover = json['cover'] as String?;
