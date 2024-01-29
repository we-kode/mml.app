import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/extensions/datetime.dart';
import 'package:mml_app/extensions/duration_double.dart';
import 'package:mml_app/extensions/flag.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/models/record_view_settings.dart';

part 'record.g.dart';

/// Record model that holds all information of a record.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Record extends ModelBase {
  /// Id of the client.
  final String? recordId;

  /// Title of the record.
  String? title;

  /// Track number of the record.
  int? trackNumber;

  /// The date the record was created..
  DateTime? date;

  /// The duration of the record in milliseconds.
  double? duration;

  /// The artists or null if no one provided.
  String? artist;

  /// Genre of the record or null if no one provided.
  String? genre;

  /// Album of the record or null if no one provided.
  String? album;

  /// Language of the record or null if no one provided.
  String? language;

  /// Checksum of the record data.
  String? checksum;

  /// The cover image of the record.
  String? cover;

  RecordViewSettings? _viewSettings;

  /// Creates a new record instance with the given values.
  Record({
    required this.recordId,
    required this.checksum,
    this.title,
    this.trackNumber,
    this.date,
    this.duration = 0,
    this.album,
    this.artist,
    this.genre,
    this.language,
    this.cover,
    super.isDeletable,
  });

  /// Converts a json object/map to the record model.
  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);

  set viewSettings(RecordViewSettings viewSettings) {
    _viewSettings = viewSettings;
  }

  /// Converts the current record model to a json object/map.
  Map<String, dynamic> toJson() => _$RecordToJson(this);

  @override
  String getDisplayDescription() {
    final tn = _viewSettings != null &&
            _viewSettings!.tracknumber &&
            trackNumber != null
        ? '$trackNumber - '
        : '';
    return "$tn$title";
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
    return duration?.asFormattedDuration();
  }

  @override
  String? getSubMetadata(BuildContext context) {
    if (_viewSettings == null) {
      return null;
    }
    var g = _viewSettings!.genre && genre != null ? genre : '';

    var lang = '';
    if (_viewSettings!.language && language != null) {
      lang = "${language?.asFlag().join(' ')}";
    }

    return "$g${lang.isEmpty ? '' : ' '}$lang";
  }

  @override
  Widget? getAvatar(BuildContext? context) {
    if (_viewSettings == null || !_viewSettings!.cover) {
      return null;
    }
    
    if (cover != null && cover!.isNotEmpty) {
      return Image.memory(
        Uint8List.fromList(
          base64.decode(cover!),
        ),
        gaplessPlayback: true,
      );
    }
    return const Icon(Icons.music_note_outlined);
  }

  @override
  String? getGroup(BuildContext context) {
    return '${DateFormat.yMd().format(date ?? DateTime.now())} - ${(date ?? DateTime.now()).weekdayName()}';
  }
}
