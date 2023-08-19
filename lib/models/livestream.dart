import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/model_base.dart';

part 'livestream.g.dart';

/// Livestream model that holds all information of a livestream.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Livestream extends ModelBase {
  /// Id of the livestream.
  final String? livestreamId;

  /// Name to be displayed.
  String? displayName;

  /// Initializes the model.
  Livestream({
    this.livestreamId,
    this.displayName,
    bool isDeletable = true,
  }) : super(isDeletable: isDeletable);

  /// Converts a json object/map to the model.
  factory Livestream.fromJson(Map<String, dynamic> json) =>
      _$LivestreamFromJson(json);

  /// Converts the current record model to a json object/map.
  Map<String, dynamic> toJson() => _$LivestreamToJson(this);

  @override
  String getDisplayDescription() {
    return displayName ?? "";
  }

  @override
  getIdentifier() {
    return livestreamId ?? "";
  }
}
