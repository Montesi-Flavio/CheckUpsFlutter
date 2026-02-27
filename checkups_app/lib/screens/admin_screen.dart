import 'package:flutter/material.dart';
import 'societa_list_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), centerTitle: false),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        children: [
          _DashboardCard(
            title: 'Società',
            icon: Icons.business,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SocietaListScreen()),
            ),
          ),
          /*
          _DashboardCard(
            title: 'Reparti',
            icon: Icons.category,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RepartoListScreen()));
            },
          ),
          _DashboardCard(
            title: 'Titoli',
            icon: Icons.title,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TitoloListScreen()));
            },
          ),
          _DashboardCard(
            title: 'Unità Locali',
            icon: Icons.store,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UnitaLocaleListScreen()));
            },
          ),
          _DashboardCard(
            title: 'Oggetti',
            icon: Icons.widgets,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OggettoListScreen()));
            },
          ),
          _DashboardCard(
            title: 'Provvedimenti',
            icon: Icons.assignment_turned_in,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProvvedimentoListScreen()));
            },
          ),
          */
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.shade50],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
