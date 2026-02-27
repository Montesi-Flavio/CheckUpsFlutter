import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../repositories/database_repository.dart';
import '../services/pdf_service.dart';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import '../models/reparto.dart';
import 'home_screen.dart';
import 'societa_edit_screen.dart';

class ValutazioneRischiScreen extends StatefulWidget {
  final Societa societa;
  final UnitaLocale unitaLocale;

  const ValutazioneRischiScreen({
    super.key,
    required this.societa,
    required this.unitaLocale,
  });

  @override
  State<ValutazioneRischiScreen> createState() =>
      _ValutazioneRischiScreenState();
}

class _ValutazioneRischiScreenState extends State<ValutazioneRischiScreen> {
  late Future<List<Reparto>> _future;
  final List<Reparto> _allReparti = [];
  String _filterText = '';
  final TextEditingController _filterController = TextEditingController();
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _future = context.read<DatabaseRepository>().getRepartoList();
    });
  }

  List<Reparto> _filterList(List<Reparto> list) {
    // Filter by UnitaLocale
    var filtered = list
        .where((r) => r.idUnitaLocale == widget.unitaLocale.id)
        .toList();

    // Apply text filter
    if (_filterText.isNotEmpty) {
      filtered = filtered
          .where(
            (r) =>
                r.nome.toLowerCase().contains(_filterText.toLowerCase()) ||
                r.descrizione.toLowerCase().contains(_filterText.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  Future<void> _creaPdf() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un reparto da stampare'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Filter selected reparti from stored list
    final selectedReparti = _allReparti
        .where((r) => _selectedIds.contains(r.id))
        .toList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creazione PDF per ${selectedReparti.length} reparti...'),
        backgroundColor: Colors.blue,
      ),
    );

    try {
      final repo = context.read<DatabaseRepository>();
      final pdfService = PdfService(repo);

      final pdfBytes = await pdfService.generaValutazioneRischi(
        societa: widget.societa,
        unitaLocale: widget.unitaLocale,
        reparti: selectedReparti,
      );

      // Ask user where to save
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Salva PDF Valutazione Rischi',
        fileName:
            'ValutazioneRischi_${widget.societa.nome}_${widget.unitaLocale.nome}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(pdfBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF salvato: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll(List<Reparto> list) {
    setState(() {
      if (_selectedIds.length == list.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.clear();
        _selectedIds.addAll(list.map((r) => r.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Header with logo and nav buttons
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
                // Logo
                Image.asset(
                  'assets/LOGOCheckUp.png',
                  height: 64,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 32),
                // HOME button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  ),
                  child: const Text(
                    'HOME',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                // CREA / MODIFICA button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SocietaEditScreen(initialSocieta: widget.societa),
                    ),
                  ),
                  child: const Text(
                    'CREA / MODIFICA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          // Società and Unità Locale info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.grey[100],
            child: Row(
              children: [
                // Società
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
                const Spacer(),
                // Unità Locale
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

          // Toolbar: Crea PDF + Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                // Crea PDF button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _creaPdf,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Crea PDF'),
                ),
                const SizedBox(width: 32),
                // Filter icon
                Icon(Icons.filter_alt_outlined, color: Colors.grey[600]),
                const SizedBox(width: 8),
                // Filter text field
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _filterController,
                    decoration: InputDecoration(
                      hintText: 'Filtra per nome...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filterText = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: FutureBuilder<List<Reparto>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                }

                // Store all reparti for PDF generation
                final allData = snapshot.data ?? [];
                _allReparti.clear();
                _allReparti.addAll(allData);
                final list = _filterList(allData);

                return Column(
                  children: [
                    // Table Header
                    Container(
                      color: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Checkbox(
                              value:
                                  list.isNotEmpty &&
                                  _selectedIds.length == list.length,
                              tristate: true,
                              onChanged: (_) => _toggleSelectAll(list),
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                            child: Text(
                              'N°',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Reparto',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Descrizione',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table Body
                    Expanded(
                      child: list.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nessun reparto trovato',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: Colors.grey[300]),
                              itemBuilder: (context, index) {
                                final reparto = list[index];
                                final isSelected = _selectedIds.contains(
                                  reparto.id,
                                );
                                return InkWell(
                                  onTap: () => _toggleSelection(reparto.id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue[50]
                                          : (index.isEven
                                                ? Colors.white
                                                : Colors.grey[50]),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          child: Checkbox(
                                            value: isSelected,
                                            onChanged: (_) =>
                                                _toggleSelection(reparto.id),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: Text('$index'),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(reparto.nome),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(reparto.descrizione),
                                        ),
                                      ],
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
          ),
        ],
      ),
    );
  }
}
