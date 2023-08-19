import 'package:flutter/material.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/services/livestreams.dart';

class LivestreamsViewModel extends ChangeNotifier {
  /// Route of the plalist screen.
  static String route = '/livestreams';

  /// App locales.
  late AppLocalizations locales;

  /// [LivestreamService] used to load data for the livestream overview.
  final LivestreamService _service = LivestreamService.getInstance();

 /// Initializes the view model.
  Future<bool> init(BuildContext context) {
    return Future.microtask(() async {
      locales = AppLocalizations.of(context)!;
      return true;
    });
  }

  /// Loads the streams with the passing [filter] starting at [offset] and loading
  /// [take] data.
  Future<ModelList> load({
    String? filter,
    int? offset,
    int? take,
    dynamic subfilter,
  }) async {
    return _service.get(
      filter,
      offset,
      take,
    );
  }

  /// Plays one stream.
  Future<void> playRecord(
    BuildContext context,
    ModelBase record,
    String? filter,
    ID3TagFilter? subfilter,
  ) async {
    // TODO
    // await PlayerService.getInstance().play(
    //   context,
    //   record as Record,
    //   filter,
    //   subfilter,
    // );
  }

}