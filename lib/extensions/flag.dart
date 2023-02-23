import 'dart:collection';

/// String? extensions, that allows to convert a langauge to an flag emoji.
extension Flag on String? {
  List<String> asFlag() {
    final langs = List<String>.empty(growable: true);
    if (this == null || this!.isEmpty) {
      return List.empty();
    }

    final lower = this!.toLowerCase().trim();
    if (lower.startsWith('mus') || lower.startsWith('муз')) {
      return List.from(['🎻']);
    }

    for (final lang in lower.split(RegExp('[/\\,;]'))) {
      var langCode = _languageCodes[lang];
      langCode ??= '🏁';

      langs.add(
        langCode.toUpperCase().replaceAllMapped(
              RegExp(r'[A-Z]'),
              (match) => String.fromCharCode(
                match.group(0)!.codeUnitAt(0) + 127397,
              ),
            ),
      );
    }

    return langs;
  }

  /// Map of languages to language iso 2 letter codes.
  static final HashMap<String, String> _languageCodes = HashMap.from(
    {
      'deutsch': 'de',
      'german': 'de',
      'немецкий': 'de',
      'russisch': 'ru',
      'russian': 'ru',
      'русский': 'ru',
      'englisch': 'gb',
      'english': 'gb',
      'английский': 'gb',
      'ukrainisch': 'ua',
      'ukrainian': 'ua',
      'украинский': 'ua',
      'spanisch': 'es',
      'spanish': 'es',
      'испанский': 'es',
      'hebräisch': 'il',
      'hebraic': 'il',
      'еврейский': 'il',
      'armenisch': 'am',
      'armenian': 'am',
      'армянский': 'am',
      'weißrussisch': 'by',
      'belarussian': 'by',
      'белорусский': 'by',
      'rumänisch': 'ro',
      'romanian': 'ro',
      'румынский': 'ro',
      'moldawisch': 'md',
      'moldavian': 'md',
      'молдавский': 'md',
      'estnisch': 'ee',
      'estonian': 'ee',
      'эстонский': 'ee',
      'litauisch': 'lt',
      'lithuanian': 'lt',
      'литовский': 'lt',
      'lettisch': 'lv',
      'latvian': 'lv',
      'латышский': 'lv',
      'portugiesisch': 'pt',
      'portuguese': 'pt',
      'португальский': 'pt',
    },
  );
}
