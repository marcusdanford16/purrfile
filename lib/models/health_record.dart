/// Matches the existing `health_records` table exactly.
enum RecordType { vaccination, vetVisit, weight, illness, other }

extension RecordTypeX on RecordType {
  String get label {
    switch (this) {
      case RecordType.vaccination:
        return 'Vaccination';
      case RecordType.vetVisit:
        return 'Vet Visit';
      case RecordType.weight:
        return 'Weight';
      case RecordType.illness:
        return 'Illness';
      case RecordType.other:
        return 'Other';
    }
  }

  static RecordType fromLabel(String? value) {
    switch (value) {
      case 'Vaccination':
        return RecordType.vaccination;
      case 'Vet Visit':
        return RecordType.vetVisit;
      case 'Weight':
        return RecordType.weight;
      case 'Illness':
        return RecordType.illness;
      default:
        return RecordType.other;
    }
  }
}

class HealthRecord {
  final String id;
  final String catId;
  final RecordType recordType;
  final DateTime date;
  final String? description;
  final String? veterinarian;
  final String? clinic;
  final String? notes;
  final DateTime? nextDueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HealthRecord({
    required this.id,
    required this.catId,
    required this.recordType,
    required this.date,
    this.description,
    this.veterinarian,
    this.clinic,
    this.notes,
    this.nextDueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as String,
      catId: map['cat_id'] as String,
      recordType: RecordTypeX.fromLabel(map['record_type'] as String?),
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      description: map['description'] as String?,
      veterinarian: map['veterinarian'] as String?,
      clinic: map['clinic'] as String?,
      notes: map['notes'] as String?,
      nextDueDate: map['next_due_date'] != null
          ? DateTime.tryParse(map['next_due_date'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'cat_id': catId,
      'record_type': recordType.label,
      'date': date.toIso8601String().split('T').first,
      'description': description,
      'veterinarian': veterinarian,
      'clinic': clinic,
      'notes': notes,
      'next_due_date': nextDueDate?.toIso8601String().split('T').first,
    };
  }
}
