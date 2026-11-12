import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/components/filter_app_bar.dart';
import 'package:mml_app/view_models/main.dart';

void main() {
  tearDown(() => MainViewModel.appBar = null);

  testWidgets('back leaves the opened folder first', (tester) async {
    final appBar = FilterAppBar(title: 'Records');
    appBar.navigationState.path = 'Folder';
    MainViewModel.appBar = appBar;
    await tester.pumpWidget(const SizedBox());

    final popped = await MainViewModel().popNestedRoute(
      tester.element(find.byType(SizedBox)),
    );

    expect(popped, isFalse);
    expect(appBar.navigationState.returnClicked, isTrue);
  });
}
