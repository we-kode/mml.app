import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/models/announcement.dart';
import 'package:mml_app/services/announcements.dart';

Announcement announcement(String id, DateTime updatedAt) => Announcement(
  notificationId: id,
  title: 'Title $id',
  message: 'Message',
  severity: 1,
  updatedAt: updatedAt,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final service = AnnouncementService.getInstance();
  final changed = DateTime.utc(2026, 11, 2);

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('returns an empty list instead of failing without a server', () async {
    expect(await service.getActive(), isEmpty);
  });

  test('parses the announcements sent by the server', () {
    final parsed = Announcement.fromJson({
      'notificationId': 'a',
      'title': 'Maintenance',
      'message': 'Tonight',
      'severity': 2,
      'validFrom': null,
      'validTo': '2026-11-03T20:00:00Z',
      'updatedAt': '2026-11-02T10:00:00Z',
      'clientIds': [],
      'groups': [],
    });

    expect(parsed.severity, 2);
    expect(parsed.validTo, DateTime.utc(2026, 11, 3, 20));
  });

  test('shows announcements on start by default', () async {
    expect(await service.showOnStart(), isTrue);
    await service.setShowOnStart(false);
    expect(await service.showOnStart(), isFalse);
  });

  test('hides dismissed announcements until they are changed', () async {
    final a = announcement('a', changed);
    final b = announcement('b', changed);
    await service.dismiss(a);

    expect(await service.notDismissed([a, b]), [b]);

    final edited = announcement('a', changed.add(const Duration(hours: 1)));
    expect(await service.notDismissed([edited, b]), [edited, b]);
  });

  test('forgets dismissed announcements, which are not active', () async {
    final a = announcement('a', changed);
    await service.dismiss(a);
    await service.notDismissed([]);

    expect(await service.notDismissed([a]), [a]);
  });
}
