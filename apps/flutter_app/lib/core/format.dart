import 'package:intl/intl.dart';

/// Whole ringgit with thousands separators and the two-digit fraction, from integer sen.
/// 1299 sen is ('12', '99'); 129900 sen is ('1,299', '00'). Never built from a float.
({String whole, String fraction}) splitMinor(int minor) {
  final negative = minor < 0;
  final abs = negative ? -minor : minor;
  final digits = (abs ~/ 100).toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }
  return (
    whole: '${negative ? '-' : ''}$grouped',
    fraction: (abs % 100).toString().padLeft(2, '0'),
  );
}

/// "RM 64.80" with a no-break space: the one way money reads as text, in lines, labels and chart axes.
/// The big price widget draws the same words with a small raised RM.
String plainMoney(int minor) {
  final p = splitMinor(minor);
  return 'RM\u00A0${p.whole}.${p.fraction}';
}

/// Malaysia time is UTC+8 all year. Shown dates are converted with this offset on purpose, never
/// with the device zone, so a sale that ends at 23:59:59 in Kuala Lumpur reads the same everywhere.
const _mytOffset = Duration(hours: 8);

/// The instant as a wall-clock value in Malaysia, carried in a UTC-flagged DateTime.
DateTime toMyt(DateTime instant) => instant.toUtc().add(_mytOffset);

DateTime todayMyt(DateTime now) {
  final m = toMyt(now);
  return DateTime.utc(m.year, m.month, m.day);
}

final _day = DateFormat('d MMM', 'en');
final _dayYear = DateFormat('d MMM y', 'en');
final _clock = DateFormat('h:mm a', 'en');

/// "15 Nov" for a sale end on a card.
String shortDateMyt(DateTime instant) => _day.format(toMyt(instant));

/// "1 Nov 2026".
String longDateMyt(DateTime instant) => _dayYear.format(toMyt(instant));

/// "15 Nov 11:59 pm", used where the year is obvious.
String dateTimeMyt(DateTime instant) {
  final m = toMyt(instant);
  return '${_day.format(m)} ${_clock.format(m).toLowerCase()}';
}

/// "2 Nov 2026, 12:10 am".
String longDateTimeMyt(DateTime instant) {
  final m = toMyt(instant);
  return '${_dayYear.format(m)}, ${_clock.format(m).toLowerCase()}';
}

/// "Sale ends 16 Dec 2026, 11:59 pm".
String saleEndsMyt(DateTime end) {
  final m = toMyt(end);
  return 'Sale ends ${_dayYear.format(m)}, ${_clock.format(m).toLowerCase()}';
}

/// A calendar date from the API ("2027-03-08"), which carries no time zone, as "8 Mar 2027".
String releaseDateLabel(String isoDate) {
  final d = DateTime.tryParse(isoDate);
  return d == null ? isoDate : _dayYear.format(d);
}

String percentOffLabel(int percent) => '$percent% OFF';

String itemsLabel(int count) => 'Items: ${NumberFormat.decimalPattern('en').format(count)}';
