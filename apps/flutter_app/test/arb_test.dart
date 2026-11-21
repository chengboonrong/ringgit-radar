import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, String> load(String code) {
  final d = jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;
  return {for (final e in d.entries) if (!e.key.startsWith('@')) e.key: e.value as String};
}

/// The ICU shape of a message: every argument name, and for plural/select arguments every case, as
/// "name" and "name:case". Text between braces is ignored.
Set<String> shape(String msg) {
  final out = <String>{};
  var i = 0;
  late final void Function() argument;
  void message(bool nested) {
    while (i < msg.length) {
      final c = msg[i];
      if (c == '{') {
        i++;
        argument();
      } else if (c == '}' && nested) {
        return;
      } else {
        i++;
      }
    }
  }

  argument = () {
    final start = i;
    while (msg[i] != '}' && msg[i] != ',') {
      i++;
    }
    final name = msg.substring(start, i).trim();
    out.add(name);
    if (msg[i] == '}') {
      i++;
      return;
    }
    i++; // the comma after the name
    final kindStart = i;
    while (msg[i] != ',') {
      i++;
    }
    final kind = msg.substring(kindStart, i).trim();
    i++;
    if (kind != 'plural' && kind != 'select') throw FormatException('unknown ICU kind $kind in $msg');
    // cases: label {message} ... }
    while (true) {
      while (msg[i] == ' ') {
        i++;
      }
      if (msg[i] == '}') {
        i++;
        return;
      }
      final labelStart = i;
      while (msg[i] != '{' && msg[i] != ' ') {
        i++;
      }
      out.add('$name:${msg.substring(labelStart, i)}');
      while (msg[i] != '{') {
        i++;
      }
      i++;
      message(true);
      i++; // the case's closing brace
    }
  };

  message(false);
  return out;
}

/// Keys whose value is rightly the same as English: each language option is written in its own language,
/// and a few Malay words are the English word.
const sameAsEnglish = {
  'zh': {'languageEnglish', 'languageChinese', 'languageMalay'},
  // Malay writes platform, genre, data, RPG, platformer and video with the English word
  'ms': {'languageEnglish', 'languageChinese', 'languageMalay', 'platform', 'genre', 'dataHeading', 'genreRpg', 'genrePlatformer', 'genreVideo'},
};

/// Words the honesty rules forbid: nothing is called popular, best-selling or trending, and nothing
/// suggests the app is official. "Unofficial" is fine.
final forbidden = {
  'en': [RegExp(r'popular|best-selling|bestseller|best seller|top-selling|trending', caseSensitive: false), RegExp(r'(?<!un)official', caseSensitive: false)],
  'zh': [RegExp('热门|最受欢迎|畅销|人气'), RegExp('(?<!非)官方')],
  'ms': [RegExp(r'popular|terlaris|paling laris|trending', caseSensitive: false), RegExp(r'(?<!tidak )rasmi', caseSensitive: false)],
};

/// Same shape, except that a language may add or drop the exact =0 and =1 cases.
bool _same(Set<String> a, Set<String> b) {
  Set<String> core(Set<String> s) => s.where((e) => !RegExp(r':=[01]$').hasMatch(e)).toSet();
  final x = core(a), y = core(b);
  return x.length == y.length && x.containsAll(y);
}

void main() {
  final en = load('en');
  final others = {'zh': load('zh'), 'ms': load('ms')};

  test('shape() reads arguments and plural cases', () {
    expect(shape('{count, plural, =1{{name}, 1 game} other{{name}, {count} games}}'), {'count', 'count:=1', 'count:other', 'name'});
    expect(shape('Ends {date}'), {'date'});
  });

  for (final MapEntry(key: code, value: tr) in others.entries) {
    test('$code has exactly the English keys', () {
      expect(tr.keys.toSet().difference(en.keys.toSet()), isEmpty, reason: 'extra');
      expect(en.keys.toSet().difference(tr.keys.toSet()), isEmpty, reason: 'missing');
    });

    test('$code keeps every placeholder and plural or select case', () {
      final wrong = [
        for (final k in en.keys)
          if (tr[k] != null && !_same(shape(tr[k]!), shape(en[k]!))) '$k: ${tr[k]}',
      ];
      expect(wrong, isEmpty, reason: wrong.join('\n'));
      for (final k in en.keys) {
        if (en[k]!.contains(', plural,') || en[k]!.contains(', select,')) {
          expect(shape(tr[k]!).any((s) => s.endsWith(':other')), isTrue, reason: k);
        }
      }
    });

    test('$code translates every value', () {
      final same = [
        for (final k in en.keys)
          if (en[k]!.isNotEmpty && tr[k] == en[k] && !sameAsEnglish[code]!.contains(k)) k,
      ];
      expect(same, isEmpty, reason: 'untranslated: ${same.join(', ')}');
      expect(tr['privacyEnglishPrevails'], isNotEmpty);
    });

    test('$code keeps the name Ringgit Radar as it is', () {
      final lost = [for (final k in en.keys) if (en[k]!.contains('Ringgit Radar') && !tr[k]!.contains('Ringgit Radar')) k];
      expect(lost, isEmpty, reason: lost.join(', '));
    });
  }

  for (final code in ['en', 'zh', 'ms']) {
    test('$code uses no word the honesty rules forbid', () {
      final values = code == 'en' ? en : others[code]!;
      final hits = [
        for (final e in values.entries)
          for (final r in forbidden[code]!)
            if (r.hasMatch(e.value)) '${e.key}: ${r.firstMatch(e.value)![0]}',
      ];
      expect(hits, isEmpty, reason: hits.join('\n'));
    });
  }
}
