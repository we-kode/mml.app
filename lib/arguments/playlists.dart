import 'package:mml_app/arguments/navigation_arguments.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/playlist.dart';

/// [NavigationArguments] for the Playlist overview.
class PlaylistArguments extends NavigationArguments {
  /// The playlist which is associated with the actual route of the playlist view.
  final Playlist? playlist;

  /// Initializes the navigation arguments for the playlist overview.
  PlaylistArguments({
    required FilterAppBar appBar,
    this.playlist,
  }) : super(appBar);
}
