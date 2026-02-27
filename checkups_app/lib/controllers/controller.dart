import 'package:checkups_app/repositories/database_repository.dart';
import 'package:checkups_app/models/table_data.dart';
import 'package:checkups_app/models/societa.dart';
import 'package:checkups_app/models/unita_locale.dart';
import 'package:checkups_app/models/reparto.dart';
import 'package:checkups_app/models/titolo.dart';
import 'package:checkups_app/models/oggetto.dart';
import 'package:checkups_app/models/provvedimento.dart';

class Controller {
  final DatabaseRepository _repository;

  Controller(this._repository);

  // Replicating Java Controller.eliminaRecord logic
  Future<void> eliminaRecord(TableData tData) async {
    tData.selfRemoveFromList(); // Handles local list removal if implemented
    await _repository.deleteRecord(tData.tableName, tData.primaryKey, tData.id);
    // ModelListe.eliminaRecordDaLista(tData); // This might be handled by State Management in Flutter
  }

  // Replicating Java Controller.modificaCampo logic
  // Note: In Flutter, usually we update the object locally and then save.
  // This method seems to assume direct DB partial update.
  Future<void> modificaCampoStringa(
    TableData obj,
    String campo,
    String? nuovoValore,
  ) async {
    await _repository.updateCampoStringa(
      obj.tableName,
      obj.primaryKey,
      obj.id,
      campo,
      nuovoValore,
    );
  }

  Future<void> modificaCampoInt(
    TableData obj,
    String campo,
    int nuovoValore,
  ) async {
    await _repository.updateCampoInt(
      obj.tableName,
      obj.primaryKey,
      obj.id,
      campo,
      nuovoValore,
    );
  }

  // Replicating Java Controller.inserisciNuovoRecord logic
  Future<void> inserisciNuovoRecord(dynamic obj) async {
    // Logic from ModelDb.inserisciRecord delegates here based on type
    if (obj is Societa) {
      await _repository.insertSocieta(obj);
    } else if (obj is UnitaLocale) {
      await _repository.insertUnitaLocale(obj);
    } else if (obj is Reparto) {
      await _repository.insertReparto(obj);
    } else if (obj is Titolo) {
      await _repository.insertTitolo(obj);
    } else if (obj is Oggetto) {
      await _repository.insertOggetto(obj);
    } else if (obj is Provvedimento) {
      await _repository.insertProvvedimento(obj);
    } else {
      // throw ArgumentError("Unsupported type for insertion: ${obj.runtimeType}");
    }
  }
}
