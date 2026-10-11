import 'package:flutter_test/flutter_test.dart';
import 'package:purrfile/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty', () {
      expect(Validators.email(''), isNotNull);
    });
    test('rejects missing @', () {
      expect(Validators.email('marcus.purrfile.app'), isNotNull);
    });
    test('accepts a valid address', () {
      expect(Validators.email('marcus@purrfile.app'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty', () {
      expect(Validators.password(''), isNotNull);
    });
    test('rejects short passwords', () {
      expect(Validators.password('short'), isNotNull);
    });
    test('accepts 8+ characters', () {
      expect(Validators.password('longenough1'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects empty confirmation', () {
      expect(Validators.confirmPassword('', 'abcdefgh'), isNotNull);
    });
    test('rejects mismatch', () {
      expect(Validators.confirmPassword('abcdefgi', 'abcdefgh'), isNotNull);
    });
    test('accepts a match', () {
      expect(Validators.confirmPassword('abcdefgh', 'abcdefgh'), isNull);
    });
  });

  group('Validators.required', () {
    test('rejects blank/whitespace', () {
      expect(Validators.required('   '), isNotNull);
    });
    test('accepts non-empty', () {
      expect(Validators.required('Ash'), isNull);
    });
  });
}
