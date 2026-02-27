import 'package:flutter/material.dart';
import '../../models/provvedimento.dart';

class ProvvedimentoEditDialog extends StatefulWidget {
  final Provvedimento? provvedimento;
  final int? idOggetto;

  const ProvvedimentoEditDialog({
    super.key,
    this.provvedimento,
    this.idOggetto,
  });

  @override
  State<ProvvedimentoEditDialog> createState() =>
      _ProvvedimentoEditDialogState();
}

class _ProvvedimentoEditDialogState extends State<ProvvedimentoEditDialog> {
  late TextEditingController _rischioController;
  late TextEditingController _nomeController; // Misure di prevenzione
  late TextEditingController _soggettiEspostiController;
  late TextEditingController _stimaDController;
  late TextEditingController _stimaPController;
  late TextEditingController _dataInizioController;
  late TextEditingController _dataScadenzaController;
  int _priorita = 0;
  DateTime? _dataInizio;
  DateTime? _dataScadenza;

  @override
  void initState() {
    super.initState();
    _rischioController = TextEditingController(
      text: widget.provvedimento?.rischio ?? '',
    );
    _nomeController = TextEditingController(
      text: widget.provvedimento?.nome ?? '',
    );
    _soggettiEspostiController = TextEditingController(
      text: widget.provvedimento?.soggettiEsposti ?? '',
    );
    _stimaDController = TextEditingController(
      text: widget.provvedimento?.stimaD.toString() ?? '0',
    );
    _stimaPController = TextEditingController(
      text: widget.provvedimento?.stimaP.toString() ?? '0',
    );
    _priorita = widget.provvedimento?.priorita ?? 0;
    _dataInizio = widget.provvedimento?.dataInizio;
    _dataScadenza = widget.provvedimento?.dataScadenza;

    _dataInizioController = TextEditingController(
      text: _dataInizio != null
          ? '${_dataInizio!.day}/${_dataInizio!.month}/${_dataInizio!.year}'
          : '',
    );
    _dataScadenzaController = TextEditingController(
      text: _dataScadenza != null
          ? '${_dataScadenza!.day}/${_dataScadenza!.month}/${_dataScadenza!.year}'
          : '',
    );
  }

  @override
  void dispose() {
    _rischioController.dispose();
    _nomeController.dispose();
    _soggettiEspostiController.dispose();
    _stimaDController.dispose();
    _stimaPController.dispose();
    _dataInizioController.dispose();
    _dataScadenzaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _dataInizio : _dataScadenza;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _dataInizio = picked;
          _dataInizioController.text =
              '${picked.day}/${picked.month}/${picked.year}';
        } else {
          _dataScadenza = picked;
          _dataScadenzaController.text =
              '${picked.day}/${picked.month}/${picked.year}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      backgroundColor: const Color(0xFFF5F5F5),
      child: Container(
        width: 600, // Slightly wider for extra fields
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.provvedimento != null
                    ? 'Modifica Provvedimento'
                    : 'Nuovo Provvedimento',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // N° (Priority)
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'N°',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '$_priorita',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _priorita++),
                                child: const Icon(
                                  Icons.arrow_drop_up,
                                  size: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(
                                  () => _priorita > 0 ? _priorita-- : 0,
                                ),
                                child: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildRow('Rischio', _rischioController),
              const SizedBox(height: 12),

              _buildRow('Misure prev.', _nomeController, maxLines: 3),
              const SizedBox(height: 12),

              _buildRow('Soggetti Esp.', _soggettiEspostiController),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildRow(
                      'Stima D',
                      _stimaDController,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRow(
                      'Stima P',
                      _stimaPController,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDateRow(
                      'Data Inizio',
                      _dataInizioController,
                      true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateRow(
                      'Data Scad.',
                      _dataScadenzaController,
                      false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final newProvvedimento = Provvedimento(
                        id: widget.provvedimento?.id ?? -1,
                        idOggetto:
                            widget.provvedimento?.idOggetto ??
                            widget.idOggetto ??
                            0,
                        priorita: _priorita,
                        rischio: _rischioController.text,
                        nome: _nomeController.text,
                        soggettiEsposti: _soggettiEspostiController.text,
                        stimaD: int.tryParse(_stimaDController.text) ?? 0,
                        stimaP: int.tryParse(_stimaPController.text) ?? 0,
                        dataInizio: _dataInizio,
                        dataScadenza: _dataScadenza,
                      );
                      Navigator.pop(context, newProvvedimento);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      elevation: 1,
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Applica'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Padding(
            padding: maxLines > 1
                ? const EdgeInsets.only(top: 8.0)
                : EdgeInsets.zero,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: maxLines > 1
                ? null
                : 32, // Height 32 for single line, auto for multi
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              minLines: maxLines > 1 ? 3 : 1,
              keyboardType: isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(
    String label,
    TextEditingController controller,
    bool isStart,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      controller.text,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _selectDate(context, isStart),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade400),
                      ),
                      color: Colors.grey.shade200,
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
