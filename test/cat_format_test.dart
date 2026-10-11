import 'package:flutter_test/flutter_test.dart';

import 'package:purrfile/models/cat.dart';
import 'package:purrfile/utils/cat_format.dart';

Cat _cat(DateTime? dob) => Cat(id: '1', userId: 'u', name: 'Ash', dob: dob);

void main() {
  group('catAgeLabel', () {
    test('is null when the date of birth is unknown', () {
      expect(catAgeLabel(_cat(null)), isNull);
    });

    test('formats whole years', () {
      final now = DateTime.now();
      final dob = DateTime(now.year - 2, now.month, now.day);
      expect(catAgeLabel(_cat(dob)), '2 yr');
      expect(catAgeLabel(_cat(dob), long: true), '2 years old');
    });

    test('singular year', () {
      final now = DateTime.now();
      final dob = DateTime(now.year - 1, now.month, now.day);
      expect(catAgeLabel(_cat(dob), long: true), '1 year old');
    });

    test('is null for a date of birth in the future', () {
      final future = DateTime.now().add(const Duration(days: 90));
      expect(catAgeLabel(_cat(future)), isNull);
    });
  });
}
