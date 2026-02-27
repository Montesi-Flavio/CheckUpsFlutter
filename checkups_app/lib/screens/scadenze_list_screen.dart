import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../repositories/database_repository.dart';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import '../models/scadenza.dart';

class ScadenzeListScreen extends StatefulWidget {
  final Societa societa;
  final UnitaLocale unitaLocale;

  const ScadenzeListScreen({
    super.key,
    required this.societa,
    required this.unitaLocale,
  });

  @override
  State<ScadenzeListScreen> createState() => _ScadenzeListScreenState();
}

class _ScadenzeListScreenState extends State<ScadenzeListScreen> {
  late Future<List<Scadenza>> _future;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = context.read<DatabaseRepository>().getScadenzeByUnitaLocale(
        widget.unitaLocale.id,
      );
    });
  }

  Future<void> _showEditDialog([Scadenza? scadenza]) async {
    final isEditing = scadenza != null;
    final genereCtrl = TextEditingController(text: scadenza?.genere ?? '');
    final categoriaCtrl = TextEditingController(
      text: scadenza?.categoria ?? '',
    );
    final typeCtrl = TextEditingController(text: scadenza?.type ?? '');
    final periodicitaCtrl = TextEditingController(
      text: scadenza?.periodicita.toString() ?? '0',
    );
    final avvisoCtrl = TextEditingController(
      text: scadenza?.avvisoScadenza ?? '',
    );
    final noteCtrl = TextEditingController(text: scadenza?.note ?? '');

    DateTime? selectedDate = scadenza?.scadenza;
    bool preavvisoAssolto = scadenza?.preavvisoAssolto ?? false;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Modifica Scadenza' : 'Nuova Scadenza'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: genereCtrl,
                        decoration: const InputDecoration(labelText: 'Genere'),
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obbligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: categoriaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obbligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: typeCtrl,
                        decoration: const InputDecoration(labelText: 'Type'),
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obbligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: periodicitaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Periodicità (giorni/mesi etc)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? 'Nessuna data selezionata'
                                  : 'Scadenza: ${_dateFormat.format(selectedDate!)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: const Text('Seleziona Data'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: avvisoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Avviso Scadenza',
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obbligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Preavviso Assolto'),
                        value: preavvisoAssolto,
                        onChanged: (v) =>
                            setStateDialog(() => preavvisoAssolto = v ?? false),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noteCtrl,
                        decoration: const InputDecoration(labelText: 'Note'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final newScadenza = Scadenza(
                        id: scadenza?.id,
                        idUnitaLocale: widget.unitaLocale.id,
                        genere: genereCtrl.text,
                        categoria: categoriaCtrl.text,
                        type: typeCtrl.text,
                        periodicita: int.tryParse(periodicitaCtrl.text) ?? 0,
                        scadenza: selectedDate,
                        avvisoScadenza: avvisoCtrl.text,
                        preavvisoAssolto: preavvisoAssolto,
                        note: noteCtrl.text,
                      );

                      final repo = context.read<DatabaseRepository>();
                      try {
                        if (isEditing) {
                          await repo.updateScadenza(newScadenza);
                        } else {
                          await repo.insertScadenza(newScadenza);
                        }
                        if (mounted) {
                          Navigator.pop(context);
                          _refresh();
                        }
                      } catch (e, stackTrace) {
                        debugPrint('--- ERRORE SALVATAGGIO SCADENZA ---');
                        debugPrint('Eccezione: $e');
                        debugPrint('StackTrace: $stackTrace');
                        debugPrint('-----------------------------------');

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Errore: $e',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteScadenza(Scadenza scadenza) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questa scadenza?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<DatabaseRepository>().deleteScadenza(scadenza.id!);
        _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Errore durante l'eliminazione: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showRinnovaDialog(Scadenza scadenza) async {
    final mesiCtrl = TextEditingController(
      text: scadenza.periodicita.toString(),
    );
    DateTime selectedDate = scadenza.scadenza ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Rinnova Scadenza'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: mesiCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Periodicità (mesi)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obbligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Nuova Data: \${_dateFormat.format(selectedDate)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: const Text('Seleziona Data'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final newScadenza = Scadenza(
                        id: scadenza.id,
                        idUnitaLocale: scadenza.idUnitaLocale,
                        genere: scadenza.genere,
                        categoria: scadenza.categoria,
                        type: scadenza.type,
                        periodicita: int.tryParse(mesiCtrl.text) ?? 0,
                        scadenza: selectedDate,
                        avvisoScadenza: scadenza.avvisoScadenza,
                        preavvisoAssolto:
                            false, // Azzeriamo il preavviso assolto per il prossimo ciclo
                        note: scadenza.note,
                      );

                      try {
                        await context.read<DatabaseRepository>().updateScadenza(
                          newScadenza,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          _refresh();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Scadenza rinnovata con successo'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Errore: \$e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Rinnova'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Torna indietro',
                ),
                const SizedBox(width: 8),
                Text(
                  'Elenco Scadenze',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('NUOVA SCADENZA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () => _showEditDialog(),
                ),
              ],
            ),
          ),

          // Info Bar Societa & Unita Locale
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Text(
                  'Società',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.societa.nome,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 32),
                Text(
                  'Unità Locale',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.unitaLocale.nome,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<List<Scadenza>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nessuna scadenza trovata',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final sc = list[index];
                    final isScaduta =
                        sc.scadenza != null &&
                        sc.scadenza!.isBefore(DateTime.now());

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isScaduta ? Colors.red[50] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sc.genere,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Categoria: ${sc.categoria} | Type: ${sc.type} | Periodicità: ${sc.periodicita}',
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        size: 16,
                                        color: Colors.orange[700],
                                      ),
                                      Text('Avviso: ${sc.avvisoScadenza}'),
                                      const SizedBox(width: 12),
                                      Icon(
                                        sc.preavvisoAssolto
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 16,
                                        color: sc.preavvisoAssolto
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      Text(
                                        'Preavviso Assolto: ${sc.preavvisoAssolto ? "Sì" : "No"}',
                                      ),
                                    ],
                                  ),
                                  if (sc.note.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Note: ${sc.note}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  sc.scadenza != null
                                      ? _dateFormat.format(sc.scadenza!)
                                      : 'N/A',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isScaduta
                                        ? Colors.red[700]
                                        : theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: const Icon(Icons.autorenew, size: 18),
                                  label: const Text('Rinnova'),
                                  onPressed: () => _showRinnovaDialog(sc),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _showEditDialog(sc),
                                      tooltip: 'Modifica',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteScadenza(sc),
                                      tooltip: 'Elimina',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
