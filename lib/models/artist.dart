import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/model_base.dart';

part 'artist.g.dart';

/// Artist model that holds all informations of a record artist.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Artist extends ModelBase {
  /// Id of the artist.
  final String? artistId;

  /// Name of the artist.
  final String? name;

  /// Initializes the model.
  Artist({
    this.artistId,
    this.name,
    super.isDeletable,
  });

  /// Converts a json object/map to the model.
  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  /// Converts the current model to a json object/map.
  Map<String, dynamic> toJson() => _$ArtistToJson(this);

  @override
  String getDisplayDescription() {
    return "$name";
  }

  @override
  getIdentifier() {
    return "$artistId";
  }
}
