import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'session.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute("CREATE TABLE session (id INTEGER PRIMARY KEY, expiryTime INTEGER)");
    });
  }

  Future<void> setSessionExpiryTime(int expiryTime) async {
    final db = await database;
    await db.insert("session", {"id": 1, "expiryTime": expiryTime},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int?> getSessionExpiryTime() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query("session", where: "id = 1");
    if (result.isNotEmpty) {
      return result.first["expiryTime"] as int;
    }
    return null;
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete("session");
  }
}
