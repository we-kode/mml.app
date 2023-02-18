import 'package:json_annotation/json_annotation.dart';

part 'record_view_settings.g.dart';

/// Settings for displaying elements of one record.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class RecordViewSettings {
  /// True if should show genre.
  bool genre;

  /// True if should show album.
  bool album;

  /// True if should show language.
  bool language;

  /// True if should show tracknumber;
  bool tracknumber;

  RecordViewSettings({
    this.genre = true,
    this.album = true,
    this.language = true,
    this.tracknumber = true,
  });

  /// Converts a json object/map to the model.
  factory RecordViewSettings.fromJson(Map<String, dynamic> json) =>
      _$RecordViewSettingsFromJson(json);

  /// Converts the current model to a json object/map.
  Map<String, dynamic> toJson() => _$RecordViewSettingsToJson(this);
}
