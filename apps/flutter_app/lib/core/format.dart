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

// Chinese uses its own pattern for dates ("12月31日"); English and Malay share "31 Dec" / "31 Dis".
// English keeps the 12-hour clock it always had, the others use 24 hours.
DateFormat _day(String l) => l == 'zh' ? DateFormat.MMMd(l) : DateFormat('d MMM', l);
DateFormat _dayYear(String l) => l == 'zh' ? DateFormat.yMMMd(l) : DateFormat('d MMM y', l);
String _clock(DateTime m, String l) => l == 'en' ? DateFormat('h:mm a', l).format(m).toLowerCase() : DateFormat('HH:mm', l).format(m);

/// "15 Nov" for a sale end on a card. zh "11月15日", ms "15 Nov".
String shortDateMyt(DateTime instant, String locale) => _day(locale).format(toMyt(instant));

/// "1 Nov 2026". zh "2026年11月1日".
String longDateMyt(DateTime instant, String locale) => _dayYear(locale).format(toMyt(instant));

/// "15 Nov 11:59 pm", used where the year is obvious. zh "11月15日 23:59", ms "15 Nov 23:59".
String dateTimeMyt(DateTime instant, String locale) {
  final m = toMyt(instant);
  return '${_day(locale).format(m)} ${_clock(m, locale)}';
}

/// "2 Nov 2026, 12:10 am". zh "2026年11月2日 00:10", ms "2 Nov 2026, 00:10".
String longDateTimeMyt(DateTime instant, String locale) {
  final m = toMyt(instant);
  return '${_dayYear(locale).format(m)}${locale == 'zh' ? ' ' : ', '}${_clock(m, locale)}';
}

/// A calendar date from the API ("2027-03-08"), which carries no time zone, as "8 Mar 2027".
String releaseDateLabel(String isoDate, String locale) {
  final d = DateTime.tryParse(isoDate);
  return d == null ? isoDate : _dayYear(locale).format(d);
}

/// "7,827".
String groupedCount(int n, String locale) => NumberFormat.decimalPattern(locale).format(n);
