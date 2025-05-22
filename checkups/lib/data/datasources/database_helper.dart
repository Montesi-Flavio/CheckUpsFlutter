import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'checkups.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Companies table
    await db.execute('''
      CREATE TABLE companies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        fiscalCode TEXT NOT NULL,
        vatNumber TEXT NOT NULL,
        address TEXT,
        city TEXT,
        postalCode TEXT,
        province TEXT,
        country TEXT,
        phone TEXT,
        email TEXT,
        pec TEXT,
        notes TEXT
      )
    ''');

    // Local Units table
    await db.execute('''
      CREATE TABLE local_units (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        companyId INTEGER NOT NULL,
        name TEXT NOT NULL,
        address TEXT,
        city TEXT,
        postalCode TEXT,
        province TEXT,
        country TEXT,
        phone TEXT,
        email TEXT,
        notes TEXT,
        FOREIGN KEY (companyId) REFERENCES companies (id) ON DELETE CASCADE
      )
    ''');

    // Departments table
    await db.execute('''
      CREATE TABLE departments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        localUnitId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        notes TEXT,
        FOREIGN KEY (localUnitId) REFERENCES local_units (id) ON DELETE CASCADE
      )
    ''');

    // Titles table
    await db.execute('''
      CREATE TABLE titles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        departmentId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        notes TEXT,
        FOREIGN KEY (departmentId) REFERENCES departments (id) ON DELETE CASCADE
      )
    ''');

    // Checkup Objects table
    await db.execute('''
      CREATE TABLE checkup_objects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titleId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        notes TEXT,
        FOREIGN KEY (titleId) REFERENCES titles (id) ON DELETE CASCADE
      )
    ''');

    // Provisions table
    await db.execute('''
      CREATE TABLE provisions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        objectId INTEGER NOT NULL,
        name TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        description TEXT,
        notes TEXT,
        completionDate TEXT,
        attachmentPath TEXT,
        FOREIGN KEY (objectId) REFERENCES checkup_objects (id) ON DELETE CASCADE
      )
    ''');

    // Many-to-many relationships
    await db.execute('''
      CREATE TABLE department_titles (
        departmentId INTEGER NOT NULL,
        titleId INTEGER NOT NULL,
        PRIMARY KEY (departmentId, titleId),
        FOREIGN KEY (departmentId) REFERENCES departments (id) ON DELETE CASCADE,
        FOREIGN KEY (titleId) REFERENCES titles (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
