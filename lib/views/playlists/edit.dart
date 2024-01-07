import 'package:flutter/material.dart';
import 'package:mml_app/view_models/playlists/edit.dart';
import 'package:mml_app/view_models/playlists/states.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';

/// View of the create/edit dialog for playlists.
class PlaylistEditDialog extends StatelessWidget {
  /// Id of the playlist to edit or null if a new playlist should be created.
  final int? playlistId;

  /// Initializes the view for the playlist create/edit dialog.
  const PlaylistEditDialog({
    super.key,
    required this.playlistId,
  });

  /// Builds the user create/edit dialog.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlaylistEditDialogViewModel>(
      create: (context) => PlaylistEditDialogViewModel(),
      builder: (context, _) {
        var vm = Provider.of<PlaylistEditDialogViewModel>(
          context,
          listen: false,
        );
        var locales = AppLocalizations.of(context)!;

        return AlertDialog(
          title: Text(
            playlistId != null ? locales.editPlaylist : locales.addPlaylist,
          ),
          content: FutureBuilder(
            future: vm.init(context, playlistId),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                  ],
                );
              }

              return snapshot.data!
                  ? _createEditForm(context, vm)
                  : Container();
            },
          ),
          actions: _createActions(context, vm),
        );
      },
    );
  }

  /// Creates the edit form that should be shown in the dialog.
  Widget _createEditForm(BuildContext context, PlaylistEditDialogViewModel vm) {
    return Form(
      key: vm.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<PlaylistEditDialogViewModel>(
            builder: (context, value, child) {
              return TextFormField(
                initialValue: vm.playlist.name,
                decoration: InputDecoration(
                  labelText: vm.locales.playlist,
                  errorMaxLines: 5,
                ),
                onSaved: (String? name) {
                  vm.clearBackendErrors(vm.nameField);
                  vm.playlist.name = name;
                },
                onChanged: (String? name) {
                  vm.clearBackendErrors(vm.nameField);
                  vm.playlist.name = name;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: vm.validateName,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Creates a list of action widgets that should be shown at the bottom of the
  /// edit dialog.
  List<Widget> _createActions(
    BuildContext context,
    PlaylistEditDialogViewModel vm,
  ) {
    var locales = AppLocalizations.of(context)!;

    return [
      if (playlistId != null)
        Consumer<PlaylistEditDialogViewModel>(
          builder: (context, value, child) {
            return TextButton(
              onPressed: value.playlistLoadedSuccessfully
                  ? () => Navigator.pop(context, EditState.delete)
                  : null,
              child: Text(
                locales.remove,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          },
        ),
      TextButton(
        onPressed: () => Navigator.pop(context, EditState.cancel),
        child: Text(locales.cancel),
      ),
      Consumer<PlaylistEditDialogViewModel>(
        builder: (context, value, child) {
          return TextButton(
            onPressed:
                value.playlistLoadedSuccessfully ? vm.savePlaylist : null,
            child: Text(locales.save),
          );
        },
      ),
    ];
  }
}
