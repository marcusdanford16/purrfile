import '../models/cat.dart';

/// Human-friendly age: "3 mo", "2 yr" (short) or "3 months old",
/// "2 years old" (long). Returns null when the date of birth is unknown.
///
/// Unlike `Cat.ageInYears`, kittens under a year get months instead of "0 yr".
String? catAgeLabel(Cat cat, {bool long = false}) {
  final dob = cat.dob;
  if (dob == null) return null;
  final now = DateTime.now();
  var months = (now.year - dob.year) * 12 + (now.month - dob.month);
  if (now.day < dob.day) months--;
  if (months < 0) return null;

  if (months < 12) {
    if (months == 0) return long ? 'Under 1 month old' : '<1 mo';
    final plural = months == 1 ? '' : 's';
    return long ? '$months month$plural old' : '$months mo';
  }
  final years = months ~/ 12;
  final plural = years == 1 ? '' : 's';
  return long ? '$years year$plural old' : '$years yr';
}
