import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/index.dart';
import '../state/department_provider.dart';
import '../state/local_unit_provider.dart';
import '../widgets/department_form.dart';
import 'titles_page.dart';

class DepartmentsPage extends ConsumerWidget {
  final int localUnitId;

  const DepartmentsPage({
    super.key,
    required this.localUnitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localUnitState = ref.watch(localUnitStateProvider);
    final localUnit = localUnitState.localUnits.firstWhere((u) => u.id == localUnitId);
    final departmentState = ref.watch(departmentStateProvider);

    // Carica i reparti quando la pagina viene creata
    ref.listen(departmentStateProvider, (previous, next) {
      if (previous?.selectedLocalUnitId != localUnitId) {
        ref.read(departmentStateProvider.notifier).loadDepartments(localUnitId: localUnitId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Reparti - ${localUnit.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDepartmentDialog(context, localUnitId),
          ),
        ],
      ),
      body: departmentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : departmentState.error != null
              ? Center(child: Text('Errore: ${departmentState.error}'))
              : ListView.builder(
                  itemCount: departmentState.departments.length,
                  itemBuilder: (context, index) {
                    final department = departmentState.departments[index];
                    return _DepartmentCard(
                      department: department,
                      localUnitName: localUnit.name,
                    );
                  },
                ),
    );
  }

  void _showAddDepartmentDialog(BuildContext context, int localUnitId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuovo Reparto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DepartmentForm(localUnitId: localUnitId),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartmentCard extends ConsumerWidget {
  final Department department;
  final String localUnitName;

  const _DepartmentCard({
    required this.department,
    required this.localUnitName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(department.name),
        subtitle: Text(department.description ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDepartmentDialog(context, department),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(context, ref, department),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TitlesPage(departmentId: department.id),
            ),
          );
        },
      ),
    );
  }

  void _showEditDepartmentDialog(BuildContext context, Department department) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Modifica Reparto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DepartmentForm(
                department: department,
                localUnitId: department.localUnitId,
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
    Department department,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Vuoi davvero eliminare il reparto ${department.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              ref.read(departmentStateProvider.notifier).deleteDepartment(department.id);
              Navigator.pop(context);
            },
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
  }
}
