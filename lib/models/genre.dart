import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/model_base.dart';

part 'genre.g.dart';

/// Genre model that holds all informations of a record genre.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Genre extends ModelBase {
  /// Id of the genre.
  final String? genreId;

  /// Name of the genre.
  final String? name;

  /// Initializes the model.
  Genre({
    this.genreId,
    this.name,
    super.isDeletable,
  });

  /// Converts a json object/map to the model.
  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  /// Converts the current model to a json object/map.
  Map<String, dynamic> toJson() => _$GenreToJson(this);

  @override
  String getDisplayDescription() {
    return "$name";
  }

  @override
  getIdentifier() {
    return "$genreId";
  }
}
