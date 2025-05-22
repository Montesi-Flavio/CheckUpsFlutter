import 'package:sqflite/sqflite.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/local_unit_repository.dart';
import '../datasources/database_helper.dart';

class LocalUnitRepositoryImpl implements LocalUnitRepository {
  final DatabaseHelper _dbHelper;

  LocalUnitRepositoryImpl(this._dbHelper);

  @override
  Future<LocalUnit?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_units',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return LocalUnit.fromJson(maps.first);
  }

  @override
  Future<List<LocalUnit>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('local_units');
    return List.generate(maps.length, (i) {
      return LocalUnit.fromJson(maps[i]);
    });
  }

  @override
  Future<int> insert(LocalUnit entity) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'local_units',
      entity.toJson()
        ..remove('id')
        ..remove('departmentIds'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> update(LocalUnit entity) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'local_units',
      entity.toJson()..remove('departmentIds'),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
    return count > 0;
  }

  @override
  Future<bool> delete(int id) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'local_units',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  @override
  Future<List<LocalUnit>> getByCompanyId(int companyId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_units',
      where: 'company_id = ?',
      whereArgs: [companyId],
    );
    return List.generate(maps.length, (i) {
      return LocalUnit.fromJson(maps[i]);
    });
  }

  @override
  Future<List<LocalUnit>> searchByName(String name) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_units',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return List.generate(maps.length, (i) {
      return LocalUnit.fromJson(maps[i]);
    });
  }
}
