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

Map<String, dynamic> _$LanguageToJson(Language instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isDeletable', instance.isDeletable);
  writeNotNull('isSelectable', instance.isSelectable);
  writeNotNull('languageId', instance.languageId);
  writeNotNull('name', instance.name);
  return val;
}
