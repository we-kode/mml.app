import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/models/livestream.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/models/playlist.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/playback_resume.dart';
import 'package:mml_app/services/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final service = PlaybackResumeService.getInstance();
  final store = SecureStorageService.getInstance();

  Future<dynamic> stored(String key) async =>
      (await store.getJson(SecureStorageService.lastPlaybackStorageKey))[key];

  Record record({double duration = 600000}) =>
      Record(recordId: 'r1', title: 'Title', checksum: 'c', duration: duration);

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await service.setEnabled(false);
  });

  test('is disabled by default and stores nothing', () async {
    FlutterSecureStorage.setMockInitialValues({});

    await service.setEnabled(false);
    await service.remember(record(), 5000, force: true);

    expect(await stored('recordId'), isNull);
  });

  test('stores the position of a server record when enabled', () async {
    await service.setEnabled(true);

    await service.remember(record(), 12345.6, force: true);

    expect(await stored('recordId'), 'r1');
    expect(await stored('position'), 12346);
  });

  test('stores positions only every few seconds unless forced', () async {
    await service.setEnabled(true);
    await service.remember(record(), 1000, force: true);

    await service.remember(record(), 2000);
    expect(await stored('position'), 1000);

    await service.remember(record(), 3000, force: true);
    expect(await stored('position'), 3000);
  });

  test('forgets a record played to its end', () async {
    await service.setEnabled(true);
    await service.remember(record(), 1000, force: true);

    await service.remember(record(duration: 60000), 59000, force: true);

    expect(await stored('recordId'), isNull);
  });

  test('does not remember livestreams', () async {
    await service.setEnabled(true);

    await service.remember(
      Livestream(recordId: 'l1', title: 'Live'),
      1000,
      force: true,
    );

    expect(await stored('recordId'), isNull);
  });

  test('disabling forgets the stored position', () async {
    await service.setEnabled(true);
    await service.remember(record(), 1000, force: true);

    await service.setEnabled(false);

    expect(await stored('position'), isNull);
    expect(await service.isEnabled(), isFalse);
  });

  test('a start position does not replace a later stored position', () async {
    await service.setEnabled(true);
    await service.remember(record(), 90000, force: true);

    await service.remember(record(), 0, force: true);

    expect(await stored('position'), 90000);
  });

  test('a start position is stored on request or for another record', () async {
    await service.setEnabled(true);
    await service.remember(record(), 90000, force: true);

    await service.remember(record(), 0, force: true, allowStart: true);
    expect(await stored('position'), 0);

    await service.remember(record(), 90000, force: true);
    await service.remember(
      Record(recordId: 'r2', title: 'Other', checksum: 'c', duration: 600000),
      0,
      force: true,
    );
    expect(await stored('recordId'), 'r2');
  });

  test('remembers downloaded records with their playlist', () async {
    await service.setEnabled(true);

    await service.remember(
      LocalRecord(
        recordId: 'l1',
        checksum: 'c',
        playlist: Playlist(id: 7, name: 'Favorites'),
      ),
      42000,
      force: true,
    );
    expect(await stored('recordId'), 'l1');
    expect(await stored('playlistId'), 7);

    await service.remember(record(), 5000, force: true);
    expect(await stored('playlistId'), isNull);
  });
}
