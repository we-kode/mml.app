import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/services/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = SecureStorageService.getInstance();

  test('keeps the existing key of downloaded records', () async {
    FlutterSecureStorage.setMockInitialValues({
      SecureStorageService.cryptoKey: '213',
    });

    await storage.ensureCryptoKey();

    expect(await storage.get(SecureStorageService.cryptoKey), '213');
  });

  test('creates a key of downloaded records if none is stored', () async {
    FlutterSecureStorage.setMockInitialValues({});

    await storage.ensureCryptoKey();

    final key = int.parse((await storage.get(SecureStorageService.cryptoKey))!);
    expect(key, inInclusiveRange(0, 255));
  });
}
