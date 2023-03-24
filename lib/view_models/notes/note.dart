import 'package:flutter/material.dart';
import 'package:mml_app/services/notes.dart';

/// View model of the note view.
class NoteViewModel extends ChangeNotifier {
  /// Route of the note screen.
  static String route = '/note';

  /// The content of the note.
  String data = '';

  /// Initialize the view model.
  Future<bool> init(BuildContext context, String path) async {
    return Future<bool>.microtask(() async {
      data = await NotesService.getInstance().loadContent(path);
      return true;
    });
  }
}
