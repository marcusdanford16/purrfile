/// Maps 1:1 to the existing `cats` table. Do not add columns here without a
/// matching column in Supabase — this app never recreates that table.
class Cat {
  final String id;
  final String userId;
  final String name;
  final String? photo;
  final String? breed;
  final String? sex;
  final DateTime? dob;
  final String? color;
  final String? microchipNumber;
  final String? ownerName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Cat({
    required this.id,
    required this.userId,
    required this.name,
    this.photo,
    this.breed,
    this.sex,
    this.dob,
    this.color,
    this.microchipNumber,
    this.ownerName,
    this.createdAt,
    this.updatedAt,
  });

  int? get ageInYears {
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob!.year;
    if (now.month < dob!.month ||
        (now.month == dob!.month && now.day < dob!.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }

  factory Cat.fromMap(Map<String, dynamic> map) {
    return Cat(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String? ?? '',
      photo: map['photo'] as String?,
      breed: map['breed'] as String?,
      sex: map['sex'] as String?,
      dob: map['dob'] != null ? DateTime.tryParse(map['dob'] as String) : null,
      color: map['color'] as String?,
      microchipNumber: map['microchip_number'] as String?,
      ownerName: map['owner_name'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  /// Fields for an insert/update — omits id/timestamps, which the database
  /// (or the service layer) is responsible for.
  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'name': name,
      'photo': photo,
      'breed': breed,
      'sex': sex,
      'dob': dob?.toIso8601String().split('T').first,
      'color': color,
      'microchip_number': microchipNumber,
      'owner_name': ownerName,
    };
  }

  Cat copyWith({
    String? name,
    String? photo,
    String? breed,
    String? sex,
    DateTime? dob,
    String? color,
    String? microchipNumber,
    String? ownerName,
  }) {
    return Cat(
      id: id,
      userId: userId,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      breed: breed ?? this.breed,
      sex: sex ?? this.sex,
      dob: dob ?? this.dob,
      color: color ?? this.color,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
