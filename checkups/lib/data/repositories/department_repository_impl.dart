import 'package:sqflite/sqflite.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/department_repository.dart';
import '../datasources/database_helper.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DatabaseHelper _dbHelper;

  DepartmentRepositoryImpl(this._dbHelper);

  @override
  Future<Department?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'departments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Department.fromJson(maps.first);
  }

  @override
  Future<List<Department>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('departments');
    return List.generate(maps.length, (i) {
      return Department.fromJson(maps[i]);
    });
  }

  @override
  Future<int> insert(Department entity) async {
    final db = await _dbHelper.database;
    final departmentId = await db.insert(
      'departments',
      entity.toJson()
        ..remove('id')
        ..remove('titleIds'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Handle many-to-many relationship with titles
    if (entity.titleIds.isNotEmpty) {
      final batch = db.batch();
      for (final titleId in entity.titleIds) {
        batch.insert('department_titles', {
          'department_id': departmentId,
          'title_id': titleId,
        });
      }
      await batch.commit();
    }

    return departmentId;
  }

  @override
  Future<bool> update(Department entity) async {
    final db = await _dbHelper.database;

    // Update department
    final count = await db.update(
      'departments',
      entity.toJson()..remove('titleIds'),
      where: 'id = ?',
      whereArgs: [entity.id],
    );

    // Update title relationships
    await db.delete(
      'department_titles',
      where: 'department_id = ?',
      whereArgs: [entity.id],
    );

    if (entity.titleIds.isNotEmpty) {
      final batch = db.batch();
      for (final titleId in entity.titleIds) {
        batch.insert('department_titles', {
          'department_id': entity.id,
          'title_id': titleId,
        });
      }
      await batch.commit();
    }

    return count > 0;
  }

  @override
  Future<bool> delete(int id) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'departments',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Delete title relationships
    await db.delete(
      'department_titles',
      where: 'department_id = ?',
      whereArgs: [id],
    );

    return count > 0;
  }

  @override
  Future<List<Department>> getByLocalUnitId(int localUnitId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'departments',
      where: 'local_unit_id = ?',
      whereArgs: [localUnitId],
    );

    final departments = await Future.wait(maps.map((map) async {
      final department = Department.fromJson(map);
      final titleMaps = await db.query(
        'department_titles',
        where: 'department_id = ?',
        whereArgs: [department.id],
      );
      final titleIds = titleMaps.map((m) => m['title_id'] as int).toList();
      return department.copyWith(titleIds: titleIds);
    }));

    return departments;
  }

  @override
  Future<List<Department>> searchByName(String name) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'departments',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    final departments = await Future.wait(maps.map((map) async {
      final department = Department.fromJson(map);
      final titleMaps = await db.query(
        'department_titles',
        where: 'department_id = ?',
        whereArgs: [department.id],
      );
      final titleIds = titleMaps.map((m) => m['title_id'] as int).toList();
      return department.copyWith(titleIds: titleIds);
    }));

    return departments;
  }
}
