import 'table_data.dart';

class Oggetto extends TableData {
  String nome;
  int priorita;
  int idTitolo;

  Oggetto({
    required int id,
    required this.nome,
    required this.priorita,
    required this.idTitolo,
  }) : super(id, 'oggetti', 'id_oggetto');

  @override
  void selfRemoveFromList() {
    // TODO: Implement
  }
}
