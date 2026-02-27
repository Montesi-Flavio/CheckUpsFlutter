import 'package:checkups_app/repositories/database_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Database Connection and Fetch Societa', () async {
    final repo = DatabaseRepository();

    try {
      final societaList = await repo.getSocietaList();
      print('Fetched ${societaList.length} societa');
      for (var s in societaList) {
        print('Societa: ${s.nome}');
      }
      expect(societaList, isNotNull);
    } catch (e) {
      fail('Database error: $e');
    } finally {
      await repo.close();
    }
  });
}
