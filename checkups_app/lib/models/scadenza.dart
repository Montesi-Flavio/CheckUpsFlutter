class Scadenza {
  final int? id;
  final int idUnitaLocale;
  final int? idGenere; // Maps to genere__id
  final String? titoloGenere; // From JOIN with generi_scadenze
  final String? categoria;
  final String? type;
  final int periodicita;
  final DateTime? scadenza;
  final String avvisoScadenza;
  final bool preavvisoAssolto;
  final String note;

  Scadenza({
    this.id,
    required this.idUnitaLocale,
    this.idGenere,
    this.titoloGenere,
    this.categoria,
    this.type,
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
      'genere__id': idGenere,
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
      id: map['id_scadenza'] as int?,
      idUnitaLocale: map['id_unita_locale'] as int,
      idGenere: map['genere__id'] as int?,
      titoloGenere: map['titolo_genere'] as String?,
      categoria: map['categoria'] as String?,
      type: map['type'] as String?,
      periodicita: map['periodicita'] as int,
      scadenza: map['scadenza'] != null ? DateTime.parse(map['scadenza'] as String) : null,
      avvisoScadenza: map['avviso_scadenza'] as String,
      preavvisoAssolto: (map['preavviso_assolto'] as int) == 1,
      note: map['note'] as String,
    );
  }

  Scadenza copyWith({
    int? id,
    int? idUnitaLocale,
    int? idGenere,
    String? titoloGenere,
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
      idGenere: idGenere ?? this.idGenere,
      titoloGenere: titoloGenere ?? this.titoloGenere,
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
