// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_export.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordExport _$RecordExportFromJson(Map<String, dynamic> json) => RecordExport(
      checksum: json['checksum'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$RecordExportToJson(RecordExport instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  writeNotNull('checksum', instance.checksum);
  return val;
}
