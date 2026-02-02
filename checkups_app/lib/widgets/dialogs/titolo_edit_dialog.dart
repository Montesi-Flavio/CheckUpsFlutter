import 'package:flutter/material.dart';
import '../../models/titolo.dart';

class TitoloEditDialog extends StatefulWidget {
  final Titolo? titolo; // If null, we are adding a new one
  final int? idReparto; // Required if new

  const TitoloEditDialog({super.key, this.titolo, this.idReparto});

  @override
  State<TitoloEditDialog> createState() => _TitoloEditDialogState();
}

class _TitoloEditDialogState extends State<TitoloEditDialog> {
  late TextEditingController _descrizioneController;
  int _priorita = 0;

  @override
  void initState() {
    super.initState();
    _descrizioneController = TextEditingController(text: widget.titolo?.descrizione ?? '');
    _priorita = widget.titolo?.priorita ?? 0;
  }

  @override
  void dispose() {
    _descrizioneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      backgroundColor: const Color(0xFFF5F5F5),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.titolo != null ? 'Modifica Titolo' : 'Nuovo Titolo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87)),
            const SizedBox(height: 24),

            // N° (Priority)
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text('N°', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                          child: Text('$_priorita', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: InkWell(onTap: () => setState(() => _priorita++), child: const Icon(Icons.arrow_drop_up, size: 16)),
                          ),
                          Expanded(
                            child: InkWell(onTap: () => setState(() => _priorita > 0 ? _priorita-- : 0), child: const Icon(Icons.arrow_drop_down, size: 16)),
                          ),
                        ],
                      ),
                    ],
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
                    child: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _descrizioneController,
                      maxLines: null,
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8), isDense: true),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Annulla'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final newTitolo = Titolo(
                      id: widget.titolo?.id ?? -1,
                      idReparto: widget.titolo?.idReparto ?? widget.idReparto ?? 0,
                      priorita: _priorita,
                      descrizione: _descrizioneController.text,
                    );
                    Navigator.pop(context, newTitolo);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 1,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
}
