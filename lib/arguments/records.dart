import 'package:mml_app/arguments/navigation_arguments.dart';
import 'package:mml_app/components/filter_app_bar.dart';

/// [NavigationArguments] for the Playlist overview.
class RecordsArguments extends NavigationArguments {

  /// Initializes the navigation arguments for the playlist overview.
  RecordsArguments({
    required FilterAppBar appBar,
  }) : super(appBar);
}
