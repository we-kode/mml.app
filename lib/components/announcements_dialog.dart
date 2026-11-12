import 'package:material_ui/material_ui.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/announcement.dart';
import 'package:mml_app/models/announcement_severity.dart';

/// Shows [announcements] one after another. It can only be closed with the
/// close button on the last announcement. With [onDismiss] the user can mark
/// announcements, so they are not shown on start again.
class AnnouncementsDialog extends StatefulWidget {
  /// The announcements to show.
  final List<Announcement> announcements;

  /// Called on close for each announcement the user does not want to see
  /// again or null, if the announcements can only be read.
  final Future<void> Function(Announcement announcement)? onDismiss;

  /// Initializes the dialog.
  const AnnouncementsDialog({
    super.key,
    required this.announcements,
    this.onDismiss,
  });

  @override
  State<AnnouncementsDialog> createState() => _AnnouncementsDialogState();
}

class _AnnouncementsDialogState extends State<AnnouncementsDialog> {
  // Icon and position have the same width, so the title is centered.
  static const double _sideWidth = 56;

  int _index = 0;
  final Set<Announcement> _dismissed = {};

  @override
  Widget build(BuildContext context) {
    var locales = AppLocalizations.of(context)!;
    var count = widget.announcements.length;
    if (count == 0) {
      return AlertDialog(
        content: Text(locales.noAnnouncements),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(locales.close),
          ),
        ],
      );
    }

    var theme = Theme.of(context);
    var announcement = widget.announcements[_index];
    var color = AnnouncementSeverity.color(announcement.severity, theme);
    var isLast = _index == count - 1;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Row(
          children: [
            SizedBox(
              width: _sideWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Icon(
                    AnnouncementSeverity.icon(announcement.severity),
                    color: color,
                  ),
                ),
              ),
            ),
            Expanded(child: _title(announcement.title)),
            SizedBox(
              width: _sideWidth,
              child: Text(
                count > 1
                    ? locales.announcementPosition(_index + 1, count)
                    : '',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: SelectableText(
                  announcement.message,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            if (widget.onDismiss != null)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(locales.doNotShowAgain),
                value: _dismissed.contains(announcement),
                onChanged: (value) => setState(
                  () => value == true
                      ? _dismissed.add(announcement)
                      : _dismissed.remove(announcement),
                ),
              ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: _index > 0 ? () => setState(() => _index--) : null,
            child: Text(locales.previous),
          ),
          TextButton(
            onPressed: isLast ? _close : () => setState(() => _index++),
            child: Text(isLast ? locales.close : locales.next),
          ),
        ],
      ),
    );
  }

  Widget _title(String title) {
    return Tooltip(
      message: title,
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<void> _close() async {
    for (var announcement in _dismissed) {
      await widget.onDismiss?.call(announcement);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
