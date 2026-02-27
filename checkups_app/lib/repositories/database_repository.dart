import 'package:postgres/postgres.dart';
import 'dart:typed_data';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import '../models/titolo.dart';
import '../models/reparto.dart';
import '../models/oggetto.dart';
import '../models/provvedimento.dart';
import '../models/import_dtos.dart';
import '../models/scadenza.dart';
import '../models/genere_scadenza.dart';

class DatabaseRepository {
  late final Pool _pool;

  DatabaseRepository() {
    _pool = Pool.withEndpoints([
      Endpoint(host: 'localhost', database: 'checkups_db', username: 'postgres', password: 'postgres'),
    ], settings: PoolSettings(maxConnectionCount: 10, sslMode: SslMode.disable));
  }

  Future<void> close() async {
    await _pool.close();
  }

  Future<List<Societa>> getSocietaList() async {
    final result = await _pool.execute('SELECT * FROM public.societa');

    return result.map((row) {
      final map = row.toColumnMap();
      return Societa(
        id: map['id_societa'] as int,
        nome: map['nome'] as String,
        localita: map['localita'] as String,
        provincia: map['provincia'] as String,
        telefono: map['telefono'] as String,
        descrizione: map['descrizione'] as String?,
        indirizzo: map['indirizzo'] as String,
        partitaIva: map['partita_iva'] as String?,
        codiceFiscale: map['codice_fiscale'] as String?,
        bancaAppoggio: map['banca_appoggio'] as String?,
        codiceAteco: map['codice_ateco'] as String?,
        email: map['email'] as String?,
        logoBytes: map['logo'] as Uint8List?, // postgres driver returns Uint8List for bytea
      );
    }).toList();
  }

  Future<List<UnitaLocale>> getUnitaLocaleList() async {
    final result = await _pool.execute('SELECT * FROM public.unita_locali');

    return result.map((row) {
      final map = row.toColumnMap();
      return UnitaLocale(
        id: map['id_unita_locale'] as int,
        idSocieta: map['id_societa'] as int,
        nome: map['nome'] as String? ?? '',
        indirizzo: map['indirizzo'] as String? ?? '',
        localita: map['localita'] as String? ?? '',
        provincia: map['provincia'] as String? ?? '',
        telefono: map['telefono'] as String? ?? '',
        email: map['email'] as String?,
      );
    }).toList();
  }

  Future<List<Titolo>> getTitoloList() async {
    final result = await _pool.execute('SELECT * FROM public.titoli');
    return result.map((row) {
      final map = row.toColumnMap();
      return Titolo(
        id: map['id_titolo'] as int,
        idReparto: map['id_reparto'] as int,
        priorita: (map['priorita'] as int?) ?? 0,
        descrizione: map['descrizione'] as String? ?? '',
      );
    }).toList();
  }

  Future<List<Reparto>> getRepartoList() async {
    final result = await _pool.execute('SELECT * FROM public.reparti');
    return result.map((row) {
      final map = row.toColumnMap();
      return Reparto(
        id: map['id_reparto'] as int,
        idUnitaLocale: map['id_unita_locale'] as int,
        priorita: (map['priorita'] as int?) ?? 0,
        nome: map['nome'] as String? ?? '',
        descrizione: map['descrizione'] as String? ?? '',
        revisione: map['revisione'] as String? ?? '',
        data: map['data'] as DateTime?,
      );
    }).toList();
  }

  Future<List<Oggetto>> getOggettoList() async {
    final result = await _pool.execute('SELECT * FROM public.oggetti');
    return result.map((row) {
      final map = row.toColumnMap();
      return Oggetto(
        id: map['id_oggetto'] as int,
        priorita: (map['priorita'] as int?) ?? 0,
        nome: map['nome'] as String? ?? '',
        idTitolo: map['id_titolo'] as int,
      );
    }).toList();
  }

