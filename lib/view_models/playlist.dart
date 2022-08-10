import 'package:mml_app/components/filter_app_bar.dart';

/// View model of the playlist view.
class PlaylistViewModel {
  /// Route of the plalist screen.
  static String route = '/playlist';

  /// The [FilterAppBar] of the playlist view.
  static FilterAppBar appBar = FilterAppBar(
    title: 'playlist',
  );
}
