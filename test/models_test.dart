import 'package:flutter_test/flutter_test.dart';
import 'package:purrfile/models/cat.dart';
import 'package:purrfile/models/health_record.dart';
import 'package:purrfile/models/reminder.dart';

void main() {
  group('Cat.fromMap / toInsertMap', () {
    test('parses a full row', () {
      final cat = Cat.fromMap({
        'id': 'cat-1',
        'user_id': 'user-1',
        'name': 'Ash',
        'photo': null,
        'breed': 'Persian',
        'sex': 'Male',
        'dob': '2024-05-10',
        'color': 'White',
        'microchip_number': '123456789012345',
        'owner_name': 'Marcus Cayanan',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': null,
      });

      expect(cat.name, 'Ash');
      expect(cat.breed, 'Persian');
      expect(cat.dob, DateTime(2024, 5, 10));
      expect(cat.ageInYears, isNotNull);
    });

    test('handles missing optional fields without throwing', () {
      final cat = Cat.fromMap({
        'id': 'cat-2',
        'user_id': 'user-1',
        'name': 'Ace',
      });
      expect(cat.breed, isNull);
      expect(cat.dob, isNull);
      expect(cat.ageInYears, isNull);
    });

    test('round-trips through toInsertMap', () {
      const cat = Cat(id: 'cat-1', userId: 'user-1', name: 'Ash', breed: 'Persian');
      final map = cat.toInsertMap();
      expect(map['user_id'], 'user-1');
      expect(map['name'], 'Ash');
      expect(map.containsKey('id'), isFalse);
    });
  });

  group('HealthRecord record type mapping', () {
    test('label round-trips through fromLabel', () {
      for (final type in RecordType.values) {
        if (type == RecordType.other) continue;
        expect(RecordTypeX.fromLabel(type.label), type);
      }
    });

    test('unknown label falls back to other', () {
      expect(RecordTypeX.fromLabel('Something else'), RecordType.other);
    });
  });

  group('Reminder.effectiveStatus', () {
    test('a completed reminder stays completed even if the date passed', () {
      final r = Reminder(
        id: 'r1',
        catId: 'cat-1',
        reminderType: 'Rabies vaccine',
        reminderDate: DateTime.now().subtract(const Duration(days: 5)),
        notificationStatus: ReminderStatus.completed,
      );
      expect(r.effectiveStatus, ReminderStatus.completed);
    });

    test('a future upcoming reminder stays upcoming', () {
      final r = Reminder(
        id: 'r2',
        catId: 'cat-1',
        reminderType: 'Annual checkup',
        reminderDate: DateTime.now().add(const Duration(days: 10)),
        notificationStatus: ReminderStatus.upcoming,
      );
      expect(r.effectiveStatus, ReminderStatus.upcoming);
    });

    test('a past-due upcoming reminder becomes overdue', () {
      final r = Reminder(
        id: 'r3',
        catId: 'cat-1',
        reminderType: 'Deworming',
        reminderDate: DateTime.now().subtract(const Duration(days: 2)),
        notificationStatus: ReminderStatus.upcoming,
      );
      expect(r.effectiveStatus, ReminderStatus.overdue);
    });
  });

  group('Reminder boolean notification_status', () {
    test('reads booleans and old text values', () {
      expect(ReminderStatusX.fromDb(true), ReminderStatus.completed);
      expect(ReminderStatusX.fromDb(false), ReminderStatus.upcoming);
      expect(ReminderStatusX.fromDb('completed'), ReminderStatus.completed);
      expect(ReminderStatusX.fromDb(null), ReminderStatus.upcoming);
    });

    test('writes a boolean', () {
      final r = Reminder(
        id: '1',
        catId: 'c',
        reminderType: 'Groom day',
        reminderDate: DateTime(2026, 10, 10),
        notificationStatus: ReminderStatus.upcoming,
      );
      expect(r.toInsertMap()['notification_status'], false);
      expect(ReminderStatus.completed.dbValue, true);
    });
  });
}
