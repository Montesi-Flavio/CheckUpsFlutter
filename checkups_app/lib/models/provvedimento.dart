import 'table_data.dart';

class Provvedimento extends TableData {
  String nome;
  int idOggetto;
  int priorita;
  String rischio;
  String soggettiEsposti;
  int stimaD;
  int stimaP;
  DateTime? dataInizio;
  DateTime? dataScadenza;

  Provvedimento({
    required int id,
    required this.nome,
    required this.idOggetto,
    required this.priorita,
    required this.rischio,
    required this.soggettiEsposti,
    required this.stimaD,
    required this.stimaP,
    this.dataInizio,
    this.dataScadenza,
  }) : super(id, 'provvedimenti', 'id_provvedimento');

  int get stimaR => stimaD * stimaP;

  @override
  void selfRemoveFromList() {
    // TODO: Implement
  }
}
