import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../repositories/database_repository.dart';
import '../models/provvedimento.dart';

class ScadenzeScreen extends StatefulWidget {
  const ScadenzeScreen({super.key});

  @override
  State<ScadenzeScreen> createState() => _ScadenzeScreenState();
}

class _ScadenzeScreenState extends State<ScadenzeScreen> {
  late Future<List<Provvedimento>> _future;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = context.read<DatabaseRepository>().getProvvedimentiScaduti();
    });
  }

  String _formatProvvedimento(Provvedimento p) {
    final scadenza = p.dataScadenza != null ? _dateFormat.format(p.dataScadenza!) : 'N/A';
    return '${p.nome} - Rischio: ${p.rischio} - Scadenza: $scadenza';
  }

  Future<void> _copyAll(List<Provvedimento> list) async {
    final text = list.map(_formatProvvedimento).join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provvedimenti copiati negli appunti'), backgroundColor: Colors.green));
    }
  }

  Future<void> _exportToFile(List<Provvedimento> list) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Salva elenco scadenze',
      fileName: 'scadenze_${DateFormat('yyyyMMdd').format(DateTime.now())}.txt',
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv'],
    );

    if (result != null) {
      final file = File(result);
      final content = StringBuffer();
      content.writeln('PROVVEDIMENTI SCADUTI - ${_dateFormat.format(DateTime.now())}');
      content.writeln('=' * 60);
      content.writeln();

      for (int i = 0; i < list.length; i++) {
        final p = list[i];
        content.writeln('${i + 1}. ${p.nome}');
        content.writeln('   Rischio: ${p.rischio}');
        content.writeln('   Soggetti Esposti: ${p.soggettiEsposti}');
        content.writeln('   Data Scadenza: ${p.dataScadenza != null ? _dateFormat.format(p.dataScadenza!) : 'N/A'}');
        content.writeln();
      }

      await file.writeAsString(content.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File salvato: ${file.path}'), backgroundColor: Colors.green));
      }
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 32),
                const SizedBox(width: 12),
                Text(
                  'Provvedimenti Scaduti',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context), tooltip: 'Chiudi'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: FutureBuilder<List<Provvedimento>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('Errore: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
                        const SizedBox(height: 16),
                        Text('Nessun provvedimento scaduto', style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text('Tutti i provvedimenti sono in regola!', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    Column(
                      children: [
                        // Table Header
                        Container(
                          color: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text('N°', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('Rischio', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('Soggetti Esposti', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('Scadenza', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                        // List
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final prov = list[index];
                              final isOverdue = prov.dataScadenza != null && DateTime.now().difference(prov.dataScadenza!).inDays > 30;

                              return Container(
                                color: isOverdue ? Colors.red[50] : null,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    SizedBox(width: 50, child: Text('${index + 1}')),
                                    Expanded(flex: 3, child: Text(prov.nome)),
                                    Expanded(flex: 2, child: Text(prov.rischio)),
                                    Expanded(flex: 2, child: Text(prov.soggettiEsposti)),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16, color: isOverdue ? Colors.red : Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            prov.dataScadenza != null ? _dateFormat.format(prov.dataScadenza!) : 'N/A',
                                            style: TextStyle(
                                              color: isOverdue ? Colors.red : Colors.orange[800],
                                              fontWeight: isOverdue ? FontWeight.bold : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Action Buttons (bottom right)
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: Row(
                        children: [
                          FloatingActionButton.extended(
                            heroTag: 'copy',
                            onPressed: () => _copyAll(list),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copia Tutti'),
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          const SizedBox(width: 16),
                          FloatingActionButton.extended(
                            heroTag: 'export',
                            onPressed: () => _exportToFile(list),
                            icon: const Icon(Icons.file_download),
                            label: const Text('Esporta'),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
