import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/model_base.dart';

part 'language.g.dart';

/// Language model that holds all informations of a record language.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Language extends ModelBase {
  /// Id of the language.
  final String? languageId;

  /// Name of the language.
  final String? name;

  /// Initializes the model.
  Language({
    this.languageId,
    this.name,
    bool isDeletable = false,
  }) : super(isDeletable: isDeletable);

  /// Converts a json object/map to the model.
  factory Language.fromJson(Map<String, dynamic> json) => _$LanguageFromJson(json);

  /// Converts the current model to a json object/map.
  Map<String, dynamic> toJson() => _$LanguageToJson(this);

  @override
  String getDisplayDescription() {
    return "$name";
  }

  @override
  getIdentifier() {
    return "$languageId";
  }
}
