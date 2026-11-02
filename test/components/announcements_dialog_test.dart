import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/components/announcements_dialog.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/announcement.dart';

void main() {
  final announcements = [
    Announcement(
      notificationId: 'a',
      title: 'Maintenance',
      message: 'Tonight',
      severity: 2,
      updatedAt: DateTime.utc(2026, 11, 2),
    ),
    Announcement(
      notificationId: 'b',
      title: 'Info',
      message: 'New records',
      severity: 1,
      updatedAt: DateTime.utc(2026, 11, 2),
    ),
  ];

  Future<void> open(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => dialog,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('navigates back and forth and dismisses checked ones on close', (
    tester,
  ) async {
    final dismissed = <String>[];
    await open(
      tester,
      AnnouncementsDialog(
        announcements: announcements,
        onDismiss: (a) async => dismissed.add(a.notificationId),
      ),
    );

    expect(find.text('Maintenance'), findsOneWidget);
    expect(find.text('1 of 2'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Back'))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Info'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Maintenance'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(dismissed, isEmpty);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(dismissed, ['a']);
    expect(find.byType(AnnouncementsDialog), findsNothing);
  });

  testWidgets('can not be closed by tapping outside or going back', (
    tester,
  ) async {
    await open(tester, AnnouncementsDialog(announcements: announcements));

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(AnnouncementsDialog), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AnnouncementsDialog), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('shortens long titles to one line and shows them as tooltip', (
    tester,
  ) async {
    final long = 'Very long title ' * 10;
    await open(
      tester,
      AnnouncementsDialog(
        announcements: [
          Announcement(
            notificationId: 'c',
            title: long,
            message: 'Text',
            severity: 3,
            updatedAt: DateTime.utc(2026, 11, 2),
          ),
          announcements.first,
        ],
      ),
    );

    expect(find.byTooltip(long), findsOneWidget);
    expect(tester.widget<Text>(find.text(long)).maxLines, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a hint without announcements', (tester) async {
    await open(tester, const AnnouncementsDialog(announcements: []));

    expect(find.text('There are no current announcements.'), findsOneWidget);
  });
}
