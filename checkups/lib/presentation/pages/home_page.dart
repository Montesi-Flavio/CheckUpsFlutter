import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/isar_provider.dart';
import 'companies_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarAsync = ref.watch(isarInitializerProvider);

    return Scaffold(
      body: isarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore: $error')),
        data: (_) => const _HomeContent(),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckUps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implementare le impostazioni
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _MenuCard(
            title: 'Aziende',
            icon: Icons.business,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompaniesPage()),
            ),
          ),
          _MenuCard(
            title: 'Scadenze',
            icon: Icons.calendar_today,
            onTap: () {
              // TODO: Implementare la pagina delle scadenze
            },
          ),
          _MenuCard(
            title: 'Documenti',
            icon: Icons.description,
            onTap: () {
              // TODO: Implementare la pagina dei documenti
            },
          ),
          _MenuCard(
            title: 'Statistiche',
            icon: Icons.bar_chart,
            onTap: () {
              // TODO: Implementare la pagina delle statistiche
            },
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
