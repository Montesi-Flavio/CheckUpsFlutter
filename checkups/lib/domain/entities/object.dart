import 'package:isar/isar.dart';

@Collection()
class Object {
  final Id id;
  final String name;
  final int priority;
  final int titleId;

  const Object({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.priority,
    required this.titleId,
  });

  // Copia dell'oggetto con possibilità di modificare alcuni campi
  Object copyWith({
    Id? id,
    String? name,
    int? priority,
    int? titleId,
  }) {
    return Object(
      id: id ?? this.id,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      titleId: titleId ?? this.titleId,
    );
  }

  // Conversione da Map a Oggetto
  factory Object.fromJson(Map<String, dynamic> json) {
    return Object(
      id: json['id'] as int? ?? Isar.autoIncrement,
      name: json['name'] as String,
      priority: json['priority'] as int,
      titleId: json['titleId'] as int,
    );
  }

  // Conversione da Oggetto a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'priority': priority,
      'titleId': titleId,
    };
  }

  @override
  String toString() {
    return 'Object(id: $id, name: $name, priority: $priority, titleId: $titleId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Object && other.id == id && other.name == name && other.priority == priority && other.titleId == titleId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      priority,
      titleId,
    );
  }
}
