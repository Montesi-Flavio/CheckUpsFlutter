import 'package:flutter/foundation.dart';

class Title {
  final int id;
  final String name;
  final int departmentId;
  final String? description;
  final String? notes;
  final List<int> objectIds;

  const Title({
    this.id = -1,
    required this.name,
    required this.departmentId,
    this.description,
    this.notes,
    this.objectIds = const [],
  });

  Title copyWith({
    int? id,
    String? name,
    int? departmentId,
    String? description,
    String? notes,
    List<int>? objectIds,
  }) {
    return Title(
      id: id ?? this.id,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      objectIds: objectIds ?? this.objectIds,
    );
  }

  factory Title.fromJson(Map<String, dynamic> json) {
    return Title(
      id: json['id'] as int? ?? -1,
      name: json['name'] as String,
      departmentId: json['departmentId'] as int,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      objectIds: (json['objectIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'departmentId': departmentId,
      'description': description,
      'notes': notes,
      'objectIds': objectIds,
    };
  }

  @override
  String toString() {
    return 'Title(id: $id, name: $name, departmentId: $departmentId, description: $description, notes: $notes, objectIds: $objectIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Title &&
        other.id == id &&
        other.name == name &&
        other.departmentId == departmentId &&
        other.description == description &&
        other.notes == notes &&
        listEquals(other.objectIds, objectIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      departmentId,
      description,
      notes,
      Object.hashAll(objectIds),
    );
  }
}
