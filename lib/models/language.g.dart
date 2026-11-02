// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Language _$LanguageFromJson(Map<String, dynamic> json) => Language(
  languageId: json['languageId'] as String?,
  name: json['name'] as String?,
  isDeletable: json['isDeletable'] as bool? ?? false,
)..isSelectable = json['isSelectable'] as bool?;

Map<String, dynamic> _$LanguageToJson(Language instance) => <String, dynamic>{
  'isDeletable': ?instance.isDeletable,
  'isSelectable': ?instance.isSelectable,
  'languageId': ?instance.languageId,
  'name': ?instance.name,
};
