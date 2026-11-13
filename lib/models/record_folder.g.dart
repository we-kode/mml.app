// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordFolder _$RecordFolderFromJson(Map<String, dynamic> json) => RecordFolder(
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num?)?.toInt(),
  day: (json['day'] as num?)?.toInt(),
  isDeletable: json['isDeletable'] as bool? ?? false,
  isSelectable: json['isSelectable'] as bool? ?? false,
);

Map<String, dynamic> _$RecordFolderToJson(RecordFolder instance) =>
    <String, dynamic>{
      'isDeletable': ?instance.isDeletable,
      'isSelectable': ?instance.isSelectable,
      'year': instance.year,
      'month': ?instance.month,
      'day': ?instance.day,
    };
