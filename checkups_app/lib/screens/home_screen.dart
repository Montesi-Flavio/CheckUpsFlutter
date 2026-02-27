import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/database_repository.dart';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import 'societa_edit_screen.dart';
import 'scadenze_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'valutazione_rischi_screen.dart';
import 'scadenze_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  Societa? _selectedSocieta;
  UnitaLocale? _selectedUnitaLocale;

  List<Societa> _societaList = [];
  List<UnitaLocale> _unitaLocaleList = [];
  bool _isLoading = true;

  static const String _scadenzeShownKey = 'scadenze_shown_once';

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadData();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Conferma Uscita'),
            content: const Text('Sei sicuro di voler chiudere l\'applicazione?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () async {
                  Navigator.pop(context);
                  await windowManager.destroy();
                },
                child: const Text('Esci'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loadData() async {
    final repo = context.read<DatabaseRepository>();
    try {
      final societa = await repo.getSocietaList();
      final unitaLocali = await repo.getUnitaLocaleList();

      setState(() {
        _societaList = societa;
        _unitaLocaleList = unitaLocali;
        _isLoading = false;
      });

      // Check for expired provvedimenti - show ScadenzeScreen only the first time
      final prefs = await SharedPreferences.getInstance();
      final alreadyShown = prefs.getBool(_scadenzeShownKey) ?? false;

      if (!alreadyShown) {
        final scaduti = await repo.getProvvedimentiScaduti();
        if (scaduti.isNotEmpty && mounted) {
          await prefs.setBool(_scadenzeShownKey, true);
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ScadenzeScreen()));
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<UnitaLocale> get _filteredUnitaLocali {
    if (_selectedSocieta == null) return [];
    return _unitaLocaleList.where((u) => u.idSocieta == _selectedSocieta!.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      // Logo
                      Image.asset('assets/LOGOCheckUp.png', height: 64, fit: BoxFit.contain),
                      const Spacer(),
                      // Nav Buttons
                      _NavButton(text: 'HOME', isActive: true, onPressed: () {}),
                      const SizedBox(width: 16),
                      _NavButton(
                        text: 'CREA / MODIFICA',
                        isActive: false,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SocietaEditScreen(initialSocieta: _selectedSocieta))),
                      ),
                      const SizedBox(width: 16),
                      _NavButton(
                        text: 'SCADENZE\n INTERVENTI',
                        isActive: false,
                        onPressed: () {
                          if (_selectedSocieta == null || _selectedUnitaLocale == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Seleziona Società e Unità Locale prima di procedere'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScadenzeListScreen(societa: _selectedSocieta!, unitaLocale: _selectedUnitaLocale!),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.all(32),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Benvenuto',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            const Text('Seleziona Società e Unità Locale per iniziare', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 32),

                            _buildDropdown<Societa>(
                              label: 'Società - Ente',
                              value: _selectedSocieta,
                              items: _societaList,
                              onChanged: (val) {
                                setState(() {
                                  _selectedSocieta = val;
                                  _selectedUnitaLocale = null;
                                });
                              },
                              itemLabelBuilder: (s) => s.nome,
                              icon: Icons.business,
                            ),
                            const SizedBox(height: 24),
                            _buildDropdown<UnitaLocale>(
                              key: ValueKey(_selectedSocieta?.id),
                              label: 'Unità Locale',
                              value: _selectedUnitaLocale,
                              items: _filteredUnitaLocali,
                              onChanged: (val) => setState(() => _selectedUnitaLocale = val),
                              itemLabelBuilder: (u) => u.nome,
                              icon: Icons.store,
                              enabled: _selectedSocieta != null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FooterButton(
                        text: 'Valutazione Rischi',
                        icon: Icons.assignment,
                        onPressed: () {
                          if (_selectedSocieta == null || _selectedUnitaLocale == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Seleziona Società e Unità Locale prima di procedere'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ValutazioneRischiScreen(societa: _selectedSocieta!, unitaLocale: _selectedUnitaLocale!),
                            ),
                          );
                        },
                        isPrimary: true,
                      ),
                      const SizedBox(width: 32),
                      _FooterButton(
                        text: 'Scadenze',
                        icon: Icons.calendar_today,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScadenzeScreen())),
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabelBuilder,
    required IconData icon,
    bool enabled = true,
    Key? key,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<T>(
          key: key,
          menuHeight: 300,
          width: constraints.maxWidth,
          initialSelection: value,
          label: Text(label),
          leadingIcon: Icon(icon, color: enabled ? Theme.of(context).primaryColor : Colors.grey),
          enabled: enabled,
          enableFilter: true,
          requestFocusOnTap: true,
          onSelected: onChanged,
          dropdownMenuEntries: (items.toList()..sort((a, b) => itemLabelBuilder(a).toLowerCase().compareTo(itemLabelBuilder(b).toLowerCase()))).map((item) {
            return DropdownMenuEntry<T>(value: item, label: itemLabelBuilder(item));
          }).toList(),
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(filled: true, fillColor: Colors.white),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const _NavButton({required this.text, required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Theme.of(context).primaryColor : Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          decoration: isActive ? TextDecoration.underline : null,
          decorationColor: Theme.of(context).primaryColor,
          decorationThickness: 2,
        ),
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _FooterButton({required this.text, required this.icon, required this.onPressed, this.isPrimary = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      height: 64,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? theme.primaryColor : theme.cardColor,
          foregroundColor: isPrimary ? Colors.white : theme.primaryColor,
          side: isPrimary ? null : BorderSide(color: theme.primaryColor),
          elevation: isPrimary ? 4 : 2,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
