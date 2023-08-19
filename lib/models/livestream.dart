import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/record.dart';

part 'livestream.g.dart';

/// Livestream model that holds all information of a livestream.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Livestream extends Record {
  /// Id of the livestream.
  final String? livestreamId;

  /// Name to be displayed.
  String? displayName;

  /// Initializes the model.
  Livestream({
    this.livestreamId,
    this.displayName,
  }) : super(recordId: livestreamId, checksum: '', title: displayName);

  /// Converts a json object/map to the model.
  factory Livestream.fromJson(Map<String, dynamic> json) =>
      _$LivestreamFromJson(json);

  @override
  String getDisplayDescription() {
    return displayName ?? "";
  }

  @override
  getIdentifier() {
    return livestreamId ?? "";
  }

  @override
  String? getSubtitle(BuildContext context) {
    return null;
  }

  @override
  String? getMetadata(BuildContext context) {
    return null;
  }

  @override
  String? getSubMetadata(BuildContext context) {
    return null;
  }

  @override
  String? getGroup(BuildContext context) {
    return null;
  }
}
