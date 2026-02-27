import 'package:flutter/material.dart';
import '../../models/reparto.dart';

class RepartoEditDialog extends StatefulWidget {
  final Reparto? reparto; // If null, we are adding a new one
  final int? idUnitaLocale; // Required if reparto is null

  const RepartoEditDialog({super.key, this.reparto, this.idUnitaLocale});

  @override
  State<RepartoEditDialog> createState() => _RepartoEditDialogState();
}

class _RepartoEditDialogState extends State<RepartoEditDialog> {
  late TextEditingController _nomeController;
  late TextEditingController _revisioneController;
  late TextEditingController _descrizioneController;
  late TextEditingController _dataController;
  int _priorita = 0;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.reparto?.nome ?? '');
    _revisioneController = TextEditingController(
      text: widget.reparto?.revisione ?? '',
    );
    _descrizioneController = TextEditingController(
      text: widget.reparto?.descrizione ?? '',
    );
    _priorita = widget.reparto?.priorita ?? 0;
    _selectedDate = widget.reparto?.data;
    _dataController = TextEditingController(
      text: _selectedDate != null
          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
          : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _revisioneController.dispose();
    _descrizioneController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dataController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      backgroundColor: const Color(
        0xFFF5F5F5,
      ), // Light grey background like image
      child: Container(
        width: 500, // Fixed width to match popup style
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              widget.reparto != null ? 'Modifica Reparto' : 'Nuovo Reparto',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // N° (Priority)
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    'N°',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: 80, // Small width for number
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
                              child: const Icon(Icons.arrow_drop_up, size: 16),
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

            // Nome*
            _buildRow('Nome*', _nomeController),
            const SizedBox(height: 12),

            // Revisione
            _buildRow('Revisione', _revisioneController),
            const SizedBox(height: 12),

            // Data*
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Data*',
                    style: TextStyle(fontWeight: FontWeight.w500),
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
                              _dataController.text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _selectDate(context),
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
            ),
            const SizedBox(height: 12),

            // Descrizione
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 80,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Descrizione',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Matching the image's rounded look for textarea
                    ),
                    child: TextField(
                      controller: _descrizioneController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                      ),
                    ),
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
                    final newReparto = Reparto(
                      id: widget.reparto?.id ?? -1,
                      idUnitaLocale:
                          widget.reparto?.idUnitaLocale ??
                          widget.idUnitaLocale ??
                          0,
                      priorita: _priorita,
                      nome: _nomeController.text,
                      descrizione: _descrizioneController.text,
                      revisione: _revisioneController.text,
                      data: _selectedDate,
                    );
                    Navigator.pop(context, newReparto);
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
    );
  }

  Widget _buildRow(String label, TextEditingController controller) {
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
          child: SizedBox(
            height: 32,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
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
}
