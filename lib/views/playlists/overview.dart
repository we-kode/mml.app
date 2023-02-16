import 'package:flutter/material.dart';
import 'package:mml_app/components/async_list_view.dart';
import 'package:mml_app/components/delete_dialog.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/playlist.dart';
import 'package:mml_app/models/subfilter.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/view_models/playlists/overview.dart';
import 'package:mml_app/view_models/playlists/states.dart';
import 'package:mml_app/views/playlists/edit.dart';
import 'package:provider/provider.dart';

/// Overview screen of the playlists of the music lib.
class PlaylistScreen extends StatelessWidget {
  /// App bar of the playlist overview screen.
  final FilterAppBar? appBar;

  /// Id of actual playlist
  final int? playlistId;

  /// Initializes the instance.
  const PlaylistScreen({Key? key, this.appBar, this.playlistId})
      : super(key: key);

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlaylistViewModel>(
      create: (context) => PlaylistViewModel(),
      builder: (context, _) {
        var vm = Provider.of<PlaylistViewModel>(context, listen: false);

        return FutureBuilder(
          future: vm.init(context, playlistId),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return AsyncListView(
              title: vm.locales.playlist,
              selectedItemsAction: appBar?.listAction,
              filter: appBar?.filter,
              activeItem: PlayerService.getInstance().playerState?.currentReocrd,
              onActiveItemChanged: PlayerService.getInstance().onRecordChanged.stream,
              onMultiSelect: (selectedItems) async {
                var shouldDelete = await showDeleteDialog(context);

                if (shouldDelete) {
                  await vm.deleteRecords(selectedItems as List<ModelBase?>);
                }

                return shouldDelete;
              },
              loadData: vm.load,
              addItem: playlistId != null
                  ? null
                  : () async {
                      final state = await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return const PlaylistEditDialog(playlistId: null);
                        },
                      );
                      return state == EditState.save;
                    },
              editGroupFunction: (item) async {
                var playlistId = (item as Playlist).id;
                final state = await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return PlaylistEditDialog(
                      playlistId: playlistId,
                    );
                  },
                );

                if (state == EditState.delete && playlistId != null) {
                  await vm.deletePlaylist(playlistId);
                }

                return state == EditState.save || state == EditState.delete;
              },
              openItemFunction: (
                ModelBase item,
                String? filter,
                Subfilter? subfilter,
              ) {
                if (item is LocalRecord) {
                  vm.playRecord(
                    context,
                    item,
                    filter,
                    null,
                  );
                } else if (item is Playlist) {
                  vm.navigate(item);
                }
              },
            );
          },
        );
      },
    );
  }
}
