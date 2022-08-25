import 'package:flutter/material.dart';
import 'package:mml_app/components/progress_indicator.dart';
import 'package:mml_app/models/playlist.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/router.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:sqflite/sqflite.dart';

/// ViewModel of the create/edit dialog for playlists.
class PlaylistEditDialogViewModel extends ChangeNotifier {
  /// [DBService] that handles the requests to the database.
  final DBService _service = DBService.getInstance();

  /// Key of the user edit form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Name of name field in the errors response.
  final String nameField = 'Name';

  /// Current build context.
  late BuildContext _context;

  /// Playlist model for creationd or modification.
  late Playlist playlist;

  /// Locales of the application.
  late AppLocalizations locales;

  /// Flag that indicates whether the playlist is successful loaded.
  bool playlistLoadedSuccessfully = false;

  /// Map of errors from the database.
  Map<String, List<String>> errors = {};

  /// Initializes the ViewModel and loads the user with the given [playlistId] or
  /// creates an new playlist model if the id is not passed.
  Future<bool> init(BuildContext context, int? playlistId) async {
    locales = AppLocalizations.of(context)!;
    _context = context;

    if (playlistId == null) {
      return Future.microtask(() {
        playlist = Playlist();
        playlistLoadedSuccessfully = true;
        notifyListeners();
        return true;
      });
    }

    var nav = Navigator.of(_context);
    playlist = await _service.getPlaylist(playlistId);
    if (playlist.id == null) {
      var messenger = MessengerService.getInstance();
      messenger.showMessage(messenger.notFound);
      nav.pop(true);
      return false;
    }
    playlistLoadedSuccessfully = true;
    notifyListeners();

    return true;
  }

  /// Validates the given [name] and returns an error message or null if
  /// the name is valid.
  String? validateName(String? name) {
    var error = (name ?? '').isNotEmpty ? null : locales.invalidDisplayName;
    return _addBackendErrors(nameField, error);
  }

  /// Clears the errors from the backend for the field with the passed
  /// [fieldName].
  clearBackendErrors(String fieldName) {
    errors.remove(fieldName);
  }

  /// Saves (creates or updates) the playlist and closes the playlist dialog on success.
  void savePlaylist() async {
    var nav = Navigator.of(_context);

    showProgressIndicator();

    if (!playlistLoadedSuccessfully || !formKey.currentState!.validate()) {
      RouterService.getInstance().navigatorKey.currentState!.pop();
      return;
    }

    formKey.currentState!.save();

    var shouldClose = false;

    try {
      await (playlist.id != null
          ? _service.updatePlaylist(playlist)
          : _service.createPlaylist(playlist));
      shouldClose = true;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        errors = Map.from({
          nameField: List<String>.from([locales.playlistUniqueConstraintFailed])
        });
        formKey.currentState!.validate();
      }
    } finally {
      RouterService.getInstance().navigatorKey.currentState!.pop();

      if (shouldClose) {
        nav.pop(true);
      }
    }
  }

  /// Adds errors from backend for passed [fieldName] to the [error] string
  /// divided by new lines and returns the extended error string.
  String? _addBackendErrors(String fieldName, String? error) {
    if (errors.containsKey(fieldName) && errors[fieldName]!.isNotEmpty) {
      error = (error != null ? '$error\n' : '');
      error += errors[fieldName]!.join("\n");
    }

    return error;
  }
}
