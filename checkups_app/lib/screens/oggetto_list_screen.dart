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
import 'provvedimento_list_screen.dart';
import '../widgets/dialogs/oggetto_edit_dialog.dart';
import '../widgets/dialogs/import_dialog.dart';
import '../models/import_dtos.dart';

class OggettoListScreen extends StatefulWidget {
  final Societa societa;
  final UnitaLocale unitaLocale;
  final Reparto reparto;
  final Titolo titolo;

  const OggettoListScreen({super.key, required this.societa, required this.unitaLocale, required this.reparto, required this.titolo});

  @override
  State<OggettoListScreen> createState() => _OggettoListScreenState();
}

class _OggettoListScreenState extends State<OggettoListScreen> {
  late Future<List<Oggetto>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = context.read<DatabaseRepository>().getOggettoList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StandardScreenLayout(
      title: 'Oggetto',
      societa: widget.societa,
      unitaLocale: widget.unitaLocale,
      reparto: widget.reparto,
      titolo: widget.titolo,
      onBack: () => Navigator.pop(context),
      onAdd: () async {
        final result = await showDialog<Oggetto>(
          context: context,
          builder: (_) => OggettoEditDialog(idTitolo: widget.titolo.id),
        );
        if (result != null && mounted) {
          final repo = context.read<DatabaseRepository>();
          final currentList = await repo.getOggettoList();
          final maxId = currentList.isEmpty ? 0 : currentList.map((e) => e.id).reduce((a, b) => a > b ? a : b);

          final newOggetto = Oggetto(id: maxId + 1, idTitolo: result.idTitolo, priorita: result.priorita, nome: result.nome);

          await repo.insertOggetto(newOggetto);
          _refresh();
        }
      },
      onImport: () async {
        final repo = context.read<DatabaseRepository>();
        final candidates = await repo.getOggettiForImport();

        if (!mounted) return;

        final results = await showDialog<List<OggettoImportDto>>(
          context: context,
          builder: (ctx) => ImportDialog<OggettoImportDto>(
            title: 'Importa Oggetti',
            items: candidates,
            columns: [
              ImportColumn(title: 'Società', getValue: (item) => item.societaNome),
              ImportColumn(title: 'Unità Locale', getValue: (item) => item.unitaLocaleNome),
              ImportColumn(title: 'Reparto', getValue: (item) => item.repartoNome),
              ImportColumn(title: 'Titolo', getValue: (item) => item.titoloDescrizione),
              ImportColumn(title: 'Oggetto', getValue: (item) => item.oggetto.nome, flex: 2),
            ],
          ),
        );

        if (results != null && results.isNotEmpty && mounted) {
          final currentList = await repo.getOggettoList();
          int maxId = currentList.isEmpty ? 0 : currentList.map((e) => e.id).reduce((a, b) => a > b ? a : b);

          final maxProvIdResult = await repo.getProvvedimentoList();
          int nextProvId = maxProvIdResult.isEmpty ? 0 : maxProvIdResult.map((e) => e.id).reduce((a, b) => a > b ? a : b);

          for (final result in results) {
            maxId++;
            final newOggetto = Oggetto(id: maxId, idTitolo: widget.titolo.id, priorita: result.oggetto.priorita, nome: result.oggetto.nome);
            await repo.insertOggetto(newOggetto);

            // Recursive Import: Provvedimenti
            final provvedimenti = await repo.getProvvedimentiByOggettoId(result.oggetto.id);
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

          _refresh();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${results.length} oggetti importati con successo')));
          }
        }
      },
      onDelete: () {},
      child: FutureBuilder<List<Oggetto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];

          // Filter by Titolo
          final filteredList = list.where((o) => o.idTitolo == widget.titolo.id).toList();

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
                      child: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final oggetto = filteredList[index];
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
                              child: Text(oggetto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const PopupMenuItem(value: 'edit', child: Text('Modifica')),
                            const PopupMenuItem(value: 'delete', child: Text('Elimina')),
                          ],
                        ).then((value) async {
                          if (value == 'edit') {
                            final result = await showDialog<Oggetto>(
                              context: context,
                              builder: (_) => OggettoEditDialog(oggetto: oggetto),
                            );
                            if (result != null && mounted) {
                              await context.read<DatabaseRepository>().updateOggetto(result);
                              _refresh();
                            }
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Conferma Eliminazione'),
                                content: Text('Sei sicuro di voler eliminare l\'oggetto "${oggetto.nome}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Elimina')),
                                ],
                              ),
                            );
                            if (confirm == true && mounted) {
                              await context.read<DatabaseRepository>().deleteOggettoRecursive(oggetto.id);
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
                              builder: (_) => ProvvedimentoListScreen(
                                societa: widget.societa,
                                unitaLocale: widget.unitaLocale,
                                reparto: widget.reparto,
                                titolo: widget.titolo,
                                oggetto: oggetto,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(width: 40, child: Text('${index + 1}')),
                              Expanded(child: Text(oggetto.nome)),
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
