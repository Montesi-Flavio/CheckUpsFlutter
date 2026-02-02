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
import 'oggetto_list_screen.dart';
import '../widgets/dialogs/titolo_edit_dialog.dart';
import '../widgets/dialogs/import_dialog.dart';
import '../models/import_dtos.dart';

class TitoloListScreen extends StatefulWidget {
  final Societa societa;
  final UnitaLocale unitaLocale;
  final Reparto reparto;

  const TitoloListScreen({super.key, required this.societa, required this.unitaLocale, required this.reparto});

  @override
  State<TitoloListScreen> createState() => _TitoloListScreenState();
}

class _TitoloListScreenState extends State<TitoloListScreen> {
  late Future<List<Titolo>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = context.read<DatabaseRepository>().getTitoloList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StandardScreenLayout(
      title: 'Titoli D.Lgs. 81/08', // Dynamic title?
      societa: widget.societa,
      unitaLocale: widget.unitaLocale,
      reparto: widget.reparto,
      onBack: () => Navigator.pop(context),
      onAdd: () async {
        final result = await showDialog<Titolo>(
          context: context,
          builder: (_) => TitoloEditDialog(idReparto: widget.reparto.id),
        );
        if (result != null && mounted) {
          final repo = context.read<DatabaseRepository>();
          final currentList = await repo.getTitoloList();
          final maxId = currentList.isEmpty ? 0 : currentList.map((e) => e.id).reduce((a, b) => a > b ? a : b);

          final newTitolo = Titolo(id: maxId + 1, idReparto: result.idReparto, priorita: result.priorita, descrizione: result.descrizione);

          await repo.insertTitolo(newTitolo);
          _refresh();
        }
      },
      onImport: () async {
        final repo = context.read<DatabaseRepository>();
        final candidates = await repo.getTitoliForImport();

        if (!mounted) return;

        final results = await showDialog<List<TitoloImportDto>>(
          context: context,
          builder: (ctx) => ImportDialog<TitoloImportDto>(
            title: 'Importa Titoli',
            items: candidates,
            columns: [
              ImportColumn(title: 'Società', getValue: (item) => item.societaNome),
              ImportColumn(title: 'Unità Locale', getValue: (item) => item.unitaLocaleNome),
              ImportColumn(title: 'Reparto', getValue: (item) => item.repartoNome),
              ImportColumn(title: 'Titolo', getValue: (item) => item.titolo.descrizione, flex: 2),
            ],
          ),
        );

        if (results != null && results.isNotEmpty && mounted) {
          final currentList = await repo.getTitoloList();
          int maxId = currentList.isEmpty ? 0 : currentList.map((e) => e.id).reduce((a, b) => a > b ? a : b);

          for (final result in results) {
            maxId++;
            final newTitolo = Titolo(id: maxId, idReparto: widget.reparto.id, priorita: result.titolo.priorita, descrizione: result.titolo.descrizione);
            await repo.insertTitolo(newTitolo);

            // Recursive Import: Oggetti
            final oggetti = await repo.getOggettiByTitoloId(result.titolo.id);
            if (oggetti.isNotEmpty) {
              final maxOggettoIdResult = await repo.getOggettoList();
              int nextOggettoId = maxOggettoIdResult.isEmpty ? 0 : maxOggettoIdResult.map((e) => e.id).reduce((a, b) => a > b ? a : b);

              final maxProvIdResult = await repo.getProvvedimentoList();
              int nextProvId = maxProvIdResult.isEmpty ? 0 : maxProvIdResult.map((e) => e.id).reduce((a, b) => a > b ? a : b);

              for (final oggetto in oggetti) {
                nextOggettoId++;
                final newOggetto = Oggetto(id: nextOggettoId, idTitolo: newTitolo.id, priorita: oggetto.priorita, nome: oggetto.nome);
                await repo.insertOggetto(newOggetto);

                // Recursive Import: Provvedimenti
                final provvedimenti = await repo.getProvvedimentiByOggettoId(oggetto.id);
                if (provvedimenti.isNotEmpty) {
                  for (final prov in provvedimenti) {
                    nextProvId++;
                    final newProv = Provvedimento(
                      id: nextProvId,
                      idOggetto: newOggetto.id,
                      priorita: prov.priorita,
                      rischio: prov.rischio,
                      nome: prov.nome,
                      soggettiEsposti: prov.soggettiEsposti,
                      stimaD: prov.stimaD,
                      stimaP: prov.stimaP,
                      dataInizio: prov.dataInizio,
                      dataScadenza: prov.dataScadenza,
                    );
                    await repo.insertProvvedimento(newProv);
                  }
                }
              }
            }
          }

          _refresh();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${results.length} titoli importati con successo')));
          }
        }
      },
      onDelete: () {},
      child: FutureBuilder<List<Titolo>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];

          // Filter by Reparto
          final filteredList = list.where((t) => t.idReparto == widget.reparto.id).toList();

          return Column(
            children: [
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text('N°', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final titolo = filteredList[index];
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
                              child: Text(titolo.descrizione, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const PopupMenuItem(value: 'edit', child: Text('Modifica')),
                            const PopupMenuItem(value: 'delete', child: Text('Elimina')),
                          ],
                        ).then((value) async {
                          if (value == 'edit') {
                            final result = await showDialog<Titolo>(
                              context: context,
                              builder: (_) => TitoloEditDialog(titolo: titolo),
                            );
                            if (result != null && mounted) {
                              await context.read<DatabaseRepository>().updateTitolo(result);
                              _refresh();
                            }
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Conferma Eliminazione'),
                                content: Text('Sei sicuro di voler eliminare il titolo "${titolo.descrizione}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Elimina')),
                                ],
                              ),
                            );
                            if (confirm == true && mounted) {
                              await context.read<DatabaseRepository>().deleteTitoloRecursive(titolo.id);
                              _refresh();
                            }
                          }
                        });
                      },
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OggettoListScreen(societa: widget.societa, unitaLocale: widget.unitaLocale, reparto: widget.reparto, titolo: titolo),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(width: 40, child: Text('${index + 1}')), // Or priorita
                              Expanded(child: Text(titolo.descrizione)),
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
