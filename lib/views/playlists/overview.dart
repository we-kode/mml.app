import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mml_app/components/async_list_view.dart';
import 'package:mml_app/components/delete_dialog.dart';
import 'package:mml_app/components/expandable_fab.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/action_export.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/playlist.dart';
import 'package:mml_app/models/subfilter.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/view_models/playlists/overview.dart';
import 'package:mml_app/view_models/playlists/states.dart';
import 'package:mml_app/views/playlists/edit.dart';
import 'package:mml_app/views/playlists/not_downloaded.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

/// Overview screen of the playlists of the music lib.
class PlaylistScreen extends StatelessWidget {
  /// App bar of the playlist overview screen.
  final FilterAppBar? appBar;

  /// Id of actual playlist
  final int? playlistId;

  /// Initializes the instance.
  const PlaylistScreen({super.key, this.appBar, this.playlistId});

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
              exportAction: appBar?.exportAction,
              filter: appBar?.filter,
              showAddButton: true,
              subactions: playlistId != null
                  ? null
                  : [
                      ActionButton(
                        icon: const Icon(Icons.upload),
                        onPressed: () async {
                          FilePickerResult? selected =
                              await FilePicker.platform.pickFiles(
                            type:
                                Platform.isIOS ? FileType.any : FileType.custom,
                            allowedExtensions: Platform.isIOS ? null : ['mml'],
                          );

                          if (selected == null) {
                            return;
                          }

                          var notDownloaded =
                              await vm.import(selected.files.first);

                          if (notDownloaded.isEmpty) {
                            return;
                          }

                          final state = await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return NotDownloadedDialog(
                                records: notDownloaded,
                              );
                            },
                          );
                          if (state == EditState.save) {
                            vm.update();
                          }
                        },
                      ),
                      ActionButton(
                        icon: const Icon(Icons.create_new_folder_outlined),
                        onPressed: () async {
                          final state = await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return const PlaylistEditDialog(playlistId: null);
                            },
                          );
                          if (state == EditState.save) {
                            vm.update();
                          }
                        },
                      ),
                    ],
              activeItem:
                  PlayerService.getInstance().playerState?.currentRecord,
              onActiveItemChanged:
                  PlayerService.getInstance().onRecordChanged.stream,
              onMultiSelect: (actionId, selectedItems) async {
                if (actionId == ExportAction.actionId) {
                  vm.exportRecords(selectedItems as List<ModelBase?>);
                  return true;
                } else {
                  var shouldDelete = await showDeleteDialog(context);

                  if (shouldDelete) {
                    await vm.deleteRecords(selectedItems as List<ModelBase?>);
                  }

                  return shouldDelete;
                }
              },
              loadData: vm.load,
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
