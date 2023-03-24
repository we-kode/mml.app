import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/arguments/notes.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/models/info.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/services/notes.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/view_models/notes/note.dart';

/// View model of the notes view.
class NotesViewModel extends ChangeNotifier {
  /// Route of the information screen.
  static String route = '/notes';

  /// App locales.
  late AppLocalizations locales;

   /// Actual selected directory.
  String? directory;

  /// [NotesService] used to load data.
  final NotesService _service = NotesService.getInstance();

  /// Initialize the view model.
  Future<bool> init(BuildContext context, String? path) async {
    return Future<bool>.microtask(() async {
      locales = AppLocalizations.of(context)!;
      directory = path;
      return true;
    });
  }

   /// Loads the items with the passing [filter] starting at [offset] and loading
  /// [take] data.
  Future<ModelList> load({
    String? filter,
    int? offset,
    int? take,
    dynamic subfilter,
  }) async {
    return _service.list(directory, offset, take);
  }

  /// navigates to folder of [info].
  void navigate(Info item) async {
    var routerService = RouterService.getInstance();
    await routerService.pushNestedRoute(
      (item.isFolder ?? false) ? route : NoteViewModel.route,
      arguments: NotesArguments(
        appBar: FilterAppBar(
          title: item.path ?? "",
        ),
        info: item,
      ),
    );
  }
}
