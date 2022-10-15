// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Genre _$GenreFromJson(Map<String, dynamic> json) => Genre(
      genreId: json['genreId'] as String?,
      name: json['name'] as String?,
      isDeletable: json['isDeletable'] as bool? ?? false,
    )..isSelectable = json['isSelectable'] as bool?;

Map<String, dynamic> _$GenreToJson(Genre instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isDeletable', instance.isDeletable);
  writeNotNull('isSelectable', instance.isSelectable);
  writeNotNull('genreId', instance.genreId);
  writeNotNull('name', instance.name);
  return val;
}
