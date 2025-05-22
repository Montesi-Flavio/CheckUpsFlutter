class CheckupItem {
  final int id;
  final String name;
  final int priority;
  final int titleId;

  const CheckupItem({
    this.id = -1,
    required this.name,
    required this.priority,
    required this.titleId,
  });

  // Copia dell'oggetto con possibilità di modificare alcuni campi
  CheckupItem copyWith({
    int? id,
    String? name,
    int? priority,
    int? titleId,
  }) {
    return CheckupItem(
      id: id ?? this.id,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      titleId: titleId ?? this.titleId,
    );
  }

  // Conversione da Map a Oggetto
  factory CheckupItem.fromJson(Map<String, dynamic> json) {
    return CheckupItem(
      id: json['id'] as int? ?? -1,
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
    return other is CheckupItem && other.id == id && other.name == name && other.priority == priority && other.titleId == titleId;
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
