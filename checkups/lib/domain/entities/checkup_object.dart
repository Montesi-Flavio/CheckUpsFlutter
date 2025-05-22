import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';

@Collection()
class CheckupObject {
  final Id id;
  final String name;
  final int titleId;
  final String? description;
  final String? notes;
  final List<int> provisionIds;

  const CheckupObject({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.titleId,
    this.description,
    this.notes,
    this.provisionIds = const [],
  });

  // Copia dell'oggetto con possibilità di modificare alcuni campi
  CheckupObject copyWith({
    Id? id,
    String? name,
    int? titleId,
    String? description,
    String? notes,
    List<int>? provisionIds,
  }) {
    return CheckupObject(
      id: id ?? this.id,
      name: name ?? this.name,
      titleId: titleId ?? this.titleId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      provisionIds: provisionIds ?? this.provisionIds,
    );
  }

  // Conversione da Map a Oggetto
  factory CheckupObject.fromJson(Map<String, dynamic> json) {
    return CheckupObject(
      id: json['id'] as int? ?? Isar.autoIncrement,
      name: json['name'] as String,
      titleId: json['titleId'] as int,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      provisionIds: (json['provisionIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
    );
  }

  // Conversione da Oggetto a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'titleId': titleId,
      'description': description,
      'notes': notes,
      'provisionIds': provisionIds,
    };
  }

  @override
  String toString() {
    return 'CheckupObject(id: $id, name: $name, titleId: $titleId, description: $description, notes: $notes, provisionIds: $provisionIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckupObject &&
        other.id == id &&
        other.name == name &&
        other.titleId == titleId &&
        other.description == description &&
        other.notes == notes &&
        listEquals(other.provisionIds, provisionIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      titleId,
      description,
      notes,
      Object.hashAll(provisionIds),
    );
  }
}
