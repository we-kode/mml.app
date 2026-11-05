import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mml_app/components/async_list_view.dart';
import 'package:mml_app/components/list_subfilter_view.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/filter.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/models/selected_items_action.dart';

class _TagFilter extends ListSubfilterView {
  const _TagFilter(ID3TagFilter filter) : super(filter: filter);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  final date = DateTime.utc(2026, 11, 4);
  late ID3TagFilter tagFilter;
  late Filter textFilter;
  late List<String?> loads;
  late int selected;

  Future<void> show(
    WidgetTester tester,
    List<Record> records, {
    bool withSubfilter = true,
    SelectedItemsAction? action,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: AsyncListView(
          title: 'records',
          subfilter: withSubfilter ? _TagFilter(tagFilter) : null,
          filter: textFilter,
          selectedItemsAction: action,
          onMultiSelect: (actionId, items) async => false,
          onGroupSelected: () => selected++,
          loadData:
              ({String? filter, int? offset, int? take, dynamic subfilter}) {
                loads.add(filter);
                return Future.value(
                  ModelList(records, offset ?? 0, records.length),
                );
              },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Record album() => Record(
    checksum: 'c',
    recordId: 'r1',
    title: 'T',
    date: date,
    album: 'A',
    albumId: 'a1',
  );

  setUp(() {
    tagFilter = ID3TagFilter(artists: ['old']);
    textFilter = Filter()..textFilter = 'text';
    loads = [];
    selected = 0;
  });

  testWidgets('tap on a group replaces all filters and reloads once', (
    tester,
  ) async {
    await show(tester, [album()]);
    loads.clear();

    await tester.tap(find.byType(ActionChip));
    await tester.pumpAndSettle();

    expect(tagFilter.albums, ['a1']);
    expect(tagFilter.startDate, date);
    expect(tagFilter.artists, isEmpty);
    expect(textFilter.textFilter, isEmpty);
    expect(selected, 1);
    expect(loads, ['']);
  });

  testWidgets('groups, which can not be filtered, are not tappable', (
    tester,
  ) async {
    await show(tester, [
      Record(checksum: 'c', recordId: 'r1', title: 'T', date: date, album: 'A'),
    ]);

    expect(find.byType(ActionChip), findsNothing);
    expect(find.byType(Chip), findsOneWidget);
  });

  testWidgets('groups are not tappable without a subfilter', (tester) async {
    await show(tester, [album()], withSubfilter: false);

    expect(find.byType(ActionChip), findsNothing);
  });

  testWidgets('groups are not tappable while selecting items', (tester) async {
    await show(tester, [
      album(),
    ], action: SelectedItemsAction(const Icon(Symbols.star)));

    await tester.longPress(find.text('T'));
    await tester.pumpAndSettle();

    expect(find.byType(ActionChip), findsNothing);
  });
}
