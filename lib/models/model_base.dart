import 'package:flutter/material.dart';

/// Base model with abstract methods that should be implemented by all models.
abstract class ModelBase {

  /// Creates a new instance of the model.
  ///
  /// Shouldn't be used directly but be invoked by constructor of implementing
  /// model classes.
  ModelBase();

  /// Returns a display description of the model object, that
  /// can be used in widgets, e.g. lists.
  String getDisplayDescription();

  /// Returns an additional text, which will be shown in the display description of the model object, that
  /// can be used in widgets, e.g. lists.
  String? getDisplayDescriptionSuffix(BuildContext context) {
    return null;
  }

  /// Returns the unique identifier of the model object.
  dynamic getIdentifier();

  /// Returns a subtitle of the model object or null if no subtitle was set.
  String? getSubtitle(BuildContext context) {
    return null;
  }

  /// Returns a time information like duration.
  String? getTimeInfo(BuildContext context) {
    return null;
  }

  /// Returns the group this item belongs to.
  String? getGroup(BuildContext context) {
    return null;
  }
}
