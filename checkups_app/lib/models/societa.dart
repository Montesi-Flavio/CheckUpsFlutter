import 'dart:typed_data';
import 'table_data.dart';

class Societa extends TableData {
  String nome;
  String indirizzo;
  String localita;
  String provincia;
  String telefono;
  String? descrizione;
  String? partitaIva;
  String? codiceFiscale;
  String? bancaAppoggio;
  String? codiceAteco;
  Uint8List? logoBytes;

  Societa({
    required int id,
    required this.nome,
    required this.indirizzo,
    required this.localita,
    required this.provincia,
    required this.telefono,
    this.descrizione,
    this.partitaIva,
    this.codiceFiscale,
    this.bancaAppoggio,
    this.codiceAteco,
    this.logoBytes,
  }) : super(id, 'societa', 'id_societa');

  @override
  void selfRemoveFromList() {
    // TODO: Implement list removal logic if using global lists
  }

  bool get hasImage => logoBytes != null && logoBytes!.isNotEmpty;
}
