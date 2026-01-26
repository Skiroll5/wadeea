class AppDateUtils {
  /// Parses a date string ensuring it is interpreted as local time,
  /// ignoring any timezone offset or 'Z' indicator from the backend.
  ///
  /// This is useful when the backend sends a time that represents a wall-clock time
  /// (e.g. 10:00) but attaches a timezone (e.g. Z) that shifts it when parsed
  /// to local time. This function strips the timezone info so DateTime.parse
  /// treats it as a local date/time.
  static DateTime parseLocal(String dateString) {
    if (dateString.isEmpty) {
      throw FormatException('Invalid date string: empty');
    }

    // Remove 'Z' if present at the end
    String cleanString = dateString;
    if (cleanString.endsWith('Z')) {
      cleanString = cleanString.substring(0, cleanString.length - 1);
    } else {
      // Remove +HH:mm or -HH:mm at the end if present
      // Regex matches: (+ or -) followed by 2 digits, optionally a colon, and 2 digits, at the end of string
      // Remove +HH:mm, -HH:mm, +HHmm, -HHmm, +HH, -HH at the end
      // Regex matches: (+ or -) followed by 2 digits, optionally (colon or not) and 2 digits
      // It also technically matches just +HH because the second group could be missing if we used ? on the whole group
      // But let's use a robust one: `[+-]\d{2}(?::?\d{2})?`
      final regex = RegExp(r'[+-]\d{2}(?::?\d{2})?$');
      if (regex.hasMatch(cleanString)) {
        cleanString = cleanString.replaceAll(regex, '');
      }
    }

    return DateTime.parse(cleanString);
  }

  /// Safe wrapper for parseLocal that returns null on error or null input
  static DateTime? tryParseLocal(String? dateString) {
    if (dateString == null) return null;
    try {
      return parseLocal(dateString);
    } catch (_) {
      return null;
    }
  }
}
