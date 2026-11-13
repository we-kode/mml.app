import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:mml_app/components/progress_indicator.dart';
import 'package:mml_app/components/share_options_dialog.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/models/record_folder.dart';
import 'package:mml_app/models/share_action.dart';
import 'package:mml_app/models/share_check.dart';
import 'package:mml_app/models/share_options.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/services/share.dart';
import 'package:share_plus/share_plus.dart';

/// Checks which of the selected records the user may share and shares them as
/// download link.
class RecordShareSelection {
  /// Service to check and create download links.
  final ShareService _shareService = ShareService.getInstance();

  /// Revision of the latest check, which of the selected records can be shared.
  int _selectionRevision = 0;

  /// Result of the latest check, which of the selected records can be shared.
  ShareCheck? _shareCheck;

  /// Timer, that waits for further changes of the selection before checking.
  Timer? _checkTimer;

  /// Known results of the check per record id. Valid as long as the selection
  /// is active.
  final Map<String, bool> _shareableRecords = {};

  /// Known results of the check per folder identifier. Valid as long as the
  /// selection is active.
  final Map<String, ShareCheck> _checkedFolders = {};

  /// Request, that loads the rights to share records, when the first item of a
  /// selection is selected.
  Future<void>? _rightsRefresh;

  /// Stops a pending check.
  void dispose() {
    _checkTimer?.cancel();
  }

  /// Checks which of the [selected] items the user may share and shows the
  /// share action of the [action] accordingly. Checks wait until the selection
  /// is not changed for a moment and only ask the server for items which are
  /// not known yet. The rights to share are loaded once, when the first item is
  /// selected.
  void selectionChanged(List<ModelBase> selected, ShareAction? action) {
    _checkTimer?.cancel();
    if (selected.isEmpty) {
      _rightsRefresh = null;
      _selectionRevision++;
      _shareableRecords.clear();
      _checkedFolders.clear();
      _shareCheck = null;
      action?.visible = false;
      return;
    }

    _rightsRefresh ??= _shareService.refresh();
    _checkTimer = Timer(
      const Duration(milliseconds: 400),
      () => _check(selected, action),
    );
  }

  Future<void> _check(List<ModelBase> selected, ShareAction? action) async {
    final revision = ++_selectionRevision;
    await _rightsRefresh;
    if (!await _shareService.canShare()) {
      action?.visible = false;
      return;
    }

    final records = selected.whereType<Record>().map((e) => e.recordId!);
    final folders = selected.whereType<RecordFolder>();
    var limit = ShareCheck.defaultLimit;
    try {
      final unknown = records.where((id) => !_shareableRecords.containsKey(id));
      if (unknown.isNotEmpty) {
        final result = await _shareService.check(unknown.toList(), []);
        limit = result.limit;
        for (final id in unknown) {
          _shareableRecords[id] = result.shareableRecords.contains(id);
        }
      }

      for (final folder in folders) {
        if (!_checkedFolders.containsKey(folder.getIdentifier())) {
          _checkedFolders[folder.getIdentifier()] = await _shareService.check(
            [],
            [folder],
          );
        }
      }
    } catch (_) {
      // Without a result the records can not be shared.
      if (revision == _selectionRevision) {
        _shareCheck = null;
        action?.visible = false;
      }
      return;
    }

    if (revision != _selectionRevision) {
      return;
    }

    final checkedFolders = folders.map(
      (e) => _checkedFolders[e.getIdentifier()]!,
    );
    _shareCheck = ShareCheck(
      shareable:
          records.where((id) => _shareableRecords[id] ?? false).length +
          checkedFolders.fold(0, (sum, e) => sum + e.shareable),
      total: records.length + checkedFolders.fold(0, (sum, e) => sum + e.total),
      limit: checkedFolders.isEmpty ? limit : checkedFolders.first.limit,
    );
    action?.visible = _shareCheck!.shareable > 0;
  }

  /// Shares a download link of the [selected] items after the user confirmed
  /// to share only the records they may share. Returns whether the selection
  /// should be reset.
  Future<bool> share(List<ModelBase?> selected, BuildContext context) async {
    final check = _shareCheck;
    if (check == null || check.shareable == 0) {
      return false;
    }

    if (check.isTooLarge) {
      final messenger = MessengerService.getInstance();
      messenger.showMessage(messenger.shareTooMany(check.limit));
      return false;
    }

    if (check.isPartial && !await _confirmPartial(context, check)) {
      return false;
    }

    ShareOptions? options;
    if (await _shareService.userChoosesOptions()) {
      options = await _shareService.loadDefaults();
      if (!await _shareService.useDefaults()) {
        if (!context.mounted) {
          return false;
        }

        final result = await showDialog<(ShareOptions, bool)>(
          context: context,
          builder: (context) => ShareOptionsDialog(options: options!),
        );
        if (result == null) {
          return false;
        }

        options = result.$1;
        if (result.$2) {
          await _shareService.saveDefaults(options, true);
        }
      }
    }

    showProgressIndicator();
    Uri? url;
    try {
      url = await _shareService.create(
        selected.whereType<Record>().map((e) => e.recordId!).toList(),
        selected.whereType<RecordFolder>().toList(),
        options,
      );
    } catch (_) {
      // Errors are shown by the api service.
    } finally {
      RouterService.getInstance().navigatorKey.currentState!.pop();
    }

    if (url == null || !context.mounted) {
      return false;
    }

    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        uri: url,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
    return true;
  }

  Future<bool> _confirmPartial(BuildContext context, ShareCheck check) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final locales = AppLocalizations.of(context)!;

        return AlertDialog(
          title: Text(locales.shareDownloadLink),
          content: Text(locales.sharePartial(check.shareable, check.total)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(locales.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(locales.share),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
