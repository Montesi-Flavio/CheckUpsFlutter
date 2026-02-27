class Scadenza {
  final int? id;
  final int idUnitaLocale;
  final String genere;
  final String categoria;
  final String type;
  final int periodicita;
  final DateTime? scadenza;
  final String avvisoScadenza;
  final bool preavvisoAssolto;
  final String note;

  Scadenza({
    this.id,
    required this.idUnitaLocale,
    required this.genere,
    required this.categoria,
    required this.type,
    required this.periodicita,
    this.scadenza,
    required this.avvisoScadenza,
    required this.preavvisoAssolto,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_unita_locale': idUnitaLocale,
      'genere': genere,
      'categoria': categoria,
      'type': type,
      'periodicita': periodicita,
      'scadenza': scadenza?.toIso8601String(),
      'avviso_scadenza': avvisoScadenza,
      'preavviso_assolto': preavvisoAssolto ? 1 : 0,
      'note': note,
    };
  }

  factory Scadenza.fromMap(Map<String, dynamic> map) {
    return Scadenza(
      id: map['id'] as int?,
      idUnitaLocale: map['id_unita_locale'] as int,
      genere: map['genere'] as String,
      categoria: map['categoria'] as String,
      type: map['type'] as String,
      periodicita: map['periodicita'] as int,
      scadenza: map['scadenza'] != null
          ? DateTime.parse(map['scadenza'] as String)
          : null,
      avvisoScadenza: map['avviso_scadenza'] as String,
      preavvisoAssolto: (map['preavviso_assolto'] as int) == 1,
      note: map['note'] as String,
    );
  }

  Scadenza copyWith({
    int? id,
    int? idUnitaLocale,
    String? genere,
    String? categoria,
    String? type,
    int? periodicita,
    DateTime? scadenza,
    String? avvisoScadenza,
    bool? preavvisoAssolto,
    String? note,
  }) {
    return Scadenza(
      id: id ?? this.id,
      idUnitaLocale: idUnitaLocale ?? this.idUnitaLocale,
      genere: genere ?? this.genere,
      categoria: categoria ?? this.categoria,
      type: type ?? this.type,
      periodicita: periodicita ?? this.periodicita,
      scadenza: scadenza ?? this.scadenza,
      avvisoScadenza: avvisoScadenza ?? this.avvisoScadenza,
      preavvisoAssolto: preavvisoAssolto ?? this.preavvisoAssolto,
      note: note ?? this.note,
    );
  }
}
