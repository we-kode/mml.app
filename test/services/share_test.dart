import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/models/share_options.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/services/share.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final service = ShareService.getInstance();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('defaults are the longest validity and single use links', () async {
    final options = await service.loadDefaults();

    expect(options.validForHours, ShareOptions.validForHoursChoices.last);
    expect(options.singleUse, isTrue);
    expect(await service.useDefaults(), isFalse);
  });

  test('defaults are stored together and restored', () async {
    await service.saveDefaults(
      ShareOptions(validForHours: 24, singleUse: false),
      true,
    );

    final options = await service.loadDefaults();
    expect(options.validForHours, 24);
    expect(options.singleUse, isFalse);
    expect(await service.useDefaults(), isTrue);
  });

  test('remembering links keeps the known rights', () async {
    FlutterSecureStorage.setMockInitialValues({
      SecureStorageService.shareStateStorageKey: '{"canShare":true}',
    });

    await service.rememberLinks(true);

    expect(await service.canShare(), isTrue);
    expect(await service.hasLinks(), isTrue);
    expect(await service.userChoosesOptions(), isFalse);
  });

  test('invalid stored values are ignored', () async {
    FlutterSecureStorage.setMockInitialValues({
      SecureStorageService.shareStateStorageKey: 'no json',
      SecureStorageService.shareDefaultsStorageKey: '{"validForHours":5}',
    });

    expect(await service.canShare(), isFalse);
    expect(
      (await service.loadDefaults()).validForHours,
      ShareOptions.validForHoursChoices.last,
    );
  });
}
