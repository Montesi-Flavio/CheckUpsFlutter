import 'titolo.dart';
import 'oggetto.dart';
import 'provvedimento.dart';

class TitoloImportDto {
  final Titolo titolo;
  final String societaNome;
  final String unitaLocaleNome;
  final String repartoNome;

  TitoloImportDto({required this.titolo, required this.societaNome, required this.unitaLocaleNome, required this.repartoNome});
}

class OggettoImportDto {
  final Oggetto oggetto;
  final String societaNome;
  final String unitaLocaleNome;
  final String repartoNome;
  final String titoloDescrizione;

  OggettoImportDto({
    required this.oggetto,
    required this.societaNome,
    required this.unitaLocaleNome,
    required this.repartoNome,
    required this.titoloDescrizione,
  });
}

class ProvvedimentoImportDto {
  final Provvedimento provvedimento;
  final String societaNome;
  final String unitaLocaleNome;
  final String repartoNome;
  final String titoloDescrizione;
  final String oggettoNome;

  ProvvedimentoImportDto({
    required this.provvedimento,
    required this.societaNome,
    required this.unitaLocaleNome,
    required this.repartoNome,
    required this.titoloDescrizione,
    required this.oggettoNome,
  });
}
