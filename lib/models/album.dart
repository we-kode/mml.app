import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/model_base.dart';

part 'album.g.dart';

/// Album model that holds all informations of a record album.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Album extends ModelBase {
  /// Id of the album.
  final String? albumId;

  /// Name of the album.
  final String? albumName;

  /// Initializes the model.
  Album({
    this.albumId,
    this.albumName,
    super.isDeletable,
  });

  /// Converts a json object/map to the model.
  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  /// Converts the current model to a json object/map.
  Map<String, dynamic> toJson() => _$AlbumToJson(this);

  @override
  String getDisplayDescription() {
    return "$albumName";
  }

  @override
  getIdentifier() {
    return "$albumId";
  }
}
