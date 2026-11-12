import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/view_models/licenses_overview.dart';

void main() {
  setUp(LicenseRegistry.reset);
  tearDown(LicenseRegistry.reset);

  test('groups the licenses by package sorted by name', () async {
    LicenseRegistry.addLicense(
      () => Stream.fromIterable([
        const LicenseEntryWithLineBreaks(['zeta', 'Alpha'], 'License A'),
        const LicenseEntryWithLineBreaks(['beta'], 'License B'),
      ]),
    );

    final licenses = await LicensesOverviewViewModel().licenses;

    expect(licenses.keys, ['Alpha', 'beta', 'zeta']);
    expect(licenses['Alpha'], 'License A');
    expect(licenses['zeta'], 'License A');
    expect(licenses['beta'], 'License B');
  });

  test('joins several licenses of one package', () async {
    LicenseRegistry.addLicense(
      () => Stream.fromIterable([
        const LicenseEntryWithLineBreaks(['alpha'], 'First'),
        const LicenseEntryWithLineBreaks(['alpha'], 'Second'),
      ]),
    );

    final license = (await LicensesOverviewViewModel().licenses)['alpha']!;

    expect(license, startsWith('First'));
    expect(license, endsWith('Second'));
  });
}
