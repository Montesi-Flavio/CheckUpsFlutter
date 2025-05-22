import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../data/datasources/database_config.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar instance must be initialized before use');
});

final isarInitializerProvider = FutureProvider<Isar>((ref) async {
  final isar = await DatabaseConfig.initialize();
  ref.container.state = isarProvider.overrideWithValue(isar);
  return isar;
});
