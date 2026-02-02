import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/database_repository.dart';
import '../models/unita_locale.dart';

class UnitaLocaleListScreen extends StatefulWidget {
  const UnitaLocaleListScreen({super.key});

  @override
  State<UnitaLocaleListScreen> createState() => _UnitaLocaleListScreenState();
}

class _UnitaLocaleListScreenState extends State<UnitaLocaleListScreen> {
  late Future<List<UnitaLocale>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = context.read<DatabaseRepository>().getUnitaLocaleList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unità Locali'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new Unita Locale
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<UnitaLocale>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Errore: ${snapshot.error}'),
                  ElevatedButton(onPressed: _refresh, child: const Text('Riprova')),
                ],
              ),
            );
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Nessuna unità locale trovata.'));
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final unita = list[index];
              return ListTile(
                leading: CircleAvatar(child: Text(unita.nome[0].toUpperCase())),
                title: Text(unita.nome),
                subtitle: Text('${unita.indirizzo}, ${unita.localita} (${unita.provincia})'),
                onTap: () {
                  // TODO: Details / Edit
                },
              );
            },
          );
        },
      ),
    );
  }
}
