import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mml_app/components/delete_dialog.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/share_link_info.dart';
import 'package:mml_app/services/share.dart';

/// Dialog that lists the active download links of the user and deletes them.
class ShareLinksDialog extends StatefulWidget {
  /// Initializes the dialog.
  const ShareLinksDialog({super.key});

  @override
  State<ShareLinksDialog> createState() => _ShareLinksDialogState();
}

class _ShareLinksDialogState extends State<ShareLinksDialog> {
  final ShareService _service = ShareService.getInstance();

  late final Future<List<ShareLinkInfo>> _loaded = _load();

  List<ShareLinkInfo>? _links;

  Future<List<ShareLinkInfo>> _load() async {
    try {
      return _links = await _service.getLinks();
    } catch (_) {
      // Errors are shown by the api service.
      return _links = [];
    }
  }

  Future<void> _delete(ShareLinkInfo link) async {
    final message = AppLocalizations.of(context)!.shareLinkDeleteInfo;
    if (!await showDeleteDialog(context, message: message)) {
      return;
    }

    try {
      await _service.deleteLink(link.id);
      setState(() => _links?.remove(link));
      await _service.rememberLinks(_links?.isNotEmpty ?? false);
    } catch (_) {
      // Errors are shown by the api service.
    }
  }

  @override
  Widget build(BuildContext context) {
    final locales = AppLocalizations.of(context)!;
    final format = DateFormat.yMd().add_Hm();

    return AlertDialog(
      title: Text(locales.shareMyLinks),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder(
          future: _loaded,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [CircularProgressIndicator()],
              );
            }

            final links = _links ?? [];
            if (links.isEmpty) {
              return Text(locales.shareNoLinks);
            }

            return ListView(
              shrinkWrap: true,
              children: [
                for (final link in links)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${locales.shareLinkRecords(link.recordCount)}'
                      '${link.singleUse ? ' · ${locales.shareSingleUse}' : ''}',
                    ),
                    subtitle: Text(
                      '${locales.shareLinkCreatedAt(format.format(link.createdAt.toLocal()))}\n'
                      '${locales.shareLinkExpiresAt(format.format(link.expiresAt.toLocal()))}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Symbols.delete),
                      tooltip: locales.remove,
                      onPressed: () => _delete(link),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(locales.close),
        ),
      ],
    );
  }
}
