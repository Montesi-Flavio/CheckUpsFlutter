import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/database_repository.dart';
import '../models/societa.dart';

class SocietaListScreen extends StatefulWidget {
  const SocietaListScreen({super.key});

  @override
  State<SocietaListScreen> createState() => _SocietaListScreenState();
}

class _SocietaListScreenState extends State<SocietaListScreen> {
  late Future<List<Societa>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = context.read<DatabaseRepository>().getSocietaList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Società'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new Societa
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Societa>>(
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
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Nessuna società trovata.'));
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final societa = list[index];
              return ListTile(
                leading: societa.hasImage
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(societa.logoBytes!),
                        onBackgroundImageError: (_, __) {},
                      )
                    : CircleAvatar(
                        child: Text(
                          societa.nome.isNotEmpty
                              ? societa.nome[0].toUpperCase()
                              : '?',
                        ),
                      ),
                title: Text(societa.nome),
                subtitle: Text(societa.indirizzo),
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
