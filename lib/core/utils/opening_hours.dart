/// Today's opening hours and open/closed status from a free-text schedule
/// such as {'Monday - Friday': '6:00 AM - 1:00 AM'}.
class OpeningHoursInfo {
  final String label;
  final bool? isOpen; // null when the times could not be parsed

  const OpeningHoursInfo({required this.label, required this.isOpen});
}

class OpeningHours {
  static const _days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  static final _timeRegex =
      RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)', caseSensitive: false);

  /// Hours for [now]'s weekday, plus whether the turf is open at [now].
  static OpeningHoursInfo? forToday(Map<String, String> hours, DateTime now) {
    if (hours.isEmpty) return null;

    final today = _entryForDay(hours, now.weekday - 1);
    final label = today ?? hours.values.first;
    final current = now.hour * 60 + now.minute;

    final todayRange = today == null ? null : _parseRange(today);
    if (todayRange == null) return OpeningHoursInfo(label: label, isOpen: null);

    final (start, end) = todayRange;
    if (end > start) {
      return OpeningHoursInfo(label: label, isOpen: current >= start && current < end);
    }

    // Crosses midnight: open from start until midnight, and from midnight
    // until end.
    var open = current >= start;

    // Still open from yesterday's late-night session?
    final yesterday = _entryForDay(hours, (now.weekday + 5) % 7);
    final yesterdayRange = yesterday == null ? null : _parseRange(yesterday);
    if (yesterdayRange != null) {
      final (yStart, yEnd) = yesterdayRange;
      if (yEnd <= yStart && current < yEnd) open = true;
    }
    return OpeningHoursInfo(label: label, isOpen: open);
  }

  /// Value for the entry whose day range covers [dayIndex] (0 = Monday).
  static String? _entryForDay(Map<String, String> hours, int dayIndex) {
    for (final entry in hours.entries) {
      final days = _parseDays(entry.key);
      if (days != null && days.contains(dayIndex)) return entry.value;
    }
    return null;
  }

  static Set<int>? _parseDays(String key) {
    final found = RegExp(r'[A-Za-z]{3,}')
        .allMatches(key.toLowerCase())
        .map((m) => _days.indexOf(m.group(0)!.substring(0, 3)))
        .where((i) => i >= 0)
        .toList();
    if (found.isEmpty) return null;
    if (found.length == 1) return {found.first};

    final result = <int>{};
    var day = found.first;
    result.add(day);
    while (day != found.last) {
      day = (day + 1) % 7;
      result.add(day);
    }
    return result;
  }

  /// (start, end) in minutes since midnight, or null if unparseable.
  static (int, int)? _parseRange(String text) {
    final matches = _timeRegex.allMatches(text).toList();
    if (matches.length < 2) return null;
    return (_toMinutes(matches[0]), _toMinutes(matches[1]));
  }

  static int _toMinutes(RegExpMatch m) {
    var hour = int.parse(m.group(1)!) % 12;
    final minute = int.tryParse(m.group(2) ?? '0') ?? 0;
    if (m.group(3)!.toLowerCase() == 'pm') hour += 12;
    return hour * 60 + minute;
  }
}
