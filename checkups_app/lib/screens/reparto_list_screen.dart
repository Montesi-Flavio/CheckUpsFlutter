import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/database_repository.dart';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import '../models/reparto.dart';
import '../widgets/standard_screen_layout.dart';
import 'titolo_list_screen.dart';
import '../widgets/dialogs/reparto_edit_dialog.dart';

class RepartoListScreen extends StatefulWidget {
  final Societa societa;
  final UnitaLocale unitaLocale;

  const RepartoListScreen({super.key, required this.societa, required this.unitaLocale});

  @override
  State<RepartoListScreen> createState() => _RepartoListScreenState();
}

class _RepartoListScreenState extends State<RepartoListScreen> {
  late Future<List<Reparto>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = context.read<DatabaseRepository>().getRepartoList();
      // TODO: Filter by UnitaLocale ID when backend supports it or manually filter here
      // For now fetching all and filtering in memory or assuming mock data matches
    });
  }

  @override
  Widget build(BuildContext context) {
    return StandardScreenLayout(
      title: 'Reparti',
      societa: widget.societa,
      unitaLocale: widget.unitaLocale,
      onBack: () => Navigator.pop(context),
      onAdd: () async {
        final result = await showDialog<Reparto>(
          context: context,
          builder: (_) => RepartoEditDialog(idUnitaLocale: widget.unitaLocale.id),
        );
        if (result != null && mounted) {
          final repo = context.read<DatabaseRepository>();
          final currentList = await repo.getRepartoList();
          final maxId = currentList.isEmpty ? 0 : currentList.map((e) => e.id).reduce((a, b) => a > b ? a : b);

          final newReparto = Reparto(
            id: maxId + 1,
            idUnitaLocale: result.idUnitaLocale,
            priorita: result.priorita,
            nome: result.nome,
            descrizione: result.descrizione,
            revisione: result.revisione,
            data: result.data,
          );

          await repo.insertReparto(newReparto);
          _refresh();
        }
      },
      onDelete: () {},
      child: FutureBuilder<List<Reparto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];
          // Filter by UnitaLocale
          final filteredList = list.where((r) => r.idUnitaLocale == widget.unitaLocale.id).toList();

          return Column(
            children: [
              // Header Row
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
                    Expanded(
                      child: Text('Revisione', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    final reparto = filteredList[index];
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
                              child: Text(reparto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const PopupMenuItem(value: 'edit', child: Text('Modifica')),
                            const PopupMenuItem(value: 'delete', child: Text('Elimina')),
                          ],
                        ).then((value) async {
                          if (value == 'edit') {
                            final result = await showDialog<Reparto>(
                              context: context,
                              builder: (_) => RepartoEditDialog(reparto: reparto),
                            );
                            if (result != null && mounted) {
                              await context.read<DatabaseRepository>().updateReparto(result);
                              _refresh();
                            }
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Conferma Eliminazione'),
                                content: Text('Sei sicuro di voler eliminare il reparto "${reparto.nome}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Elimina')),
                                ],
                              ),
                            );
                            if (confirm == true && mounted) {
                              await context.read<DatabaseRepository>().deleteRepartoRecursive(reparto.id);
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
                              builder: (_) => TitoloListScreen(societa: widget.societa, unitaLocale: widget.unitaLocale, reparto: reparto),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(width: 40, child: Text('${reparto.id}')),
                              Expanded(child: Text(reparto.nome)),
                              Expanded(child: Text(reparto.revisione)),
                              const Expanded(child: Text('')), // Data placeholder
                              const Expanded(child: Text('')), // Descrizione placeholder
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
