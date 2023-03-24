// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Info _$InfoFromJson(Map<String, dynamic> json) => Info(
      path: json['path'] as String?,
      name: json['name'] as String?,
      isFolder: json['isFolder'] as bool?,
      isDeletable: json['isDeletable'] as bool? ?? false,
    )..isSelectable = json['isSelectable'] as bool?;

Map<String, dynamic> _$InfoToJson(Info instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isDeletable', instance.isDeletable);
  writeNotNull('isSelectable', instance.isSelectable);
  writeNotNull('path', instance.path);
  writeNotNull('name', instance.name);
  writeNotNull('isFolder', instance.isFolder);
  return val;
}
