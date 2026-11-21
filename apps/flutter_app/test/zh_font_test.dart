import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ringgit_radar/app/theme.dart';

void main() {
  test('every character the Chinese text uses is in the bundled Chinese subset', () {
    final arb = jsonDecode(File('lib/l10n/app_zh.arb').readAsStringSync()) as Map<String, dynamic>;
    final used = <int>{
      for (final e in arb.entries)
        if (!e.key.startsWith('@')) ...(e.value as String).runes.where((r) => r > 0x7E),
    };
    final have = File('assets/fonts/zh_chars.txt').readAsStringSync().runes.toSet();
    final missing = used.difference(have).map(String.fromCharCode).join();
    expect(missing, isEmpty, reason: 'missing from the subset (run tool/subset_zh_font.sh): $missing');
  });

  test('each shipped Chinese font file is a small subset, not a full CJK font', () {
    final files = Directory('assets/fonts').listSync().whereType<File>().where((f) => f.uri.pathSegments.last.startsWith('RinggitZh')).toList();
    expect(files, isNotEmpty);
    for (final f in files) {
      expect(f.lengthSync(), lessThan(300 * 1024), reason: f.path);
    }
  });

  test('Chinese puts the Chinese font first; English and Malay fall back to it for 简体中文', () {
    final zh = buildTheme(Brightness.light, languageCode: 'zh').textTheme.bodyMedium!;
    expect(zh.fontFamily, 'RinggitZh');
    expect(zh.fontFamilyFallback, contains('MPlusRounded1c'));
    for (final code in ['en', 'ms']) {
      final s = buildTheme(Brightness.dark, languageCode: code).textTheme.bodyMedium!;
      expect(s.fontFamily, 'MPlusRounded1c');
      expect(s.fontFamilyFallback, contains('RinggitZh'));
    }
  });
}
