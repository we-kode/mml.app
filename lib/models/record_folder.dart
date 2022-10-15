import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/model_base.dart';

part 'record_folder.g.dart';

/// Playlist model that holds all informations of a playlist.
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
      return "$day";
    }

    if (month != null) {
      return "$month";
    }

    return "$year";
  }

  @override
  getIdentifier() {
    final m = month != null ? "-$month" : "";
    final d = day != null ? "-$day" : "";
    return "$year$m$d";
  }

  @override
  Icon? getPrefixIcon(BuildContext context) {
    return const Icon(Icons.folder);
  }
}
