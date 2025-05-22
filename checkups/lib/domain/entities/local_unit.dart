import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';

@Collection()
class LocalUnit {
  final Id id;
  final String name;
  final int companyId;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? email;
  final String? notes;
  final List<int> departmentIds;

  const LocalUnit({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.companyId,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.country,
    this.phone,
    this.email,
    this.notes,
    this.departmentIds = const [],
  });

  // Copia dell'oggetto con possibilità di modificare alcuni campi
  LocalUnit copyWith({
    Id? id,
    String? name,
    int? companyId,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? country,
    String? phone,
    String? email,
    String? notes,
    List<int>? departmentIds,
  }) {
    return LocalUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      departmentIds: departmentIds ?? this.departmentIds,
    );
  }

  // Conversione da Map a Oggetto
  factory LocalUnit.fromJson(Map<String, dynamic> json) {
    return LocalUnit(
      id: json['id'] as int? ?? Isar.autoIncrement,
      name: json['name'] as String,
      companyId: json['companyId'] as int,
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      departmentIds: (json['departmentIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
    );
  }

  // Conversione da Oggetto a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyId': companyId,
      'address': address,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'email': email,
      'notes': notes,
      'departmentIds': departmentIds,
    };
  }

  @override
  String toString() {
    return 'LocalUnit(id: $id, name: $name, companyId: $companyId, address: $address, city: $city, province: $province, postalCode: $postalCode, country: $country, phone: $phone, email: $email, notes: $notes, departmentIds: $departmentIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalUnit &&
        other.id == id &&
        other.name == name &&
        other.companyId == companyId &&
        other.address == address &&
        other.city == city &&
        other.province == province &&
        other.postalCode == postalCode &&
        other.country == country &&
        other.phone == phone &&
        other.email == email &&
        other.notes == notes &&
        listEquals(other.departmentIds, departmentIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      companyId,
      address,
      city,
      province,
      postalCode,
      country,
      phone,
      email,
      notes,
      Object.hashAll(departmentIds),
    );
  }
}
