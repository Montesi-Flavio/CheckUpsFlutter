import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/database_repository.dart';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import '../models/reparto.dart';
import '../models/titolo.dart';
import '../models/oggetto.dart';
import '../models/provvedimento.dart';
import '../widgets/standard_screen_layout.dart';
import '../widgets/dialogs/provvedimento_edit_dialog.dart';
import '../widgets/dialogs/import_dialog.dart';
import '../models/import_dtos.dart';

class ProvvedimentoListScreen extends StatefulWidget {
  final Societa societa;
  final UnitaLocale unitaLocale;
  final Reparto reparto;
  final Titolo titolo;
  final Oggetto oggetto;

  const ProvvedimentoListScreen({
    super.key,
    required this.societa,
    required this.unitaLocale,
    required this.reparto,
    required this.titolo,
    required this.oggetto,
  });

  @override
  State<ProvvedimentoListScreen> createState() =>
      _ProvvedimentoListScreenState();
}

class _ProvvedimentoListScreenState extends State<ProvvedimentoListScreen> {
  late Future<List<Provvedimento>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = context.read<DatabaseRepository>().getProvvedimentoList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StandardScreenLayout(
      title: 'Rischi e Provvedimenti',
      societa: widget.societa,
      unitaLocale: widget.unitaLocale,
      reparto: widget.reparto,
      titolo: widget.titolo,
      oggetto: widget.oggetto,
      onBack: () => Navigator.pop(context),
      onAdd: () async {
        final result = await showDialog<Provvedimento>(
          context: context,
          builder: (_) => ProvvedimentoEditDialog(idOggetto: widget.oggetto.id),
        );
        if (result != null && mounted) {
          final repo = context.read<DatabaseRepository>();
          final currentList = await repo.getProvvedimentoList();
          final maxId = currentList.isEmpty
              ? 0
              : currentList.map((e) => e.id).reduce((a, b) => a > b ? a : b);

          final newProvvedimento = Provvedimento(
            id: maxId + 1,
            idOggetto: result.idOggetto,
            priorita: result.priorita,
            rischio: result.rischio,
            nome: result.nome,
            soggettiEsposti: result.soggettiEsposti,
            stimaD: result.stimaD,
            stimaP: result.stimaP,
            dataInizio: result.dataInizio,
            dataScadenza: result.dataScadenza,
          );

          await repo.insertProvvedimento(newProvvedimento);
          _refresh();
        }
      },
      onImport: () async {
        final repo = context.read<DatabaseRepository>();
        final candidates = await repo.getProvvedimentiForImport();

        if (!mounted) return;

        final results = await showDialog<List<ProvvedimentoImportDto>>(
          context: context,
          builder: (ctx) => ImportDialog<ProvvedimentoImportDto>(
            title: 'Importa Provvedimenti',
            items: candidates,
            columns: [
              ImportColumn(
                title: 'Società',
                getValue: (item) => item.societaNome,
              ),
              ImportColumn(
                title: 'Unità Locale',
                getValue: (item) => item.unitaLocaleNome,
              ),
              ImportColumn(
                title: 'Reparto',
                getValue: (item) => item.repartoNome,
              ),
              ImportColumn(
                title: 'Titolo',
                getValue: (item) => item.titoloDescrizione,
              ),
              ImportColumn(
                title: 'Oggetto',
                getValue: (item) => item.oggettoNome,
              ),
              ImportColumn(
                title: 'Rischio',
                getValue: (item) => item.provvedimento.rischio,
              ),
              ImportColumn(
                title: 'Misure',
                getValue: (item) => item.provvedimento.nome,
                flex: 2,
              ),
            ],
          ),
        );

        if (results != null && results.isNotEmpty && mounted) {
          final currentList = await repo.getProvvedimentoList();
          int maxId = currentList.isEmpty
              ? 0
              : currentList.map((e) => e.id).reduce((a, b) => a > b ? a : b);

          for (final result in results) {
            maxId++;
            final newProvvedimento = Provvedimento(
              id: maxId,
              idOggetto: widget.oggetto.id,
              priorita: result.provvedimento.priorita,
              rischio: result.provvedimento.rischio,
              nome: result.provvedimento.nome,
              soggettiEsposti: result.provvedimento.soggettiEsposti,
              stimaD: result.provvedimento.stimaD,
              stimaP: result.provvedimento.stimaP,
              dataInizio: result.provvedimento.dataInizio,
              dataScadenza: result.provvedimento.dataScadenza,
            );
            await repo.insertProvvedimento(newProvvedimento);
          }

          _refresh();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${results.length} provvedimenti importati con successo',
                ),
              ),
            );
          }
        }
      },
      onDelete: () {},
      child: FutureBuilder<List<Provvedimento>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];

          // Filter by Oggetto
          final filteredList = list
              .where((p) => p.idOggetto == widget.oggetto.id)
              .toList();

          return Column(
            children: [
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        'N°',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Rischio',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Misure di prevenzione e protezione',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Soggetti Esposti',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Stima',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Data...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final prov = filteredList[index];
                    return GestureDetector(
                      onSecondaryTapUp: (details) {
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                          ),
                          items: [
                            PopupMenuItem(
                              enabled: false,
                              child: Text(
                                prov.rischio,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Modifica'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Elimina'),
                            ),
                          ],
                        ).then((value) async {
                          if (value == 'edit') {
                            final result = await showDialog<Provvedimento>(
                              context: context,
                              builder: (_) =>
                                  ProvvedimentoEditDialog(provvedimento: prov),
                            );
                            if (result != null && mounted) {
                              await context
                                  .read<DatabaseRepository>()
                                  .updateProvvedimento(result);
                              _refresh();
                            }
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Conferma Eliminazione'),
                                content: Text(
                                  'Sei sicuro di voler eliminare il provvedimento?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Annulla'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Elimina'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && mounted) {
                              await context
                                  .read<DatabaseRepository>()
                                  .deleteRecord(
                                    'provvedimenti',
                                    'id_provvedimento',
                                    prov.id,
                                  );
                              _refresh();
                            }
                          }
                        });
                      },
                      child: InkWell(
                        onTap: () {
                          // Edit details
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 40, child: Text('${index + 1}')),
                              Expanded(flex: 1, child: Text(prov.rischio)),
                              Expanded(flex: 3, child: Text(prov.nome)),
                              const Expanded(
                                flex: 1,
                                child: Text(''),
                              ), // Soggetti placeholder
                              const Expanded(
                                flex: 1,
                                child: Text('0'),
                              ), // Stima placeholder
                              const Expanded(
                                flex: 1,
                                child: Text(''),
                              ), // Data placeholder
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
