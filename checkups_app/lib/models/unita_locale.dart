import 'table_data.dart';

class UnitaLocale extends TableData {
  int idSocieta;
  String nome;
  String indirizzo;
  String localita;
  String provincia;
  String telefono;
  String? email;

  UnitaLocale({
    required int id,
    required this.idSocieta,
    required this.nome,
    required this.indirizzo,
    required this.localita,
    required this.provincia,
    required this.telefono,
    this.email,
  }) : super(id, 'unita_locali', 'id_unita_locale');

  @override
  void selfRemoveFromList() {
    // TODO: Implement list removal logic
  }
}
