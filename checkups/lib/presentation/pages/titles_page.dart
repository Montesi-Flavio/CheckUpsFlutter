import 'package:flutter/material.dart' hide Title;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/index.dart';
import '../state/title_provider.dart';
import '../state/department_provider.dart';
import '../widgets/title_form.dart';
import 'objects_page.dart';

class TitlesPage extends ConsumerWidget {
  final int departmentId;

  const TitlesPage({
    super.key,
    required this.departmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentState = ref.watch(departmentStateProvider);
    final department = departmentState.departments.firstWhere((d) => d.id == departmentId);
    final titleState = ref.watch(titleStateProvider);

    // Carica i titoli quando la pagina viene creata
    ref.listen(titleStateProvider, (previous, next) {
      if (previous?.selectedDepartmentId != departmentId) {
        ref.read(titleStateProvider.notifier).loadTitles(departmentId: departmentId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Titoli - ${department.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTitleDialog(context, departmentId),
          ),
        ],
      ),
      body: titleState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : titleState.error != null
              ? Center(child: Text('Errore: ${titleState.error}'))
              : ListView.builder(
                  itemCount: titleState.titles.length,
                  itemBuilder: (context, index) {
                    final title = titleState.titles[index];
                    return _TitleCard(
                      title: title,
                      departmentName: department.name,
                    );
                  },
                ),
    );
  }

  void _showAddTitleDialog(BuildContext context, int departmentId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuovo Titolo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TitleForm(departmentId: departmentId),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleCard extends ConsumerWidget {
  final Title title;
  final String departmentName;

  const _TitleCard({
    required this.title,
    required this.departmentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title.name),
        subtitle: Text(title.description ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditTitleDialog(context, title),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(context, ref, title),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ObjectsPage(titleId: title.id),
            ),
          );
        },
      ),
    );
  }

  void _showEditTitleDialog(BuildContext context, Title title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Modifica Titolo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TitleForm(
                title: title,
                departmentId: title.departmentId,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Title title,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Vuoi davvero eliminare il titolo ${title.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              ref.read(titleStateProvider.notifier).deleteTitle(title.id);
              Navigator.pop(context);
            },
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
  }
}
