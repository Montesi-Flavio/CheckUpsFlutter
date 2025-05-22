import 'package:sqflite/sqflite.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/database_helper.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final DatabaseHelper _dbHelper;

  CompanyRepositoryImpl(this._dbHelper);

  @override
  Future<Company?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Company.fromJson(maps.first);
  }

  @override
  Future<List<Company>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('companies');
    return List.generate(maps.length, (i) {
      return Company.fromJson(maps[i]);
    });
  }

  @override
  Future<int> insert(Company entity) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'companies',
      entity.toJson()
        ..remove('id')
        ..remove('localUnitIds'), // Remove id and localUnitIds
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> update(Company entity) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'companies',
      entity.toJson()..remove('localUnitIds'), // Remove localUnitIds
      where: 'id = ?',
      whereArgs: [entity.id],
    );
    return count > 0;
  }

  @override
  Future<bool> delete(int id) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  @override
  Future<List<Company>> searchByName(String name) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'companies',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return List.generate(maps.length, (i) {
      return Company.fromJson(maps[i]);
    });
  }

  @override
  Future<List<Company>> getByFiscalCode(String fiscalCode) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'companies',
      where: 'fiscal_code = ?',
      whereArgs: [fiscalCode],
    );
    return List.generate(maps.length, (i) {
      return Company.fromJson(maps[i]);
    });
  }

  @override
  Future<List<Company>> getByVatNumber(String vatNumber) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'companies',
      where: 'vat_number = ?',
      whereArgs: [vatNumber],
    );
    return List.generate(maps.length, (i) {
      return Company.fromJson(maps[i]);
    });
  }
}
