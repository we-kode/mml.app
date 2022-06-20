import 'package:flutter/material.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/view_models/main.dart';
import 'package:mml_app/view_models/records.dart';
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

            return Scaffold(
              appBar: AppBar(
                title: Consumer<MainViewModel>(
                  builder: (context, vm, _) {
                    return Text(vm.navItems.elementAt(vm.selectedIndex).label!);
                  },
                ),
              ),
              body: SafeArea(
                child: Navigator(
                  initialRoute: RecordsViewModel.route,
                  onGenerateRoute: (settings) {
                    return RouterService.getInstance()
                        .nestedRoutes[settings.name];
                  },
                ),
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
                      vm.selectedIndex = index;
                    },
                    items: vm.navItems,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
