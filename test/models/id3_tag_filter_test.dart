import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/models/id3_tag_filter.dart';

void main() {
  test('replacing resets former values and notifies once', () {
    final filter = ID3TagFilter(
      artists: ['artist'],
      genres: ['genre'],
      languages: ['language'],
      albums: ['old'],
    );
    var notified = 0;
    filter.addListener(() => notified++);
    final day = DateTime.utc(2026, 11, 4);

    filter.replaceWith(
      ID3TagFilter(albums: ['new'], startDate: day, endDate: day),
    );

    expect(notified, 1);
    expect(filter.albums, ['new']);
    expect(filter.startDate, day);
    expect(filter.endDate, day);
    expect(filter.artists, isEmpty);
    expect(filter.genres, isEmpty);
    expect(filter.languages, isEmpty);
  });

  test('replacing keeps the view mode', () {
    final filter = ID3TagFilter(isFolderView: true);

    filter.replaceWith(ID3TagFilter());

    expect(filter.isGrouped, isTrue);
  });
}
