import 'package:json_annotation/json_annotation.dart';

part 'record_export.g.dart';

/// Record model that holds all information of a record.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class RecordExport {
  /// Title of the record.
  String? title;

  /// Checksum of the record data.
  String? checksum;

  /// Creates a new record instance with the given values.
  RecordExport({
    required this.checksum,
    this.title,
  });

  /// Converts a json object/map to the record model.
  factory RecordExport.fromJson(Map<String, dynamic> json) =>
      _$RecordExportFromJson(json);

  /// Converts the current record model to a json object/map.
  Map<String, dynamic> toJson() => _$RecordExportToJson(this);
}
