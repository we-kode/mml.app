import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:path/path.dart';

part 'info.g.dart';

/// Info model that holds all informations of an info.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Info extends ModelBase {
  /// Path of the info.
  final String? path;

  /// Name of the dircetory or file, without path.
  final String? name;

  /// True, if actual item is a folder.
  final bool? isFolder;

  /// Initializes the model.
  Info({
    this.path,
    this.name,
    this.isFolder,
    bool isDeletable = false,
  }) : super(isDeletable: isDeletable);

  /// Converts a json object/map to the model.
  factory Info.fromJson(Map<String, dynamic> json) =>
      _$InfoFromJson(json);

  /// Converts the current model to a json object/map.
  Map<String, dynamic> toJson() => _$InfoToJson(this);

  @override
  String getDisplayDescription() {
    return basenameWithoutExtension(name ?? "");
  }

  @override
  getIdentifier() {
    return "$path";
  }

  @override
  Icon? getPrefixIcon(BuildContext context) {
    return Icon((isFolder ?? false) ? Icons.snippet_folder : Icons.description);
  }
}
