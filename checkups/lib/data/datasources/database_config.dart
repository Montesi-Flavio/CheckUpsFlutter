import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class DatabaseConfig {
  static Future<Database> openDatabase() async {
    return await DatabaseHelper().database;
  }
}
