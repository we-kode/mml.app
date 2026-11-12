import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/views/records/record_tag_filter.dart';

void main() {
  const screens = {'portrait': Size(375, 667), 'landscape': Size(667, 375)};

  for (final screen in screens.entries) {
    testWidgets('opens the date filter on a small ${screen.key} screen', (
      tester,
    ) async {
      tester.view.physicalSize = screen.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  RecordTagFilter.showDateRangeDialog(context, const []),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CalendarDatePicker2WithActionButtons), findsOneWidget);
    });
  }
}
