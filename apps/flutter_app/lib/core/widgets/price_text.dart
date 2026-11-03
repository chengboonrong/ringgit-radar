import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../api/models.dart';
import '../format.dart';

/// The one place a price is drawn. A small top-aligned "RM", a gap, tabular digits with two
/// decimals. On sale: the struck original above, then the red chip and the red price.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.digitSize = 18,
    this.note,
  });

  final Price price;
  final double digitSize;

  /// Small text on the left of the struck original, such as "Ends 15 Nov". Only shown on sale,
  /// and only where the width is bounded.
  final String? note;

  /// What a screen reader says, built from the same integers.
  static String describe(Price p) => p.onSale
      ? 'Sale price ${plainMoney(p.currentMinor)}, was ${plainMoney(p.regularMinor)}, ${p.percentOff} percent off'
      : plainMoney(p.currentMinor);

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final d = digitSize;
    final struck = Text(
      plainMoney(price.regularMinor),
      style: TextStyle(
        fontSize: d * 0.7,
        color: tk.hint,
        decoration: TextDecoration.lineThrough,
        decorationColor: tk.hint,
        height: 1.2,
      ),
    );
    return Semantics(
      label: describe(price),
      child: ExcludeSemantics(
        child: price.onSale
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (note != null)
                    LayoutBuilder(
                      builder: (context, c) {
                        // The note keeps its natural width (cut only if it cannot fit at all) and the struck
                        // price takes the rest, right-aligned, scaling down only if it must.
                        final style = TextStyle(
                          fontSize: 11,
                          color: tk.hint,
                          height: 1.2,
                        );
                        final painter = TextPainter(
                          // measured with the style the Text will inherit, so the width matches what is drawn
                          text: TextSpan(
                            text: note,
                            style: DefaultTextStyle.of(
                              context,
                            ).style.merge(style),
                          ),
                          textDirection: TextDirection.ltr,
                          textScaler: MediaQuery.textScalerOf(context),
                          maxLines: 1,
                        )..layout();
                        final noteWidth = c.hasBoundedWidth
                            ? painter.width.ceilToDouble().clamp(
                                0.0,
                                c.maxWidth - 6,
                              )
                            : painter.width;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: noteWidth,
                              child: Text(
                                note!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: style,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: struck,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else
                    struck,
                  SizedBox(height: d * 0.1),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SaleChip(percent: price.percentOff, size: d * 0.62),
                          SizedBox(width: d * 0.3),
                          Amount(
                            minor: price.currentMinor,
                            digitSize: d,
                            color: tk.saleText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.centerRight,
                widthFactor: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Amount(
                    minor: price.currentMinor,
                    digitSize: d,
                    color: tk.text,
                  ),
                ),
              ),
      ),
    );
  }
}

/// "RM" at 75% of the digit size with its top level with the top of the digits, then the digits.
class Amount extends StatelessWidget {
  const Amount({
    super.key,
    required this.minor,
    required this.digitSize,
    required this.color,
  });

  final int minor;
  final double digitSize;
  final Color color;

  /// Numerals in M PLUS Rounded 1c are 0.74 em tall, so a 0.75 scale RM sits 0.185 em lower
  /// at the baseline unless it is lifted by the difference in their heights.
  static const _numeralHeight = 0.74;

  @override
  Widget build(BuildContext context) {
    final p = splitMinor(minor);
    final d = digitSize;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Transform.translate(
          offset: Offset(0, -_numeralHeight * d * 0.25),
          child: Text(
            'RM',
            style: TextStyle(
              fontSize: d * 0.75,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.15,
            ),
          ),
        ),
        SizedBox(width: d * 0.12),
        Text(
          '${p.whole}.${p.fraction}',
          style: TextStyle(
            fontSize: d,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

/// Square-cornered red chip, "10% OFF".
class SaleChip extends StatelessWidget {
  const SaleChip({super.key, required this.percent, this.size = 11});

  final int percent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.12,
      ),
      decoration: BoxDecoration(
        color: brandRed,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        percentOffLabel(percent),
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}

/// "NEW" and "Pre-order": near-black text, because white fails contrast on amber and green.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.size = 11,
  });

  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.12,
      ),
      color: color,
      child: Text(
        label,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: nearBlack,
          height: 1.2,
        ),
      ),
    );
  }
}
