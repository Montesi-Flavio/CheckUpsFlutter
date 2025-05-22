import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/company.dart';
import '../state/company_provider.dart';
import 'local_units_page.dart';
import '../widgets/company_form.dart';

class CompaniesPage extends ConsumerWidget {
  const CompaniesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companyStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aziende'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCompanyDialog(context),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Errore: ${state.error}'))
              : ListView.builder(
                  itemCount: state.companies.length,
                  itemBuilder: (context, index) {
                    final company = state.companies[index];
                    return _CompanyCard(company: company);
                  },
                ),
    );
  }

  void _showAddCompanyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuova Azienda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const CompanyForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyCard extends ConsumerWidget {
  final Company company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(company.name),
        subtitle: Text('P.IVA: ${company.vatNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditCompanyDialog(context, company),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(context, ref, company),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LocalUnitsPage(companyId: company.id),
            ),
          );
        },
      ),
    );
  }

  void _showEditCompanyDialog(BuildContext context, Company company) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Modifica Azienda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CompanyForm(company: company),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Company company,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Vuoi davvero eliminare l\'azienda ${company.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              ref.read(companyStateProvider.notifier).deleteCompany(company.id);
              Navigator.pop(context);
            },
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
  }
}
