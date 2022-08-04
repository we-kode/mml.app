import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/view_models/main.dart';
import 'package:mml_app/view_models/records/overview.dart';
import 'package:provider/provider.dart';

/// Main screen.
class MainScreen extends StatelessWidget {
  /// Initializes the instance.
  const MainScreen({Key? key}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MainViewModel>(
      create: (context) => MainViewModel(),
      builder: (context, _) {
        var vm = Provider.of<MainViewModel>(context, listen: false);
        return FutureBuilder(
          future: vm.init(context),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return WillPopScope(
              onWillPop: () => vm.popNestedRoute(context),
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: Consumer<MainViewModel>(
                    builder: (context, vm, _) {
                      return vm.getAppBar();
                    },
                  ),
                ),
                body: SafeArea(
                  child: Navigator(
                    initialRoute: RecordsViewModel.route,
                    observers: [_NestedRouteObserver(vm: vm)],
                    onGenerateRoute: (settings) {
                      return RouterService.getInstance().getNestedRoutes(
                        arguments: settings.arguments,
                      )[settings.name];
                    },
                  ),
                ),
                bottomSheet: BottomSheet(
                  enableDrag: false,
                  builder: (context) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).bottomAppBarColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        boxShadow: kElevationToShadow[8],
                      ),
                      height: 150,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 25,
                          right: 25,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.close,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Titel",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  "Author",
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                Text(
                                  "0:00/0:00",
                                  textAlign: TextAlign.right,
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Slider(
                                    value: 0,
                                    onChanged: (value) {},
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  icon: Icon(Icons.skip_previous_rounded),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 32,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  icon: Icon(Icons.skip_next_rounded),
                                ),
                                Spacer(),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.repeat,
                                    size: 16,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.shuffle_rounded,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                        ),
                      ),
                    );
                  },
                  onClosing: () {},
                ),
                bottomNavigationBar: Consumer<MainViewModel>(
                  builder: (context, vm, _) {
                    return BottomNavigationBar(
                      backgroundColor: Theme.of(context).bottomAppBarColor,
                      showUnselectedLabels: false,
                      showSelectedLabels: false,
                      currentIndex: vm.selectedIndex,
                      onTap: (index) {
                        if (index == vm.selectedIndex) {
                          return;
                        }
                        vm.loadPage(index);
                      },
                      items: vm.navItems,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Route observer used to pop routes in the nested navigator.
class _NestedRouteObserver extends RouteObserver<PageRoute> {
  /// Main viewmodel used to update the selected index.
  MainViewModel vm;

  /// Intializes the observer.
  _NestedRouteObserver({required this.vm});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    vm.selectedIndex = getSelectedIndex(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    vm.selectedIndex = getSelectedIndex(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    vm.selectedIndex = getSelectedIndex(previousRoute);
  }

  /// Returns the selected index for the bottom navigation bar based on the
  /// passed [route] index in the nested route list.
  int getSelectedIndex(Route? route) {
    return RouterService.getInstance()
        .getNestedRoutes()
        .keys
        .toList()
        .indexOf(
          route?.settings.name ?? "",
        )
        .clamp(
          0,
          vm.navItems.length - 1,
        );
  }
}
