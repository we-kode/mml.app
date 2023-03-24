import 'package:mml_app/arguments/navigation_arguments.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/info.dart';

/// [NavigationArguments] for the notes view.
class NotesArguments extends NavigationArguments {
  /// The [Info] which is associated with the actual route of the notes view.
  final Info? info;

  /// Initializes the navigation arguments for the notes overview.
  NotesArguments({
    required FilterAppBar appBar,
    this.info,
  }) : super(appBar);
}
