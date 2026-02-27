class GenereScadenza {
  final int id;
  final String title;

  GenereScadenza({required this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }

  factory GenereScadenza.fromMap(Map<String, dynamic> map) {
    return GenereScadenza(id: map['id'] as int, title: map['title'] as String);
  }
}
