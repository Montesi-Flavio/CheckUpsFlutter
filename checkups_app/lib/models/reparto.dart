import 'table_data.dart';

class Reparto extends TableData {
  int idUnitaLocale;
  int priorita;
  String nome;
  String descrizione;
  String revisione;
  DateTime? data;

  Reparto({
    required int id,
    required this.idUnitaLocale,
    required this.priorita,
    required this.nome,
    required this.descrizione,
    required this.revisione,
    this.data,
  }) : super(id, 'reparti', 'id_reparto');

  @override
  void selfRemoveFromList() {
    // TODO: Implement
  }
}
