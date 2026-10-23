// format.dart
// ---------------------------------------------------------------------------
// Turning numbers and dates into text the Vietnamese way:
//   money  -> 1.500.000 ₫   (dots between thousands, symbol after, no cents)
//   dates  -> 24/09/2026    (day/month/year)
//   months -> Tháng 9/2026
//
// We write these by hand instead of adding the `intl` package, so a beginner
// can see exactly how the formatting works.
// ---------------------------------------------------------------------------

/// Formats an amount of Vietnamese đồng, e.g. 1500000 -> "1.500.000 ₫".
///
/// Steps:
///   1. Round to a whole number (VND has no cents).
///   2. Turn it into text: "1500000".
///   3. Walk from the RIGHT, adding a dot every 3 digits: "1.500.000".
String formatVnd(num amount, {bool withSymbol = true, bool showPlus = false}) {
  final rounded = amount.round();
  final digits = rounded.abs().toString();

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    // How many digits are still to the right of this one?
    final digitsLeftAfterThis = digits.length - i - 1;
    buffer.write(digits[i]);
    final needsDot = digitsLeftAfterThis > 0 && digitsLeftAfterThis % 3 == 0;
    if (needsDot) {
      buffer.write('.');
    }
  }

  var sign = '';
  if (rounded < 0) {
    sign = '-';
  } else if (showPlus && rounded > 0) {
    sign = '+';
  }

  final symbol = withSymbol ? ' ₫' : '';
  return '$sign$buffer$symbol';
}

/// Short form for tight spaces such as chart labels:
/// 18500000 -> "18,5tr", 750000 -> "750k", 2300000000 -> "2,3 tỷ".
String formatVndCompact(num amount) {
  final value = amount.abs();
  final sign = amount < 0 ? '-' : '';

  if (value >= 1000000000) {
    return '$sign${_oneDecimal(value / 1000000000)} tỷ';
  }
  if (value >= 1000000) {
    return '$sign${_oneDecimal(value / 1000000)}tr';
  }
  if (value >= 1000) {
    return '$sign${(value / 1000).round()}k';
  }
  return '$sign${value.round()}';
}

/// 18.5 -> "18,5" and 18.0 -> "18" (Vietnamese uses a comma as decimal mark).
String _oneDecimal(num value) {
  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return rounded.round().toString();
  }
  return rounded.toStringAsFixed(1).replaceAll('.', ',');
}

/// Reads what the user typed ("1.500.000", "1500000", "1,5") into a number.
/// Returns null when the text is not a valid positive amount.
int? parseVnd(String text) {
  final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) {
    return null;
  }
  final value = int.tryParse(digitsOnly);
  if (value == null || value <= 0) {
    return null;
  }
  return value;
}

/// Adds a leading zero: 7 -> "07".
String _twoDigits(int n) => n.toString().padLeft(2, '0');

/// 2026-09-24 -> "24/09/2026"
String formatDate(DateTime date) {
  return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
}

/// 2026-09-24 -> "24/09"
String formatDayMonth(DateTime date) {
  return '${_twoDigits(date.day)}/${_twoDigits(date.month)}';
}

/// "Tháng 9/2026"
String formatMonth(DateTime date) => 'Tháng ${date.month}/${date.year}';

/// Friendly label for a list header: "Hôm nay", "Hôm qua", or "Thứ Hai, 22/09".
String formatRelativeDay(DateTime date, {DateTime? today}) {
  final now = today ?? DateTime.now();
  final dayOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(now.year, now.month, now.day);
  final difference = todayOnly.difference(dayOnly).inDays;

  if (difference == 0) {
    return 'Hôm nay';
  }
  if (difference == 1) {
    return 'Hôm qua';
  }
  return '${weekdayName(date)}, ${formatDayMonth(date)}';
}

/// Vietnamese weekday names. DateTime.weekday: Monday = 1 ... Sunday = 7.
String weekdayName(DateTime date) {
  const names = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
  return names[date.weekday - 1];
}

/// Greeting that follows the clock.
String greetingFor(DateTime time) {
  if (time.hour < 11) {
    return 'Chào buổi sáng';
  }
  if (time.hour < 14) {
    return 'Chào buổi trưa';
  }
  if (time.hour < 18) {
    return 'Chào buổi chiều';
  }
  return 'Chào buổi tối';
}

/// 0.456 -> "46%"
String formatPercent(double ratio) => '${(ratio * 100).round()}%';
