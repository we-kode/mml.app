import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/extensions/duration_double.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/playlist.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';

part 'offline_record.g.dart';

/// Record model that holds all information of an offline record.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class OfflineRecord extends ModelBase {
  /// Id of the record.
  final String? recordId;

  /// Title of the record.
  String? title;

  // The name of the file which belongs to this record.
  String? file;

  /// The duration of the record in milliseconds.
  double duration;

  /// The artists or null if no one provided.
  String? artist;

  /// Genre of the record or null if no one provided.
  String? genre;

  /// Album of the record or null if no one provided.
  String? album;

  /// The playlist the record belongs to.
  Playlist? playlist;

  /// Creates a new record instance with the given values.
  OfflineRecord({
    required this.recordId,
    this.title,
    this.duration = 0,
    this.album,
    this.artist,
    this.genre,
    this.file,
    this.playlist,
    bool isDeletable = true,
  }) : super(isDeletable: isDeletable);

  /// Converts a json object/map to the record model.
  factory OfflineRecord.fromJson(Map<String, dynamic> json) =>
      _$OfflineRecordFromJson(json);

  /// Converts the current record model to a json object/map.
  Map<String, dynamic> toJson() => _$OfflineRecordToJson(this);

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
  String? getMetadata(BuildContext context) {
    return duration.asFormattedDuration();
  }

  @override
  String? getGroup(BuildContext context) {
    return "${playlist!.name}";
  }
}
