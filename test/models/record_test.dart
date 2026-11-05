import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/record.dart';

class _FakeContext extends Fake implements BuildContext {}

void main() {
  final date = DateTime.utc(2026, 11, 4, 23, 30);

  group('group', () {
    test('contains date and album', () {
      final record = Record(
        checksum: 'c',
        recordId: 'r1',
        date: date,
        album: 'Album',
      );

      expect(record.getGroup(_FakeContext()), endsWith(': Album'));
    });

    test('contains no album text without an album', () {
      final record = Record(checksum: 'c', recordId: 'r1', date: date);

      final group = record.getGroup(_FakeContext())!;
      expect(group, isNot(contains('null')));
      expect(group, isNot(contains(':')));
    });
  });

  group('group filter', () {
    test('contains the day and the album of the record', () {
      final record = Record(
        checksum: 'c',
        recordId: 'r1',
        date: date,
        album: 'Album',
        albumId: 'a1',
      );

      final filter = record.getGroupFilter() as ID3TagFilter;

      expect(filter.albums, ['a1']);
      expect(filter.startDate, DateTime.utc(2026, 11, 4));
      expect(filter.endDate, DateTime.utc(2026, 11, 4));
      expect(filter.artists, isEmpty);
    });

    test('contains only the day without an album', () {
      final filter =
          Record(checksum: 'c', recordId: 'r1', date: date).getGroupFilter()
              as ID3TagFilter;

      expect(filter.albums, isEmpty);
      expect(filter.startDate, DateTime.utc(2026, 11, 4));
    });

    test('does not exist, if the server sends no album id', () {
      final record = Record(
        checksum: 'c',
        recordId: 'r1',
        date: date,
        album: 'Album',
      );

      expect(record.getGroupFilter(), isNull);
    });

    test('does not exist without a date', () {
      expect(Record(checksum: 'c', recordId: 'r1').getGroupFilter(), isNull);
    });
  });

  test('does not send the album id back', () {
    final record = Record.fromJson({'recordId': 'r1', 'albumId': 'a1'});

    expect(record.albumId, 'a1');
    expect(record.toJson().containsKey('albumId'), isFalse);
  });
}
