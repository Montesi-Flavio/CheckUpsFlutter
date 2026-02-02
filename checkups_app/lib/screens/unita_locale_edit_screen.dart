import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/societa.dart';
import '../models/unita_locale.dart';
import '../repositories/database_repository.dart';
import '../widgets/shared_header.dart';
import '../widgets/modern_action_button.dart';
import 'reparto_list_screen.dart';

class UnitaLocaleEditScreen extends StatefulWidget {
  final Societa? societa;

  const UnitaLocaleEditScreen({super.key, this.societa});

  @override
  State<UnitaLocaleEditScreen> createState() => _UnitaLocaleEditScreenState();
}

class _UnitaLocaleEditScreenState extends State<UnitaLocaleEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _searchController = TextEditingController();
  final _nomeController = TextEditingController();
  final _indirizzoController = TextEditingController();
  final _localitaController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();

  List<UnitaLocale> _unitaList = [];
  UnitaLocale? _selectedUnita;
  bool _isLoading = false;
  bool _isFormValid = false;

  bool get _isDirty {
    if (_selectedUnita == null) {
      return _nomeController.text.isNotEmpty ||
          _indirizzoController.text.isNotEmpty ||
          _localitaController.text.isNotEmpty ||
          _provinciaController.text.isNotEmpty ||
          _telefonoController.text.isNotEmpty ||
          _emailController.text.isNotEmpty;
    } else {
      return _nomeController.text != _selectedUnita!.nome ||
          _indirizzoController.text != _selectedUnita!.indirizzo ||
          _localitaController.text != _selectedUnita!.localita ||
          _provinciaController.text != _selectedUnita!.provincia ||
          _telefonoController.text != _selectedUnita!.telefono ||
          _emailController.text != (_selectedUnita!.email ?? '');
    }
  }

  void _checkFormValid() {
    final isValid = _nomeController.text.isNotEmpty && _localitaController.text.isNotEmpty && _provinciaController.text.isNotEmpty;
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();

    final controllers = [_nomeController, _indirizzoController, _localitaController, _provinciaController, _telefonoController, _emailController];

    for (var controller in controllers) {
      controller.addListener(() {
        _checkFormValid();
        setState(() {});
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<DatabaseRepository>();
      final list = await repo.getUnitaLocaleList();

      // Filter by Societa if provided
      List<UnitaLocale> filteredList = list;
      if (widget.societa != null) {
        filteredList = list.where((u) => u.idSocieta == widget.societa!.id).toList();
      }

      setState(() {
        _unitaList = filteredList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  void _populateForm(UnitaLocale? unita) {
    if (unita != null) {
      _searchController.text = unita.nome;
      _nomeController.text = unita.nome;
      _indirizzoController.text = unita.indirizzo;
      _localitaController.text = unita.localita;
      _provinciaController.text = unita.provincia;
      _telefonoController.text = unita.telefono;
      _emailController.text = unita.email ?? '';
    } else {
      _clearForm();
    }
    setState(() {
      _selectedUnita = unita;
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkFormValid());
    });
  }

  void _clearForm() {
    _searchController.clear();
    _nomeController.clear();
    _indirizzoController.clear();
    _localitaController.clear();
    _provinciaController.clear();
    _telefonoController.clear();
    _emailController.clear();
    setState(() => _selectedUnita = null);
  }

  Future<bool> _saveUnitaLocale() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.societa == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Errore: Nessuna società selezionata')));
        return false;
      }

      setState(() => _isLoading = true);
      try {
        final unita = UnitaLocale(
          id: _selectedUnita?.id ?? -1,
          idSocieta: widget.societa!.id,
          nome: _nomeController.text,
          indirizzo: _indirizzoController.text,
          localita: _localitaController.text,
          provincia: _provinciaController.text,
          telefono: _telefonoController.text,
          email: _emailController.text,
        );

        final repo = context.read<DatabaseRepository>();
        if (_selectedUnita == null) {
          await repo.insertUnitaLocale(unita);
        } else {
          await repo.updateUnitaLocale(unita);
        }

        await _loadData();

        // Always keep selection after save - find the saved/updated item
        try {
          final savedId = _selectedUnita?.id ?? unita.id;
          UnitaLocale? found;
          for (final u in _unitaList) {
            if (u.id == savedId || (savedId == -1 && u.nome == unita.nome)) {
              found = u;
              break;
            }
          }
          if (found != null) {
            _selectedUnita = found;
            _populateForm(found);
          }
        } catch (e) {
          // Keep current form state
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvataggio completato')));
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore durante il salvataggio: $e')));
        }
        return false;
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
    return false;
  }

  Future<void> _deleteUnitaLocale() async {
    if (_selectedUnita == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Sei sicuro di voler eliminare l\'unità locale "${_selectedUnita!.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final repo = context.read<DatabaseRepository>();
        await repo.deleteUnitaLocale(_selectedUnita!.id);
        await _loadData();
        _clearForm();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unità locale eliminata')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore durante l\'eliminazione: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          SharedHeader(
            isHomeActive: false,
            onHomePressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            isAdminActive: true,
            onAdminPressed: () {},
          ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: double.infinity),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title and Context
                      Column(
                        children: [
                          Text(
                            'Unità Locale',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.societa != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Società: ${widget.societa!.nome}',
                                style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Toolbar & Search
                      Row(
                        children: [
                          // Back Button
                          ModernActionButton(icon: Icons.arrow_back_ios_new, onPressed: () => Navigator.pop(context), tooltip: 'Indietro'),
                          const SizedBox(width: 8),

                          // Action Icons
                          ModernActionButton(
                            icon: Icons.save,
                            label: 'Salva',
                            isPrimary: true,
                            onPressed: (_isFormValid && _isDirty) ? () => _saveUnitaLocale() : null,
                          ),
                          const SizedBox(width: 8),
                          ModernActionButton(icon: Icons.close, onPressed: _clearForm, tooltip: 'Resetta campi'),
                          const SizedBox(width: 8),
                          ModernActionButton(
                            icon: Icons.delete_outline,
                            isDestructive: true,
                            onPressed: _selectedUnita != null
                                ? () {
                                    _deleteUnitaLocale();
                                  }
                                : null,
                            tooltip: 'Elimina',
                          ),

                          const SizedBox(width: 32),

                          // Search Dropdown
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return DropdownMenu<UnitaLocale>(
                                  controller: _searchController,
                                  width: constraints.maxWidth,
                                  label: const Text('Seleziona unità locale...'),
                                  enableFilter: true,
                                  menuHeight: 300,
                                  dropdownMenuEntries: (_unitaList.toList()..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase())))
                                      .map((u) => DropdownMenuEntry<UnitaLocale>(value: u, label: u.nome))
                                      .toList(),
                                  onSelected: _populateForm,
                                  inputDecorationTheme: const InputDecorationTheme(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(4))),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 32),

                          // Next Button -> Reparti
                          ModernActionButton(
                            icon: Icons.arrow_forward_ios,
                            onPressed: () async {
                              if (widget.societa != null) {
                                if (_selectedUnita == null) {
                                  if (_isDirty && _isFormValid) {
                                    final success = await _saveUnitaLocale();
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(const SnackBar(content: Text('Unità locale creata. Selezionala per procedere.')));
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleziona un\'unità locale per procedere')));
                                  }
                                } else {
                                  // Selected not null
                                  if (_isDirty) {
                                    if (_isFormValid) {
                                      final success = await _saveUnitaLocale();
                                      if (success && context.mounted && _selectedUnita != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => RepartoListScreen(societa: widget.societa!, unitaLocale: _selectedUnita!),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RepartoListScreen(societa: widget.societa!, unitaLocale: _selectedUnita!),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Errore: Nessuna società selezionata')));
                              }
                            },
                            tooltip: 'Vai a Reparti',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Form
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildField('Nome Unità*', _nomeController, fullWidth: true),
                                    const SizedBox(height: 12),
                                    _buildField('Indirizzo', _indirizzoController, fullWidth: true),
                                    const SizedBox(height: 12),
                                    _buildRow(_buildField('Località*', _localitaController), _buildField('Provincia*', _provinciaController)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 48), // Gutter
                              // Right Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildField(
                                      'Telefono',
                                      _telefonoController,
                                      fullWidth: true,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildField('Email', _emailController, fullWidth: true),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 32),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool fullWidth = false,
    int maxLines = 1,
    double? width,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: fullWidth ? double.infinity : width,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );

    if (fullWidth) {
      return field;
    }

    return field;
  }
}
