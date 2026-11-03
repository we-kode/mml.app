import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/share_check.dart';
import 'package:mml_app/models/share_link.dart';

void main() {
  group('ShareLink', () {
    test('search link keeps text, tags and dates when parsed again', () {
      final link = ShareLink(
        filter: 'sermon & more',
        tagFilter: ID3TagFilter(
          genres: ['g1', 'g2'],
          genreNames: ['Gospel', 'Pop'],
          artists: ['a1'],
          artistNames: ['Artist'],
          startDate: DateTime.utc(2026, 1, 1),
          endDate: DateTime.utc(2026, 12, 31),
        ),
      );

      final uri = link.toUri('mml.example.org:8443');
      expect(uri.scheme, 'https');
      expect(uri.host, 'mml.example.org');
      expect(uri.port, 8443);
      expect(uri.path, '/s/open');

      // The landing page of the server forwards the query to the app.
      final parsed = ShareLink.parse(
        Uri.parse('mml://open?${uri.query}&server=mml.example.org%3A8443'),
      )!;
      expect(parsed.isRecord, isFalse);
      expect(parsed.server, 'mml.example.org:8443');
      expect(parsed.filter, 'sermon & more');
      expect(parsed.tagFilter.genres, ['g1', 'g2']);
      expect(parsed.tagFilter.genreNames, ['Gospel', 'Pop']);
      expect(parsed.tagFilter.artists, ['a1']);
      expect(parsed.tagFilter.startDate, DateTime.utc(2026, 1, 1));
      expect(parsed.tagFilter.endDate, DateTime.utc(2026, 12, 31));
    });

    test('record link carries the position only with a record', () {
      final record = ShareLink(recordId: 'r1', positionMs: 61500);
      final search = ShareLink(positionMs: 5);

      expect(record.toUri('mml.example.org').queryParameters, {
        'record': 'r1',
        't': '61500',
      });
      expect(search.toUri('mml.example.org').hasQuery, isFalse);

      final parsed = ShareLink.parse(
        Uri.parse('mml://open?record=r1&t=61500'),
      )!;
      expect(parsed.isRecord, isTrue);
      expect(parsed.recordId, 'r1');
      expect(parsed.positionMs, 61500);
    });

    test(
      'accepts the route of the operating system and ignores other links',
      () {
        expect(ShareLink.parse(Uri.parse('/open?record=r1')), isNotNull);
        expect(ShareLink.parse(Uri.parse('https://example.org/open')), isNull);
        expect(ShareLink.parse(Uri.parse('/records')), isNull);
      },
    );

    test('ignores an invalid position and empty record', () {
      final parsed = ShareLink.parse(Uri.parse('mml://open?record=&t=abc'))!;

      expect(parsed.isRecord, isFalse);
      expect(parsed.positionMs, isNull);
    });

    test('ignores a negative position', () {
      expect(
        ShareLink.parse(Uri.parse('mml://open?record=r1&t=-5'))!.positionMs,
        isNull,
      );
    });

    test('search link with a token is short and carries only the token', () {
      final link = ShareLink(
        tagFilter: ID3TagFilter(genres: List.generate(50, (i) => 'g$i')),
      );

      final uri = link.toTokenUri('mml.example.org:8443', 'abc123');
      expect(uri.toString(), 'https://mml.example.org:8443/s/open?c=abc123');

      final parsed = ShareLink.parse(
        Uri.parse('mml://open?c=abc123&server=mml.example.org%3A8443'),
      )!;
      expect(parsed.token, 'abc123');
      expect(parsed.server, 'mml.example.org:8443');
      expect(parsed.isRecord, isFalse);
    });

    test('filters are stored by name and restored from them', () {
      final link = ShareLink(
        filter: 'text',
        tagFilter: ID3TagFilter(genres: ['g1', 'g2'], languages: ['de']),
      );

      expect(link.toSearch(), {
        'q': 'text',
        'genre': ['g1', 'g2'],
        'language': ['de'],
      });
      expect(link.searchValueCount, 4);

      // the server answers with all filters, unset ones are empty or null.
      final restored = ShareLink.fromSearch({
        'q': 'text',
        'artist': <String>[],
        'genre': ['g1', 'g2'],
        'from': null,
        'to': '2026-01-02T00:00:00.000',
      }, 'mml.example.org');
      expect(restored.filter, 'text');
      expect(restored.tagFilter.genres, ['g1', 'g2']);
      expect(restored.tagFilter.artists, isEmpty);
      expect(restored.tagFilter.startDate, isNull);
      expect(restored.tagFilter.endDate, DateTime(2026, 1, 2));
      expect(restored.server, 'mml.example.org');
      expect(restored.hasSearch, isTrue);
    });

    test('only searches with a filter are worth to be shared', () {
      expect(ShareLink().hasSearch, isFalse);
      expect(ShareLink(filter: '').hasSearch, isFalse);
      expect(ShareLink(filter: 'a').hasSearch, isTrue);
      expect(
        ShareLink(tagFilter: ID3TagFilter(albums: ['a1'])).hasSearch,
        isTrue,
      );
      expect(ShareLink(recordId: 'r1', filter: 'a').hasSearch, isFalse);
    });
  });

  group('ShareCheck', () {
    test('is partial only if some, but not all records can be shared', () {
      expect(const ShareCheck(shareable: 2, total: 3).isPartial, isTrue);
      expect(const ShareCheck(shareable: 3, total: 3).isPartial, isFalse);
      expect(const ShareCheck(shareable: 0, total: 3).isPartial, isFalse);
    });

    test('parses the response of the server', () {
      final check = ShareCheck.fromJson({'shareable': 1, 'total': 4});

      expect(check.shareable, 1);
      expect(check.total, 4);
    });
  });
}
