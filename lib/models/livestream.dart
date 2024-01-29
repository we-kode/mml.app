import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/record.dart';

part 'livestream.g.dart';

/// Livestream model that holds all information of a livestream.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Livestream extends Record {
  /// Initializes the model.
  Livestream({
    required super.recordId,
    super.title,
  }) : super(checksum: '');

  /// Converts a json object/map to the model.
  factory Livestream.fromJson(Map<String, dynamic> json) =>
      _$LivestreamFromJson(json);

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

  @override
  Widget? getAvatar(BuildContext? context) {
    return null;
  }
}