  Future<List<Provvedimento>> getProvvedimentoList() async {
    final result = await _pool.execute('SELECT * FROM public.provvedimenti');
    return result.map((row) {
      final map = row.toColumnMap();
      return Provvedimento(
        id: map['id_provvedimento'] as int,
        idOggetto: map['id_oggetto'] as int,
        priorita: (map['priorita'] as int?) ?? 0,
        rischio: map['rischio'] as String? ?? '',
        nome: map['nome'] as String? ?? '',
        soggettiEsposti: map['soggetti_esposti'] as String? ?? '',
        stimaD: (map['stima_d'] as int?) ?? 0,
        stimaP: (map['stima_p'] as int?) ?? 0,
        dataInizio: map['data_inizio'] as DateTime?,
        dataScadenza: map['data_scadenza'] as DateTime?,
      );
    }).toList();
  }

  Future<List<Provvedimento>> getProvvedimentiScaduti() async {
    final result = await _pool.execute('SELECT * FROM public.provvedimenti WHERE data_scadenza < CURRENT_DATE');
    return result.map((row) {
      final map = row.toColumnMap();
      return Provvedimento(
        id: map['id_provvedimento'] as int,
        idOggetto: map['id_oggetto'] as int,
        priorita: (map['priorita'] as int?) ?? 0,
        rischio: map['rischio'] as String? ?? '',
        nome: map['nome'] as String? ?? '',
        soggettiEsposti: map['soggetti_esposti'] as String? ?? '',
        stimaD: (map['stima_d'] as int?) ?? 0,
        stimaP: (map['stima_p'] as int?) ?? 0,
        dataInizio: map['data_inizio'] as DateTime?,
        dataScadenza: map['data_scadenza'] as DateTime?,
      );
    }).toList();
  }

  Future<List<GenereScadenza>> getGeneriScadenze() async {
    final result = await _pool.execute('SELECT id, title FROM public.generi_scadenze ORDER BY title ASC');
    return result.map((row) {
      final map = row.toColumnMap();
      return GenereScadenza(id: map['id'] as int, title: map['title'] as String);
    }).toList();
  }

