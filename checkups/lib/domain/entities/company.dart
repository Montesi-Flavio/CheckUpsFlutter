import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';

@Collection()
class Company {
  final Id id;
  final String name;
  final String fiscalCode;
  final String vatNumber;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? email;
  final String? pec;
  final String? notes;
  final List<int> localUnitIds;

  const Company({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.fiscalCode,
    required this.vatNumber,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.country,
    this.phone,
    this.email,
    this.pec,
    this.notes,
    this.localUnitIds = const [],
  });

  // Copia dell'oggetto con possibilità di modificare alcuni campi
  Company copyWith({
    Id? id,
    String? name,
    String? fiscalCode,
    String? vatNumber,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? country,
    String? phone,
    String? email,
    String? pec,
    String? notes,
    List<int>? localUnitIds,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      fiscalCode: fiscalCode ?? this.fiscalCode,
      vatNumber: vatNumber ?? this.vatNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      pec: pec ?? this.pec,
      notes: notes ?? this.notes,
      localUnitIds: localUnitIds ?? this.localUnitIds,
    );
  }

  // Conversione da Map a Oggetto
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int? ?? Isar.autoIncrement,
      name: json['name'] as String,
      fiscalCode: json['fiscalCode'] as String,
      vatNumber: json['vatNumber'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      pec: json['pec'] as String?,
      notes: json['notes'] as String?,
      localUnitIds: (json['localUnitIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
    );
  }

  // Conversione da Oggetto a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fiscalCode': fiscalCode,
      'vatNumber': vatNumber,
      'address': address,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'email': email,
      'pec': pec,
      'notes': notes,
      'localUnitIds': localUnitIds,
    };
  }

  @override
  String toString() {
    return 'Company(id: $id, name: $name, fiscalCode: $fiscalCode, vatNumber: $vatNumber, address: $address, city: $city, province: $province, postalCode: $postalCode, country: $country, phone: $phone, email: $email, pec: $pec, notes: $notes, localUnitIds: $localUnitIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Company &&
        other.id == id &&
        other.name == name &&
        other.fiscalCode == fiscalCode &&
        other.vatNumber == vatNumber &&
        other.address == address &&
        other.city == city &&
        other.province == province &&
        other.postalCode == postalCode &&
        other.country == country &&
        other.phone == phone &&
        other.email == email &&
        other.pec == pec &&
        other.notes == notes &&
        listEquals(other.localUnitIds, localUnitIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      fiscalCode,
      vatNumber,
      address,
      city,
      province,
      postalCode,
      country,
      phone,
      email,
      pec,
      notes,
      Object.hashAll(localUnitIds),
    );
  }
}
