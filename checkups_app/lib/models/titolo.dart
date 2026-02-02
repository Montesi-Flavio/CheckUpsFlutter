import 'table_data.dart';

class Titolo extends TableData {
  String descrizione;
  int priorita;
  int idReparto;

  Titolo({
    required int id,
    required this.descrizione,
    required this.priorita,
    required this.idReparto,
  }) : super(id, 'titoli', 'id_titolo');

  @override
  void selfRemoveFromList() {
    // TODO: Implement
  }
}
