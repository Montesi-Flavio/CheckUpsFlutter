import 'package:flutter/foundation.dart';

class Department {
  final int id;
  final String name;
  final int localUnitId;
  final String? description;
  final String? notes;

  final List<int> titleIds;

  const Department({
    this.id = -1,
    required this.name,
    required this.localUnitId,
    this.description,
    this.notes,
    this.titleIds = const [],
  });

  Department copyWith({
    int? id,
    String? name,
    int? localUnitId,
    String? description,
    String? notes,
    List<int>? titleIds,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      localUnitId: localUnitId ?? this.localUnitId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      titleIds: titleIds ?? this.titleIds,
    );
  }

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int? ?? -1,
      name: json['name'] as String,
      localUnitId: json['localUnitId'] as int,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      titleIds: (json['titleIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'localUnitId': localUnitId,
      'description': description,
      'notes': notes,
      'titleIds': titleIds,
    };
  }

  @override
  String toString() {
    return 'Department(id: $id, name: $name, localUnitId: $localUnitId, description: $description, notes: $notes, titleIds: $titleIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Department &&
        other.id == id &&
        other.name == name &&
        other.localUnitId == localUnitId &&
        other.description == description &&
        other.notes == notes &&
        listEquals(other.titleIds, titleIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      localUnitId,
      description,
      notes,
      Object.hashAll(titleIds),
    );
  }
}
