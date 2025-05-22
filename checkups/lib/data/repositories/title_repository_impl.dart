import 'package:sqflite/sqflite.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/title_repository.dart';
import '../datasources/database_helper.dart';

class TitleRepositoryImpl implements TitleRepository {
  final DatabaseHelper _dbHelper;

  TitleRepositoryImpl(this._dbHelper);

  @override
  Future<Title?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'titles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Title.fromJson(maps.first);
  }

  @override
  Future<List<Title>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('titles');
    return List.generate(maps.length, (i) {
      return Title.fromJson(maps[i]);
    });
  }

  @override
  Future<int> insert(Title entity) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'titles',
      entity.toJson()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> update(Title entity) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'titles',
      entity.toJson(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
    return count > 0;
  }

  @override
  Future<bool> delete(int id) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'titles',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  @override
  Future<List<Title>> getByDepartmentId(int departmentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*
      FROM titles t
      INNER JOIN department_titles dt ON dt.title_id = t.id
      WHERE dt.department_id = ?
    ''', [departmentId]);

    return List.generate(maps.length, (i) {
      return Title.fromJson(maps[i]);
    });
  }

  @override
  Future<List<Title>> searchByName(String name) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'titles',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return List.generate(maps.length, (i) {
      return Title.fromJson(maps[i]);
    });
  }
}
