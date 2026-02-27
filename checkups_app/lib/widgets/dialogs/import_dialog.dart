import 'package:flutter/material.dart';

class ImportDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final List<ImportColumn<T>> columns;

  const ImportDialog({super.key, required this.title, required this.items, required this.columns});

  @override
  State<ImportDialog<T>> createState() => _ImportDialogState<T>();
}

class _ImportDialogState<T> extends State<ImportDialog<T>> {
  late List<T> _filteredItems;
  final Map<int, String> _filters = {}; // Column index -> Filter text
  final Set<T> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = widget.items.where((item) {
        for (final entry in _filters.entries) {
          final columnIndex = entry.key;
          final filterText = entry.value.toLowerCase();
          if (filterText.isEmpty) continue;

          final cellValue = widget.columns[columnIndex].getValue(item).toLowerCase();
          if (!cellValue.contains(filterText)) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  void _toggleSelection(T item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedItems.addAll(_filteredItems);
      } else {
        _selectedItems.removeAll(_filteredItems);
      }
    });
  }

  bool get _areAllFilteredSelected => _filteredItems.isNotEmpty && _filteredItems.every((item) => _selectedItems.contains(item));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),

            // Table Header with Filters
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Checkbox(value: _areAllFilteredSelected, onChanged: _filteredItems.isEmpty ? null : _toggleSelectAll),
                  ),
                  for (int i = 0; i < widget.columns.length; i++)
                    Expanded(
                      flex: widget.columns[i].flex,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.columns[i].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (widget.columns[i].filterable)
                            Container(
                              height: 36,
                              padding: const EdgeInsets.only(right: 8),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Filtra per ${widget.columns[i].title.toLowerCase()}',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  suffixIcon: _filters[i]?.isNotEmpty == true
                                      ? InkWell(
                                          onTap: () {
                                            _filters[i] = '';
                                            _applyFilters();
                                          },
                                          child: const Icon(Icons.close, size: 16),
                                        )
                                      : null,
                                ),
                                style: const TextStyle(fontSize: 13),
                                onChanged: (value) {
                                  _filters[i] = value;
                                  _applyFilters();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Table Body
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(child: Text('Nessun elemento trovato'))
                  : ListView.separated(
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = _selectedItems.contains(item);
                        return InkWell(
                          onTap: () => _toggleSelection(item),
                          child: Container(
                            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Checkbox(value: isSelected, onChanged: (_) => _toggleSelection(item)),
                                ),
                                for (int i = 0; i < widget.columns.length; i++)
                                  Expanded(
                                    flex: widget.columns[i].flex,
                                    child: Text(
                                      widget.columns[i].getValue(item),
                                      style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_selectedItems.isNotEmpty)
                  Text(
                    '${_selectedItems.length} selezionati',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                const SizedBox(width: 16),
                OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Chiudi')),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _selectedItems.isNotEmpty ? () => Navigator.pop(context, _selectedItems.toList()) : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
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

class ImportColumn<T> {
  final String title;
  final int flex;
  final bool filterable;
  final String Function(T) getValue;

  const ImportColumn({required this.title, required this.getValue, this.flex = 1, this.filterable = true});
}
