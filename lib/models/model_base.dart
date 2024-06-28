import 'dart:io';

import 'package:cached_memory_image/cached_image_base64_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Base model with abstract methods that should be implemented by all models.
abstract class ModelBase {
  static const platform = MethodChannel("de.wekode.mml");

  /// Indicates whether the model object is deletable.
  late bool? isDeletable;

  /// Indicates whether the model object is selectable.
  late bool? isSelectable;

  /// Creates a new instance of the model.
  ///
  /// Shouldn't be used directly but be invoked by constructor of implementing
  /// model classes.
  ModelBase({
    this.isDeletable = false,
    this.isSelectable = true,
  });

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

  /// Returns meta data information, e.g. duration.
  String? getMetadata(BuildContext context) {
    return null;
  }

  /// Returns meta data information, e.g. genre or language.
  String? getSubMetadata(BuildContext context) {
    return null;
  }

  /// Returns the group this item belongs to.
  String? getGroup(BuildContext context) {
    return null;
  }

  /// Returns an icon which can be used as prefix in list.
  Icon? getPrefixIcon(BuildContext context) {
    return null;
  }

  /// Returns the avatar as base64 string to be shown in list.
  String? getAvatarString() {
    return null;
  }

  /// Returns the avatar to be shown in list.
  Widget? getAvatar(BuildContext? context) {
    return null;
  }

  /// Returns the avatar uri.
  Future<Uri?> getAvatarUri() async {
    if (Platform.isAndroid &&
        getAvatarString() != null &&
        getAvatarString()!.isNotEmpty &&
        getIdentifier() != null &&
        getIdentifier()!.isNotEmpty) {
      var file = await CachedImageBase64Manager.instance().cacheFile(
        getIdentifier()!,
      );

      if (file?.existsSync() ?? false) {
        var uri = Uri.parse(await platform.invokeMethod("mapUri", file!.path));
        return uri;
      }

      file = await CachedImageBase64Manager.instance().cacheBase64(
        getIdentifier()!,
        getAvatarString()!,
      );

      var uri = Uri.parse(await platform.invokeMethod("mapUri", file.path));
      return uri;
    }

    return null;
  }
}
