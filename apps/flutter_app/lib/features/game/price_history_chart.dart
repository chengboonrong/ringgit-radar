import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/format.dart';

/// Step chart of the prices we have seen. It holds the last price up to [now].
/// The axis labels come from integer sen, never from the plotted doubles.
class PriceHistoryChart extends StatelessWidget {
  const PriceHistoryChart({
    super.key,
    required this.history,
    required this.now,
  });

  final List<HistoryPoint> history;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final first = history.first.observedAt;
    double x(DateTime t) => t.difference(first).inMinutes / 1440.0;
    final spots = [
      for (final h in history) FlSpot(x(h.observedAt), h.priceMinor / 100.0),
      FlSpot(
        x(now.isAfter(history.last.observedAt) ? now : history.last.observedAt),
        history.last.priceMinor / 100.0,
      ),
    ];
    final hi = history.map((h) => h.priceMinor).reduce((a, b) => a > b ? a : b);
    // the axis starts at zero, so a drop is drawn at its true size, and ends at the highest price seen
    const minY = 0.0;
    final maxY = hi / 100.0;
    final maxX = spots.last.x <= 0 ? 1.0 : spots.last.x;
    final summary =
        'Price history from ${longDateMyt(first)}: ${history.map((h) => plainMoney(h.priceMinor)).join(', then ')}.';

    TextStyle label() =>
        TextStyle(fontFamily: fontFamily, fontSize: 11, color: tk.hint);

    return Semantics(
      label: summary,
      image: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(top: 4, right: 8),
          child: SizedBox(
            height: 170,
            child: LineChart(
              duration: Duration.zero,
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: tk.divider),
                    left: BorderSide(color: tk.divider),
                  ),
                ),
                lineTouchData: const LineTouchData(enabled: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 72,
                      interval: maxY,
                      getTitlesWidget: (value, meta) {
                        final atTop = (value - maxY).abs() < 0.005;
                        if (!atTop && value.abs() > 0.005) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            plainMoney(atTop ? hi : 0),
                            style: label(),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: maxX,
                      getTitlesWidget: (value, meta) {
                        final at = value <= 0.001 ? first : now;
                        return SideTitleWidget(
                          meta: meta,
                          fitInside: SideTitleFitInsideData.fromTitleMeta(
                            meta,
                            distanceFromEdge: 0,
                          ),
                          child: Text(shortDateMyt(at), style: label()),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isStepLineChart: true,
                    lineChartStepData: const LineChartStepData(
                      stepDirection: LineChartStepData.stepDirectionForward,
                    ),
                    color: brandRed,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => spot.x != spots.last.x,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 3.5,
                            color: brandRed,
                            strokeWidth: 2,
                            strokeColor: tk.card,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
