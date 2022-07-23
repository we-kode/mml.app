import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';

part 'record.g.dart';

/// Record model that holds all information of a record.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Record extends ModelBase {
  /// Id of the client.
  final String? recordId;

  /// Title of the record.
  String? title;

  /// The date the record was created..
  DateTime? date;

  /// The duration of the record in milliseconds.
  double duration;

  /// The artists or null if no one provided.
  String? artist;

  /// Genre of the record or null if no one provided.
  String? genre;

  /// Album of the record or null if no one provided.
  String? album;

  /// Creates a new record instance with the given values.
  Record({
    required this.recordId,
    this.title,
    this.date,
    this.duration = 0,
    this.album,
    this.artist,
    this.genre,
  }) : super();

  /// Converts a json object/map to the record model.
  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);

  /// Converts the current record model to a json object/map.
  Map<String, dynamic> toJson() => _$RecordToJson(this);

  @override
  String getDisplayDescription() {
    return "$title";
  }

  @override
  dynamic getIdentifier() {
    return recordId;
  }

  @override
  String? getSubtitle(BuildContext context) {
    var locales = AppLocalizations.of(context)!;
    return artist ?? locales.unknown;
  }

  @override
  String? getTimeInfo(BuildContext context) {
    int seconds = ((duration / 1000) % 60).toInt();
    int minutes = ((duration / (1000 * 60)) % 60).toInt();
    int hours = ((duration / (1000 * 60 * 60)) % 24).toInt();
    return "${_valueString(hours)}:${_valueString(minutes)}:${_valueString(seconds)}";
  }

  @override
  String? getGroup(BuildContext context) {
    return DateFormat.yMd().format(date!);
  }

  /// Adds a 0 before [value] if [value] is smaller than ten.
  String _valueString(int value) {
    return value < 10 ? "0$value" : "$value";
  }
}
