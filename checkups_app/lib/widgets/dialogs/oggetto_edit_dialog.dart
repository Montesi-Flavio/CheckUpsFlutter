import 'package:flutter/material.dart';
import '../../models/oggetto.dart';

class OggettoEditDialog extends StatefulWidget {
  final Oggetto? oggetto; // If null, we are adding a new one
  final int? idTitolo; // Required if new

  const OggettoEditDialog({super.key, this.oggetto, this.idTitolo});

  @override
  State<OggettoEditDialog> createState() => _OggettoEditDialogState();
}

class _OggettoEditDialogState extends State<OggettoEditDialog> {
  late TextEditingController _nomeController;
  int _priorita = 0;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.oggetto?.nome ?? '');
    _priorita = widget.oggetto?.priorita ?? 0;
  }

  @override
  void dispose() {
    _nomeController.dispose();
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
            Text(
              widget.oggetto != null ? 'Modifica Oggetto' : 'Nuovo Oggetto',
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

            // Nome
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Nome',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: TextField(
                      controller: _nomeController,
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
                    final newOggetto = Oggetto(
                      id: widget.oggetto?.id ?? -1,
                      idTitolo:
                          widget.oggetto?.idTitolo ?? widget.idTitolo ?? 0,
                      priorita: _priorita,
                      nome: _nomeController.text,
                    );
                    Navigator.pop(context, newOggetto);
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
}
