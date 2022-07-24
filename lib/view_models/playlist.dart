import 'package:flutter/material.dart';
import 'package:mml_app/components/filter_app_bar.dart';

class PlaylistViewModel {
  /// Route of the plalist screen.
  static String route = '/playlist';

  static Widget routeArgs = const FilterAppBar(
    title: "playlist",
  );
}
