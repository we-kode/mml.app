import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/model_base.dart';

part 'playlist.g.dart';

/// Playlist model that holds all informations of a playlist.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Playlist extends ModelBase {
  /// Id of the playlist.
  final int? id;

  /// Name of the playlist.
  String? name;

  /// Initializes the model.
  Playlist({
    this.id,
    this.name,
    bool isDeletable = true,
  }) : super(isDeletable: isDeletable);

  /// Converts a json object/map to the model.
  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  /// Converts the current model to a json object/map.
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);

  @override
  String getDisplayDescription() {
    return "$name";
  }

  @override
  getIdentifier() {
    return "$id";
  }

  @override
  Icon? getPrefixIcon(BuildContext context) {
    return const Icon(Icons.folder_special);
  }

  /// Converts a map of the model for inserting into db.
  Map<String, Object?> toMap() {
    var map = toJson();
    map.remove('isDeletable');
    return map;
  }
}
