import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/action_export.dart';
import 'package:mml_app/models/selected_items_action.dart';
import 'package:mml_app/models/share_action.dart';

void main() {
  Future<void> show(WidgetTester tester, FilterAppBar appBar) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: appBar),
      ),
    );
  }

  testWidgets(
    'shows the share action as soon as it becomes visible, also after the app bar was recreated',
    (tester) async {
      final selection = SelectedItemsAction(const Icon(Symbols.star))
        ..count = 1000
        ..enabled = true;
      await show(
        tester,
        FilterAppBar(
          title: 'records',
          listAction: selection,
          shareAction: ShareAction(),
        ),
      );

      // The router recreates the app bar with a new share action.
      final shareAction = ShareAction();
      await show(
        tester,
        FilterAppBar(
          title: 'records',
          listAction: selection,
          shareAction: shareAction,
        ),
      );
      expect(find.byTooltip('Share download link'), findsNothing);

      shareAction.visible = true;
      await tester.pump();

      expect(find.byTooltip('Share download link'), findsOneWidget);
    },
  );

  testWidgets('forgets the actions of a recreated app bar', (tester) async {
    final oldSelection = SelectedItemsAction(const Icon(Symbols.star));
    final oldExport = ExportAction();
    await show(
      tester,
      FilterAppBar(
        title: 'records',
        listAction: oldSelection,
        exportAction: oldExport,
      ),
    );
    await show(
      tester,
      FilterAppBar(
        title: 'records',
        listAction: SelectedItemsAction(const Icon(Symbols.star)),
        exportAction: ExportAction(),
      ),
    );
    await tester.pumpWidget(const SizedBox());

    // Updates of the old actions must not reach the disposed app bar.
    oldSelection.count = 1;
    oldExport.actionPerformed = true;

    expect(tester.takeException(), isNull);
  });

  testWidgets('follows text filters changed by others', (tester) async {
    final appBar = FilterAppBar(title: 'records', enableFilter: true);
    await show(tester, appBar);

    appBar.filter.textFilter = 'search';
    await tester.pump();
    expect(find.text('search'), findsOneWidget);

    appBar.filter.textFilter = '';
    await tester.pump();
    expect(find.text('search'), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
  });
}
