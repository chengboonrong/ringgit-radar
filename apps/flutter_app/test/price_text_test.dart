import 'package:ringgit_radar/app/theme.dart';
import 'package:ringgit_radar/core/api/models.dart';
import 'package:ringgit_radar/core/widgets/price_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => MaterialApp(theme: buildTheme(Brightness.light), home: Scaffold(body: Center(child: child)));

Price regular(int minor) => Price(currency: 'MYR', regularMinor: minor, currentMinor: minor, onSale: false);

Price sale(int regular, int current, int percent) => Price(
      currency: 'MYR',
      regularMinor: regular,
      currentMinor: current,
      onSale: true,
      discountMinor: current,
      percentOff: percent,
      savedMinor: regular - current,
    );

double fontSizeOf(WidgetTester t, String text) => t.widget<Text>(find.text(text)).style!.fontSize!;

void main() {
  testWidgets('a regular price is a small RM and two-decimal digits', (t) async {
    await t.pumpWidget(host(PriceText(price: regular(7200), digitSize: 20)));
    expect(find.text('RM'), findsOneWidget);
    expect(find.text('72.00'), findsOneWidget);
    expect(find.textContaining('OFF'), findsNothing);
    expect(fontSizeOf(t, 'RM'), 15); // 75% of the digits
    expect(fontSizeOf(t, '72.00'), 20);
  });

  testWidgets('a free price still shows two decimals', (t) async {
    await t.pumpWidget(host(PriceText(price: regular(0))));
    expect(find.text('0.00'), findsOneWidget);
  });

  testWidgets('thousands are grouped', (t) async {
    await t.pumpWidget(host(PriceText(price: regular(129900))));
    expect(find.text('1,299.00'), findsOneWidget);
  });

  testWidgets('a sale shows the struck original, the percent chip and the sale price', (t) async {
    await t.pumpWidget(host(PriceText(price: sale(7200, 6480, 10), note: 'Ends 15 Nov')));
    expect(find.text('RM\u00A072.00'), findsOneWidget);
    expect(t.widget<Text>(find.text('RM\u00A072.00')).style!.decoration, TextDecoration.lineThrough);
    expect(find.text('10% OFF'), findsOneWidget);
    expect(find.text('64.80'), findsOneWidget);
    expect(find.text('Ends 15 Nov'), findsOneWidget);
    // the chip is red and the sale price takes the sale colour
    final chip = t.widget<Container>(find.ancestor(of: find.text('10% OFF'), matching: find.byType(Container)).first);
    expect((chip.decoration! as BoxDecoration).color, brandRed);
    expect(t.widget<Text>(find.text('64.80')).style!.color, brandRed);
  });

  testWidgets('on a dark card the sale price uses the pinker red', (t) async {
    await t.pumpWidget(MaterialApp(theme: buildTheme(Brightness.dark), home: Scaffold(body: Center(child: PriceText(price: sale(7200, 6480, 10))))));
    expect(t.widget<Text>(find.text('64.80')).style!.color, saleRedOnDark);
  });

  testWidgets('the screen reader hears the sale in words from the same integers', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(host(PriceText(price: sale(7200, 6480, 10))));
    expect(find.bySemanticsLabel('Sale price RM\u00A064.80, was RM\u00A072.00, 10 percent off'), findsOneWidget);
    handle.dispose();
  });
}
