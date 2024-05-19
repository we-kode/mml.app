import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/extensions/datetime.dart';
import 'package:mml_app/models/model_base.dart';

part 'record_folder.g.dart';

/// Model holds the actual fodler view, when in hieracrchical navigation.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class RecordFolder extends ModelBase {
  final int year;
  final int? month;
  final int? day;

  /// Initializes the model.
  RecordFolder({
    required this.year,
    this.month,
    this.day,
    bool isDeletable = false,
    bool isSelectable = false,
  }) : super(
          isDeletable: isDeletable,
          isSelectable: isSelectable,
        );

  /// Converts a json object/map to the model.
  factory RecordFolder.fromJson(Map<String, dynamic> json) =>
      _$RecordFolderFromJson(json);

  /// Converts the current model to a json object/map.
  Map<String, dynamic> toJson() => _$RecordFolderToJson(this);

  @override
  String getDisplayDescription() {
    if (day != null) {
      return "$day - ${DateTime(year, month!, day!).weekdayName()}";
    }

    if (month != null) {
      return "$month";
    }

    return "$year";
  }

  @override
  getIdentifier() {
    final m = month != null ? "-$month" : "";
    final d = day != null
        ? "-$day - ${DateTime(year, month!, day!).weekdayName()}"
        : "";
    return "$year$m$d";
  }

  @override
  Icon? getPrefixIcon(BuildContext context) {
    return const Icon(Icons.folder);
  }

  /// returns the [RecordFolder] converted from range of [startDate] and [endDate] or null if one date is not provided.
  static RecordFolder? fromDate(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return null;
    }

    if (startDate == endDate) {
      return RecordFolder(
          year: startDate.year, month: startDate.month, day: startDate.day);
    }

    if (startDate.month == endDate.month) {
      return RecordFolder(year: startDate.year, month: startDate.month);
    }

    return RecordFolder(year: startDate.year);
  }
}
