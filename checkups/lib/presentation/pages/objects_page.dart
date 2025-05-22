import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/checkup_item.dart';
import '../state/object_provider.dart';

class ObjectsPage extends ConsumerWidget {
  final int titleId;

  const ObjectsPage({
    super.key,
    required this.titleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectState = ref.watch(objectStateProvider);

    // Carica gli oggetti quando la pagina viene creata
    ref.listen(objectStateProvider, (previous, next) {
      if (previous?.selectedTitleId != titleId) {
        ref.read(objectStateProvider.notifier).loadObjects(titleId: titleId);
      }
    });

    final objects = objectState.objects;
    final isLoading = objectState.isLoading;
    final error = objectState.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oggetti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddObjectDialog(context, titleId),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Errore: $error'))
              : ListView.builder(
                  itemCount: objects.length,
                  itemBuilder: (context, index) {
                    final object = objects[index];
                    return Card(
                      child: ListTile(
                        title: Text(object.name),
                        subtitle: Text('Priorità: ${object.priority}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditObjectDialog(context, object),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // TODO: elimina oggetto
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddObjectDialog(BuildContext context, int titleId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Form aggiunta oggetto (da implementare)'),
        ),
      ),
    );
  }

  void _showEditObjectDialog(BuildContext context, CheckupItem object) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Form modifica oggetto (da implementare)'),
        ),
      ),
    );
  }
}
