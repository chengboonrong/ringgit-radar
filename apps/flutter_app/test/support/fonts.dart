import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the shipped fonts (every family under assets/fonts), so widths in tests are the ones people
/// see rather than the test font's square glyphs.
Future<void> loadAppFonts() async {
  final families = <String, List<File>>{};
  for (final f in Directory('assets/fonts').listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    if (!name.endsWith('.ttf')) continue;
    final family = name.startsWith('MPLUSRounded1c') ? 'MPlusRounded1c' : name.split('-').first;
    (families[family] ??= []).add(f);
  }
  for (final MapEntry(key: family, value: files) in families.entries) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
    }
    await loader.load();
  }
}
