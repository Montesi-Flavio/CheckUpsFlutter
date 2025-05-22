import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/local_unit.dart';
import '../state/local_unit_provider.dart';
import '../state/company_provider.dart';
import '../widgets/local_unit_form.dart';
import 'departments_page.dart';

class LocalUnitsPage extends ConsumerWidget {
  final int companyId;

  const LocalUnitsPage({
    super.key,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyState = ref.watch(companyStateProvider);
    final company = companyState.companies.firstWhere((c) => c.id == companyId);
    final localUnitState = ref.watch(localUnitStateProvider);

    // Carica le unità locali quando la pagina viene creata
    ref.listen(localUnitStateProvider, (previous, next) {
      if (previous?.selectedCompanyId != companyId) {
        ref.read(localUnitStateProvider.notifier).loadLocalUnits(companyId: companyId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Unità Locali - ${company.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddLocalUnitDialog(context, companyId),
          ),
        ],
      ),
      body: localUnitState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : localUnitState.error != null
              ? Center(child: Text('Errore: ${localUnitState.error}'))
              : ListView.builder(
                  itemCount: localUnitState.localUnits.length,
                  itemBuilder: (context, index) {
                    final localUnit = localUnitState.localUnits[index];
                    return _LocalUnitCard(
                      localUnit: localUnit,
                      companyName: company.name,
                    );
                  },
                ),
    );
  }

  void _showAddLocalUnitDialog(BuildContext context, int companyId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuova Unità Locale',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LocalUnitForm(companyId: companyId),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalUnitCard extends ConsumerWidget {
  final LocalUnit localUnit;
  final String companyName;

  const _LocalUnitCard({
    required this.localUnit,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(localUnit.name),
        subtitle: Text(localUnit.address ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditLocalUnitDialog(context, localUnit),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(context, ref, localUnit),
            ),
          ],
        ),        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DepartmentsPage(localUnitId: localUnit.id),
            ),
          );
        },
      ),
    );
  }

  void _showEditLocalUnitDialog(BuildContext context, LocalUnit localUnit) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Modifica Unità Locale',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LocalUnitForm(
                localUnit: localUnit,
                companyId: localUnit.companyId,
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
    LocalUnit localUnit,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Vuoi davvero eliminare l\'unità locale ${localUnit.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              ref.read(localUnitStateProvider.notifier).deleteLocalUnit(localUnit.id);
              Navigator.pop(context);
            },
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
  }
}
