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

Map<String, dynamic> _$GenreToJson(Genre instance) => <String, dynamic>{
  'isDeletable': ?instance.isDeletable,
  'isSelectable': ?instance.isSelectable,
  'genreId': ?instance.genreId,
  'name': ?instance.name,
};
