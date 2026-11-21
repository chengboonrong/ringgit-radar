import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Literals that are not UI text: names that are never translated, format patterns, and code-only strings.
const allowed = {
  'Ringgit Radar', 'Switch 2', 'Switch', 'RM', 'MPlusRounded1c', 'RinggitZh', 'API_BASE', //
  'd MMM', 'd MMM y', 'h:mm a', 'HH:mm', 'override in main',
};

/// Every string literal in [src] with its line, interpolations removed (they are code, not text).
List<(int, String)> literals(String src) => _Scanner(src).run();

class _Scanner {
  _Scanner(this.src);
  final String src;
  final found = <(int, String)>[];
  var i = 0, line = 1;
  static final _ident = RegExp(r'[A-Za-z0-9_]');

  List<(int, String)> run() {
    while (i < src.length) {
      final c = src[i];
      if (c == '\n') {
        line++;
        i++;
      } else if (src.startsWith('//', i)) {
        while (i < src.length && src[i] != '\n') {
          i++;
        }
      } else if (c == "'" || c == '"') {
        literal(c);
      } else {
        i++;
      }
    }
    return found;
  }

  // reads the literal starting at the quote at i, records it, leaves i after the closing quote
  void literal(String q) {
    final raw = i > 0 && src[i - 1] == 'r' && (i < 2 || !_ident.hasMatch(src[i - 2]));
    final at = line;
    final out = StringBuffer();
    i++;
    while (i < src.length && src[i] != q) {
      final c = src[i];
      if (c == '\n') line++;
      if (!raw && c == r'\') {
        out.write(src.substring(i, i + 2));
        i += 2;
      } else if (!raw && c == r'$' && i + 1 < src.length && src[i + 1] == '{') {
        i += 2;
        code();
      } else if (!raw && c == r'$') {
        i++;
        while (i < src.length && _ident.hasMatch(src[i])) {
          i++;
        }
      } else {
        out.write(c);
        i++;
      }
    }
    i++;
    found.add((at, out.toString()));
  }

  // skips interpolated code up to its closing brace, over nested strings and braces
  void code() {
    var depth = 0;
    while (i < src.length) {
      final c = src[i];
      if (c == '\n') line++;
      if (c == "'" || c == '"') {
        literal(c);
        continue;
      }
      if (c == '{') depth++;
      if (c == '}' && depth-- == 0) {
        i++;
        return;
      }
      i++;
    }
  }
}

bool isUiText(String raw) {
  // escapes such as \u00A0 are not words, and edge punctuation around an allowed name is not text
  final v = raw.replaceAll(RegExp(r'\\u\{?[0-9A-Fa-f]+\}?|\\.'), ' ').trim().replaceAll(RegExp(r'^[^A-Za-z0-9]+|[^A-Za-z0-9]+$'), '');
  if (allowed.contains(v)) return false;
  if (!RegExp('[A-Za-z]').hasMatch(v)) return false;
  if (RegExp(r'^[a-z0-9_/.:\-]*$').hasMatch(v)) return false; // keys, routes, ids, hero tags
  if (v.startsWith('http') || v.contains('package:') || v.startsWith('dart:')) return false;
  return true;
}

void main() {
  test('literals() reads nested interpolation and skips code inside it', () {
    final found = literals(r"""x('a ${b ? 'Inner' : "c"} d', 'art-$id'); // 'Comment'""").map((e) => e.$2).toList();
    expect(found, unorderedEquals(['a  d', 'Inner', 'c', 'art-']));
  });

  test('no UI text is hard-coded outside lib/l10n', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final p = f.path;
      if (!p.endsWith('.dart') || p.startsWith('lib/l10n/') || p.endsWith('.g.dart') || p.endsWith('.freezed.dart')) continue;
      final src = f.readAsStringSync();
      for (final (line, v) in literals(src)) {
        final text = src.split('\n')[line - 1].trimLeft();
        if (text.startsWith('import ') || text.startsWith('export ') || text.startsWith('part ')) continue;
        if (text.contains('toString()') && text.contains('ApiException(')) continue; // debug text
        if (isUiText(v)) offenders.add('$p:$line: $v');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
