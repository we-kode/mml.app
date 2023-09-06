import 'package:flutter/material.dart';
import 'package:mml_app/components/async_list_view.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/subfilter.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/view_models/livestreams/overview.dart';
import 'package:provider/provider.dart';

/// Overview screen of the livestreams of the music lib.
class LivestreamScreen extends StatelessWidget {
  /// App bar of the livestreams overview screen.
  final FilterAppBar? appBar;

  /// Initializes the instance.
  const LivestreamScreen({Key? key, this.appBar}) : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LivestreamsViewModel>(
      create: (context) => LivestreamsViewModel(),
      builder: (context, _) {
        var vm = Provider.of<LivestreamsViewModel>(context, listen: false);

        return FutureBuilder(
          future: vm.init(context),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return AsyncListView(
              title: vm.locales.livestreams,
              activeItem:
                  PlayerService.getInstance().playerState?.currentRecord,
              onActiveItemChanged:
                  PlayerService.getInstance().onRecordChanged.stream,
              loadData: vm.load,
              openItemFunction: (
                ModelBase item,
                String? filter,
                Subfilter? subfilter,
              ) {
                vm.playRecord(
                  context,
                  item,
                  filter,
                  null,
                );
              },
            );
          },
        );
      },
    );
  }
}
