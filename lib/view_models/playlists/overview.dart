import 'package:flutter/material.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/services/db.dart';

/// View model of the playlist view.
class PlaylistViewModel extends ChangeNotifier {
  /// Route of the plalist screen.
  static String route = '/playlist';

  /// The [FilterAppBar] of the playlist view.
  static FilterAppBar appBar = FilterAppBar(
    title: 'playlist',
  );

  /// [RecordService] used to load data for the records uplaod dialog.
  final DBService _service = DBService.getInstance();

   /// App locales.
  late AppLocalizations locales;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) {
    return Future.microtask(() {
      locales = AppLocalizations.of(context)!;

      return true;
    });
  }

  /// Loads the records with the passing [filter] starting at [offset] and loading
  /// [take] data.
  Future<ModelList> load({
    String? filter,
    int? offset,
    int? take,
    dynamic subfilter,
  }) async {
    return _service.load(filter, offset, take);
  }
}