  Future<List<Scadenza>> getScadenzeByUnitaLocale(int idUnitaLocale) async {
    final sql = '''
      SELECT s.*, g.title as titolo_genere 
      FROM public.scadenze_interventi s
      LEFT JOIN public.generi_scadenze g ON s.genere__id = g.id
      WHERE s.id_unita_locale = @id
    ''';
    final result = await _pool.execute(Sql.named(sql), parameters: {'id': idUnitaLocale});
    return result.map((row) {
      final map = row.toColumnMap();
      return Scadenza(
        id: map['id_scadenza'] as int,
        idUnitaLocale: map['id_unita_locale'] as int,
        idGenere: map['genere__id'] as int?,
        titoloGenere: map['titolo_genere'] as String?,
        categoria: map['categoria'] as String?,
        type: map['type'] as String?,
        periodicita: map['periodicita'] as int? ?? 1,
        scadenza: map['scadenza'] as DateTime?,
        avvisoScadenza: map['avviso_scadenza'] as String? ?? '',
        preavvisoAssolto: (map['preavviso_assolto'] as int? ?? 0) == 1,
        note: map['note'] as String? ?? '',
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getScadenzeForAutomatedEmail() async {
    // Cerchiamo le scadenze nei prossimi 20 giorni che non hanno il preavviso assolto
    // E facciamo una join con unita_locali e societa per prendere l'email
    final sql = '''
      SELECT s.id_scadenza, g.title as genere, s.categoria, s.type, s.scadenza,
             COALESCE(u.email, soc.email) as email
      FROM public.scadenze_interventi s
      LEFT JOIN public.generi_scadenze g ON s.genere__id = g.id
      LEFT JOIN public.unita_locali u ON s.id_unita_locale = u.id_unita_locale
      LEFT JOIN public.societa soc ON u.id_societa = soc.id_societa
      WHERE s.preavviso_assolto = 0 
        AND s.scadenza IS NOT NULL
        AND s.scadenza BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '20 days'
    ''';

    final result = await _pool.execute(sql);
    return result.map((row) => row.toColumnMap()).toList();
  }

  // *** Import Methods ***

  Future<List<TitoloImportDto>> getTitoliForImport() async {
    final sql = '''
      SELECT t.*, r.nome as reparto_nome, u.nome as unita_nome, s.nome as societa_nome
      FROM public.titoli t
      JOIN public.reparti r ON t.id_reparto = r.id_reparto
      JOIN public.unita_locali u ON r.id_unita_locale = u.id_unita_locale
      JOIN public.societa s ON u.id_societa = s.id_societa
    ''';
    final result = await _pool.execute(sql);
    return result.map((row) {
      final map = row.toColumnMap();
      return TitoloImportDto(
        titolo: Titolo(
          id: map['id_titolo'] as int,
          idReparto: map['id_reparto'] as int,
          priorita: (map['priorita'] as int?) ?? 0,
          descrizione: map['descrizione'] as String? ?? '',
        ),
        societaNome: map['societa_nome'] as String? ?? '',
        unitaLocaleNome: map['unita_nome'] as String? ?? '',
        repartoNome: map['reparto_nome'] as String? ?? '',
      );
    }).toList();
  }

  Future<List<OggettoImportDto>> getOggettiForImport() async {
    final sql = '''
      SELECT o.*, t.descrizione as titolo_desc, r.nome as reparto_nome, u.nome as unita_nome, s.nome as societa_nome
      FROM public.oggetti o
      JOIN public.titoli t ON o.id_titolo = t.id_titolo
      JOIN public.reparti r ON t.id_reparto = r.id_reparto
      JOIN public.unita_locali u ON r.id_unita_locale = u.id_unita_locale
      JOIN public.societa s ON u.id_societa = s.id_societa
    ''';
    final result = await _pool.execute(sql);
    return result.map((row) {
      final map = row.toColumnMap();
      return OggettoImportDto(
        oggetto: Oggetto(
          id: map['id_oggetto'] as int,
          priorita: (map['priorita'] as int?) ?? 0,
          nome: map['nome'] as String? ?? '',
          idTitolo: map['id_titolo'] as int,
        ),
        societaNome: map['societa_nome'] as String? ?? '',
        unitaLocaleNome: map['unita_nome'] as String? ?? '',
        repartoNome: map['reparto_nome'] as String? ?? '',
        titoloDescrizione: map['titolo_desc'] as String? ?? '',
      );
    }).toList();
  }

  Future<List<ProvvedimentoImportDto>> getProvvedimentiForImport() async {
    final sql = '''
      SELECT p.*, o.nome as oggetto_nome, t.descrizione as titolo_desc, r.nome as reparto_nome, u.nome as unita_nome, s.nome as societa_nome
      FROM public.provvedimenti p
      JOIN public.oggetti o ON p.id_oggetto = o.id_oggetto
      JOIN public.titoli t ON o.id_titolo = t.id_titolo
      JOIN public.reparti r ON t.id_reparto = r.id_reparto
      JOIN public.unita_locali u ON r.id_unita_locale = u.id_unita_locale
      JOIN public.societa s ON u.id_societa = s.id_societa
    ''';
    final result = await _pool.execute(sql);
    return result.map((row) {
      final map = row.toColumnMap();
      return ProvvedimentoImportDto(
        provvedimento: Provvedimento(
          id: map['id_provvedimento'] as int,
          idOggetto: map['id_oggetto'] as int,
          priorita: (map['priorita'] as int?) ?? 0,
          rischio: map['rischio'] as String? ?? '',
          nome: map['nome'] as String? ?? '',
          soggettiEsposti: map['soggetti_esposti'] as String? ?? '',
          stimaD: (map['stima_d'] as int?) ?? 0,
          stimaP: (map['stima_p'] as int?) ?? 0,
          dataInizio: map['data_inizio'] as DateTime?,
          dataScadenza: map['data_scadenza'] as DateTime?,
        ),
        societaNome: map['societa_nome'] as String? ?? '',
        unitaLocaleNome: map['unita_nome'] as String? ?? '',
        repartoNome: map['reparto_nome'] as String? ?? '',
        titoloDescrizione: map['titolo_desc'] as String? ?? '',
        oggettoNome: map['oggetto_nome'] as String? ?? '',
      );
    }).toList();
  }

  // *** Insert Methods ***

  Future<void> insertSocieta(Societa societa) async {
    // Get next ID
    final maxIdResult = await _pool.execute('SELECT COALESCE(MAX(id_societa), 0) + 1 as next_id FROM public.societa');
    final nextId = maxIdResult.first.toColumnMap()['next_id'] as int;

    await _pool.execute(
      Sql.named(
        'INSERT INTO public.societa (id_societa, nome, localita, provincia, telefono, descrizione, indirizzo, partita_iva, codice_fiscale, banca_appoggio, codice_ateco, email, logo) VALUES (@id, @nome, @localita, @provincia, @telefono, @descrizione, @indirizzo, @partitaIva, @codiceFiscale, @bancaAppoggio, @codiceAteco, @email, @logo:bytea)',
      ),
      parameters: {
        'id': nextId,
        'nome': societa.nome,
        'localita': societa.localita,
        'provincia': societa.provincia,
        'telefono': societa.telefono,
        'descrizione': societa.descrizione,
        'indirizzo': societa.indirizzo,
        'partitaIva': societa.partitaIva,
        'codiceFiscale': societa.codiceFiscale,
        'bancaAppoggio': societa.bancaAppoggio,
        'codiceAteco': societa.codiceAteco,
        'email': societa.email,
        'logo': societa.logoBytes,
      },
    );
  }

  Future<void> insertUnitaLocale(UnitaLocale unitaLocale) async {
    // Get next ID
    final maxIdResult = await _pool.execute('SELECT COALESCE(MAX(id_unita_locale), 0) + 1 as next_id FROM public.unita_locali');
    final nextId = maxIdResult.first.toColumnMap()['next_id'] as int;

    await _pool.execute(
      Sql.named(
        'INSERT INTO public.unita_locali (id_unita_locale, id_societa, nome, indirizzo, localita, provincia, telefono, email) VALUES (@id, @idSocieta, @nome, @indirizzo, @localita, @provincia, @telefono, @email)',
      ),
      parameters: {
        'id': nextId,
        'idSocieta': unitaLocale.idSocieta,
        'nome': unitaLocale.nome,
        'indirizzo': unitaLocale.indirizzo,
        'localita': unitaLocale.localita,
        'provincia': unitaLocale.provincia,
        'telefono': unitaLocale.telefono,
        'email': unitaLocale.email,
      },
    );
  }

  Future<void> insertReparto(Reparto reparto) async {
    await _pool.execute(
      Sql.named(
        'INSERT INTO public.reparti (id_reparto, id_unita_locale, priorita, nome, descrizione, revisione, data) VALUES (@id, @idUnitaLocale, @priorita, @nome, @descrizione, @revisione, @data)',
      ),
      parameters: {
        'id': reparto.id,
        'idUnitaLocale': reparto.idUnitaLocale,
        'priorita': reparto.priorita,
        'nome': reparto.nome,
        'descrizione': reparto.descrizione,
        'revisione': reparto.revisione,
        'data': reparto.data,
      },
    );
  }

  Future<void> insertTitolo(Titolo titolo) async {
    await _pool.execute(
      Sql.named('INSERT INTO public.titoli (id_titolo, id_reparto, priorita, descrizione) VALUES (@id, @idReparto, @priorita, @descrizione)'),
      parameters: {'id': titolo.id, 'idReparto': titolo.idReparto, 'priorita': titolo.priorita, 'descrizione': titolo.descrizione},
    );
  }

  Future<void> insertOggetto(Oggetto oggetto) async {
    await _pool.execute(
      Sql.named('INSERT INTO public.oggetti (id_oggetto, priorita, nome, id_titolo) VALUES (@id, @priorita, @nome, @idTitolo)'),
      parameters: {'id': oggetto.id, 'priorita': oggetto.priorita, 'nome': oggetto.nome, 'idTitolo': oggetto.idTitolo},
    );
  }

  Future<void> insertProvvedimento(Provvedimento provvedimento) async {
    await _pool.execute(
      Sql.named(
        'INSERT INTO public.provvedimenti (id_provvedimento, id_oggetto, priorita, rischio, nome, soggetti_esposti, stima_d, stima_p, data_inizio, data_scadenza) VALUES (@id, @idOggetto, @priorita, @rischio, @nome, @soggettiEsposti, @stimaD, @stimaP, @dataInizio, @dataScadenza)',
      ),
      parameters: {
        'id': provvedimento.id,
        'idOggetto': provvedimento.idOggetto,
        'priorita': provvedimento.priorita,
        'rischio': provvedimento.rischio,
        'nome': provvedimento.nome,
        'soggettiEsposti': provvedimento.soggettiEsposti,
        'stimaD': provvedimento.stimaD,
        'stimaP': provvedimento.stimaP,
        'dataInizio': provvedimento.dataInizio,
        'dataScadenza': provvedimento.dataScadenza,
      },
    );
  }

  Future<void> insertScadenza(Scadenza scadenza) async {
    final maxIdResult = await _pool.execute('SELECT COALESCE(MAX(id_scadenza), 0) + 1 as next_id FROM public.scadenze_interventi');
    final nextId = maxIdResult.first.toColumnMap()['next_id'] as int;

    await _pool.execute(
      Sql.named(
        'INSERT INTO public.scadenze_interventi (id_scadenza, id_unita_locale, genere__id, categoria, type, periodicita, scadenza, avviso_scadenza, preavviso_assolto, note) VALUES (@id, @idUnitaLocale, @genereId, @categoria, @type, @periodicita, @scadenza, @avvisoScadenza, @preavvisoAssolto, @note)',
      ),
      parameters: {
        'id': nextId,
        'idUnitaLocale': scadenza.idUnitaLocale,
        'genereId': scadenza.idGenere,
        'categoria': scadenza.categoria ?? '',
        'type': scadenza.type ?? '',
        'periodicita': scadenza.periodicita,
        'scadenza': scadenza.scadenza,
        'avvisoScadenza': scadenza.avvisoScadenza,
        'preavvisoAssolto': scadenza.preavvisoAssolto ? 1 : 0,
        'note': scadenza.note,
      },
    );
  }

  // *** Update Methods ***

  Future<void> updateCampoStringa(String tableName, String pkName, int id, String campo, String? value) async {
    await _pool.execute(Sql.named('UPDATE public.$tableName SET $campo = @value WHERE $pkName = @id'), parameters: {'id': id, 'value': value});
  }

  Future<void> updateCampoInt(String tableName, String pkName, int id, String campo, int value) async {
    await _pool.execute(Sql.named('UPDATE public.$tableName SET $campo = @value WHERE $pkName = @id'), parameters: {'id': id, 'value': value});
  }

  Future<void> updateCampoDate(String tableName, String pkName, int id, String campo, DateTime? value) async {
    await _pool.execute(Sql.named('UPDATE public.$tableName SET $campo = @value WHERE $pkName = @id'), parameters: {'id': id, 'value': value});
  }

  Future<void> updateCampoBinary(String tableName, String pkName, int id, String campo, Uint8List? value) async {
    await _pool.execute(Sql.named('UPDATE public.$tableName SET $campo = @value:bytea WHERE $pkName = @id'), parameters: {'id': id, 'value': value});
  }

  Future<void> updateSocieta(Societa societa) async {
    await _pool.execute(
      Sql.named(
        'UPDATE public.societa SET nome = @nome, localita = @localita, provincia = @provincia, telefono = @telefono, descrizione = @descrizione, indirizzo = @indirizzo, partita_iva = @partitaIva, codice_fiscale = @codiceFiscale, banca_appoggio = @bancaAppoggio, codice_ateco = @codiceAteco, email = @email, logo = @logo:bytea WHERE id_societa = @id',
      ),
      parameters: {
        'id': societa.id,
        'nome': societa.nome,
        'localita': societa.localita,
        'provincia': societa.provincia,
        'telefono': societa.telefono,
        'descrizione': societa.descrizione,
        'indirizzo': societa.indirizzo,
        'partitaIva': societa.partitaIva,
        'codiceFiscale': societa.codiceFiscale,
        'bancaAppoggio': societa.bancaAppoggio,
        'codiceAteco': societa.codiceAteco,
        'email': societa.email,
        'logo': societa.logoBytes,
      },
    );
  }

  Future<void> updateUnitaLocale(UnitaLocale unitaLocale) async {
    await _pool.execute(
      Sql.named(
        'UPDATE public.unita_locali SET id_societa = @idSocieta, nome = @nome, indirizzo = @indirizzo, localita = @localita, provincia = @provincia, telefono = @telefono, email = @email WHERE id_unita_locale = @id',
      ),
      parameters: {
        'id': unitaLocale.id,
        'idSocieta': unitaLocale.idSocieta,
        'nome': unitaLocale.nome,
        'indirizzo': unitaLocale.indirizzo,
        'localita': unitaLocale.localita,
        'provincia': unitaLocale.provincia,
        'telefono': unitaLocale.telefono,
        'email': unitaLocale.email,
      },
    );
  }

  Future<void> updateReparto(Reparto reparto) async {
    await _pool.execute(
      Sql.named(
        'UPDATE public.reparti SET priorita = @priorita, nome = @nome, descrizione = @descrizione, revisione = @revisione, data = @data WHERE id_reparto = @id',
      ),
      parameters: {
        'id': reparto.id,
        'priorita': reparto.priorita,
        'nome': reparto.nome,
        'descrizione': reparto.descrizione,
        'revisione': reparto.revisione,
        'data': reparto.data,
      },
    );
  }

  Future<void> updateTitolo(Titolo titolo) async {
    await _pool.execute(
      Sql.named('UPDATE public.titoli SET priorita = @priorita, descrizione = @descrizione WHERE id_titolo = @id'),
      parameters: {'id': titolo.id, 'priorita': titolo.priorita, 'descrizione': titolo.descrizione},
    );
  }

  Future<void> updateOggetto(Oggetto oggetto) async {
    await _pool.execute(
      Sql.named('UPDATE public.oggetti SET priorita = @priorita, nome = @nome WHERE id_oggetto = @id'),
      parameters: {'id': oggetto.id, 'priorita': oggetto.priorita, 'nome': oggetto.nome},
    );
  }

  Future<void> updateProvvedimento(Provvedimento provvedimento) async {
    await _pool.execute(
      Sql.named(
        'UPDATE public.provvedimenti SET priorita = @priorita, rischio = @rischio, nome = @nome, soggetti_esposti = @soggettiEsposti, stima_d = @stimaD, stima_p = @stimaP, data_inizio = @dataInizio, data_scadenza = @dataScadenza WHERE id_provvedimento = @id',
      ),
      parameters: {
        'id': provvedimento.id,
        'priorita': provvedimento.priorita,
        'rischio': provvedimento.rischio,
        'nome': provvedimento.nome,
        'soggettiEsposti': provvedimento.soggettiEsposti,
        'stimaD': provvedimento.stimaD,
        'stimaP': provvedimento.stimaP,
        'dataInizio': provvedimento.dataInizio,
        'dataScadenza': provvedimento.dataScadenza,
      },
    );
  }

  Future<void> updateScadenza(Scadenza scadenza) async {
    await _pool.execute(
      Sql.named(
        'UPDATE public.scadenze_interventi SET id_unita_locale = @idUnitaLocale, genere__id = @genereId, categoria = @categoria, type = @type, periodicita = @periodicita, scadenza = @scadenza, avviso_scadenza = @avvisoScadenza, preavviso_assolto = @preavvisoAssolto, note = @note WHERE id_scadenza = @id',
      ),
      parameters: {
        'id': scadenza.id,
        'idUnitaLocale': scadenza.idUnitaLocale,
        'genereId': scadenza.idGenere,
        'categoria': scadenza.categoria ?? '',
        'type': scadenza.type ?? '',
        'periodicita': scadenza.periodicita,
        'scadenza': scadenza.scadenza,
        'avvisoScadenza': scadenza.avvisoScadenza,
        'preavvisoAssolto': scadenza.preavvisoAssolto ? 1 : 0,
        'note': scadenza.note,
      },
    );
  }

  Future<void> markPreavvisoAssolto(int idScadenza) async {
    await _pool.execute(Sql.named('UPDATE public.scadenze_interventi SET preavviso_assolto = 1 WHERE id_scadenza = @id'), parameters: {'id': idScadenza});
  }

  // *** Fetch Children Methods for Deep Import ***

  Future<List<Oggetto>> getOggettiByTitoloId(int idTitolo) async {
    final result = await _pool.execute(Sql.named('SELECT * FROM public.oggetti WHERE id_titolo = @id'), parameters: {'id': idTitolo});
    return result.map((row) {
      final map = row.toColumnMap();
      return Oggetto(
        id: map['id_oggetto'] as int,
        priorita: (map['priorita'] as int?) ?? 0,
        nome: map['nome'] as String? ?? '',
        idTitolo: map['id_titolo'] as int,
      );
    }).toList();
  }

  Future<List<Provvedimento>> getProvvedimentiByOggettoId(int idOggetto) async {
    final result = await _pool.execute(Sql.named('SELECT * FROM public.provvedimenti WHERE id_oggetto = @id'), parameters: {'id': idOggetto});
    return result.map((row) {
      final map = row.toColumnMap();
      return Provvedimento(
        id: map['id_provvedimento'] as int,
        idOggetto: map['id_oggetto'] as int,
        priorita: (map['priorita'] as int?) ?? 0,
        rischio: map['rischio'] as String? ?? '',
        nome: map['nome'] as String? ?? '',
        soggettiEsposti: map['soggetti_esposti'] as String? ?? '',
        stimaD: (map['stima_d'] as int?) ?? 0,
        stimaP: (map['stima_p'] as int?) ?? 0,
        dataInizio: map['data_inizio'] as DateTime?,
        dataScadenza: map['data_scadenza'] as DateTime?,
      );
    }).toList();
  }

  // *** Delete Methods ***

  Future<void> deleteSocieta(int id) async {
    await deleteRecord('societa', 'id_societa', id);
  }

  Future<void> deleteUnitaLocale(int id) async {
    await deleteRecord('unita_locali', 'id_unita_locale', id);
  }

  Future<void> deleteScadenza(int id) async {
    await deleteRecord('scadenze_interventi', 'id_scadenza', id);
  }

  Future<void> deleteRecord(String tableName, String pkName, int id) async {
    await _pool.execute(Sql.named('DELETE FROM public.$tableName WHERE $pkName = @id'), parameters: {'id': id});
  }

  // *** Recursive Delete Methods ***

  Future<void> deleteOggettoRecursive(int idOggetto) async {
    // Delete Provvedimenti associated with this Oggetto
    await _pool.execute(Sql.named('DELETE FROM public.provvedimenti WHERE id_oggetto = @id'), parameters: {'id': idOggetto});
    // Delete the Oggetto itself
    await deleteRecord('oggetti', 'id_oggetto', idOggetto);
  }

  Future<void> deleteTitoloRecursive(int idTitolo) async {
    // Delete Provvedimenti indirectly associated via Oggetti
    await _pool.execute(
      Sql.named('DELETE FROM public.provvedimenti WHERE id_oggetto IN (SELECT id_oggetto FROM public.oggetti WHERE id_titolo = @id)'),
      parameters: {'id': idTitolo},
    );
    // Delete Oggetti associated with this Titolo
    await _pool.execute(Sql.named('DELETE FROM public.oggetti WHERE id_titolo = @id'), parameters: {'id': idTitolo});
    // Delete the Titolo itself
    await deleteRecord('titoli', 'id_titolo', idTitolo);
  }

  Future<void> deleteRepartoRecursive(int idReparto) async {
    // Delete Provvedimenti indirectly associated via Oggetti -> Titoli
    await _pool.execute(
      Sql.named('''
        DELETE FROM public.provvedimenti 
        WHERE id_oggetto IN (
          SELECT o.id_oggetto 
          FROM public.oggetti o
          JOIN public.titoli t ON o.id_titolo = t.id_titolo
          WHERE t.id_reparto = @id
        )
      '''),
      parameters: {'id': idReparto},
    );
    // Delete Oggetti indirectly associated via Titoli
    await _pool.execute(
      Sql.named('DELETE FROM public.oggetti WHERE id_titolo IN (SELECT id_titolo FROM public.titoli WHERE id_reparto = @id)'),
      parameters: {'id': idReparto},
    );
    // Delete Titoli associated with this Reparto
    await _pool.execute(Sql.named('DELETE FROM public.titoli WHERE id_reparto = @id'), parameters: {'id': idReparto});
    // Delete the Reparto itself
    await deleteRecord('reparti', 'id_reparto', idReparto);
  }
}
