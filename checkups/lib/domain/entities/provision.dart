import 'package:isar/isar.dart';

@Collection()
class Provision {
  final Id id;
  final String name;
  final int objectId;
  final DateTime dueDate;
  final bool isCompleted;
  final String? description;
  final String? notes;
  final DateTime? completionDate;
  final String? attachmentPath;

  const Provision({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.objectId,
    required this.dueDate,
    required this.isCompleted,
    this.description,
    this.notes,
    this.completionDate,
    this.attachmentPath,
  });

  Provision copyWith({
    Id? id,
    String? name,
    int? objectId,
    DateTime? dueDate,
    bool? isCompleted,
    String? description,
    String? notes,
    DateTime? completionDate,
    String? attachmentPath,
  }) {
    return Provision(
      id: id ?? this.id,
      name: name ?? this.name,
      objectId: objectId ?? this.objectId,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      completionDate: completionDate ?? this.completionDate,
      attachmentPath: attachmentPath ?? this.attachmentPath,
    );
  }

  factory Provision.fromJson(Map<String, dynamic> json) {
    return Provision(
      id: json['id'] as int? ?? Isar.autoIncrement,
      name: json['name'] as String,
      objectId: json['objectId'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: json['isCompleted'] as bool,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate'] as String) : null,
      attachmentPath: json['attachmentPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'objectId': objectId,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'description': description,
      'notes': notes,
      'completionDate': completionDate?.toIso8601String(),
      'attachmentPath': attachmentPath,
    };
  }

  @override
  String toString() {
    return 'Provision(id: $id, name: $name, objectId: $objectId, dueDate: $dueDate, isCompleted: $isCompleted, description: $description, notes: $notes, completionDate: $completionDate, attachmentPath: $attachmentPath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Provision &&
        other.id == id &&
        other.name == name &&
        other.objectId == objectId &&
        other.dueDate == dueDate &&
        other.isCompleted == isCompleted &&
        other.description == description &&
        other.notes == notes &&
        other.completionDate == completionDate &&
        other.attachmentPath == attachmentPath;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      objectId,
      dueDate,
      isCompleted,
      description,
      notes,
      completionDate,
      attachmentPath,
    );
  }
}
