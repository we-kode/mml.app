import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/constants/mml_media_constants.dart';
import 'package:mml_app/util/assets.dart';

class MMLMediaItemService {
  /// Instance of the [MMLMediaItemService].
  static final MMLMediaItemService _instance = MMLMediaItemService._();

  final Map<String, List<MediaItem>> _concreteItemsByParentId = {
    AudioService.browsableRootId: [
      // TODO: Art URIs & Localization
      const MediaItem(
        id: MMLMediaConstants.homeTabId,
        title: "Übersicht",
        playable: false,
      ),
      const MediaItem(
        id: MMLMediaConstants.favoritesTabId,
        title: "Favouriten",
        playable: false,
      ),
      const MediaItem(
        id: MMLMediaConstants.livestreamsTabId,
        title: "Live-Streams",
        playable: false,
      ),
      const MediaItem(
        id: MMLMediaConstants.browseTabId,
        title: "Stöbern",
        playable: false,
      ),
    ],
    MMLMediaConstants.homeTabId: [
      const MediaItem(
        id: MMLMediaConstants.newestRecordsGroupId,
        title: "Neueste",
        playable: false,
      ),
      const MediaItem(
        id: MMLMediaConstants.commonArtistsGroupId,
        title: "Häufige Interpreten",
        playable: false,
      ),
      const MediaItem(
        id: MMLMediaConstants.newestArtistsGroupId,
        title: "Neueste Interpreten",
        playable: false,
      ),
    ]
  };

  /// Private constructor of the service.
  MMLMediaItemService._();

  /// Returns the singleton instance of the [MMLMediaItemService].
  static MMLMediaItemService getInstance() {
    return _instance;
  }

  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    if (_concreteItemsByParentId.containsKey(parentMediaId)) {
      return Future.value(_concreteItemsByParentId[parentMediaId]);
    }

    switch (parentMediaId) {

      default:
        return [];
    }
  }
}
