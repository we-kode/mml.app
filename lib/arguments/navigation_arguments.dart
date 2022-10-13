import 'package:mml_app/components/filter_app_bar.dart';

/// Navigation arguments for the route navigation.
class NavigationArguments {
  /// The [FilterAppBar] of the actual route.
  final FilterAppBar appBar;

  /// Initializes the [NavigationArguments].
  NavigationArguments(this.appBar);
}
