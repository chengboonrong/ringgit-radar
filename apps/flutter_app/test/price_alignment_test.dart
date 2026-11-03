import 'dart:io';

import 'package:ringgit_radar/app/theme.dart';
import 'package:ringgit_radar/core/api/models.dart';
import 'package:ringgit_radar/core/widgets/price_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Price sale(int regular, int current, int percent) => Price(
  currency: 'MYR',
  regularMinor: regular,
  currentMinor: current,
  onSale: true,
  discountMinor: current,
  percentOff: percent,
  savedMinor: regular - current,
);

// the shipped font, so widths are the ones people see rather than the test font's square glyphs
Future<void> loadFont() async {
  final loader = FontLoader(fontFamily);
  for (final w in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('assets/fonts/MPLUSRounded1c-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Future<void> pumpCard(
  WidgetTester t,
  Price price,
  String note,
  double scale, {
  double width = 151,
}) async {
  await t.pumpWidget(
    MaterialApp(
      theme: buildTheme(Brightness.light),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: PriceText(price: price, digitSize: 17, note: note),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(loadFont);

  for (final scale in [1.0, 1.3]) {
    for (final (regular, current, note) in [
      (24900, 1992, 'Ends 11 Nov'),
      (129900, 12990, 'Ends 22 Nov'),
      (30900, 12360, 'Ends 8 Nov'),
    ]) {
      testWidgets(
        'the struck price ends where the sale price ends, scale $scale, RM ${regular / 100}, "$note"',
        (t) async {
          await pumpCard(t, sale(regular, current, 90), note, scale);
          expect(t.takeException(), isNull, reason: 'no overflow');

          final struck = find.byWidgetPredicate(
            (w) =>
                w is Text &&
                (w.style?.decoration == TextDecoration.lineThrough),
          );
          final salePrice = find.byWidgetPredicate(
            (w) =>
                w is Text &&
                w.data != null &&
                RegExp(r'^[\d,]+\.\d\d$').hasMatch(w.data!) &&
                w.style?.color == brandRed,
          );
          expect(struck, findsOneWidget);
          expect(salePrice, findsOneWidget);
          // right edges after any scaling by the FittedBoxes
          expect(
            t.getBottomRight(struck).dx,
            closeTo(t.getBottomRight(salePrice).dx, 0.5),
          );
          expect(t.getBottomRight(salePrice).dx, closeTo(151, 0.5));

          // the note keeps its room: it is not cut to an ellipsis
          final noteBox = t.renderObject<RenderParagraph>(find.text(note));
          expect(
            noteBox.didExceedMaxLines,
            isFalse,
            reason: 'the note must not be ellipsised',
          );
        },
      );
    }
  }
}
