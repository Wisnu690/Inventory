import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  // 🔥 INIT DATABASE
  initDb() async {
    String path = join(await getDatabasesPath(), 'inventory.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // TABLE ITEMS
        await db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            stock INTEGER
          )
        ''');

        // TABLE CATEGORIES
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
      },
    );
  }

  // 🔥 CRUD CATEGORY (DI LUAR initDb)

  // ➕ Insert
  Future<void> insertCategory(String name) async {
    final database = await db;
    await database.insert('categories', {
      'name': name,
    });
  }

  // 📥 Get
  Future<List<Map<String, dynamic>>> getCategories() async {
    final database = await db;
    return await database.query('categories');
  }

  // ❌ Delete
  Future<void> deleteCategory(int id) async {
    final database = await db;
    await database.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✏️ Update
  Future<void> updateCategory(int id, String name) async {
    final database = await db;
    await database.update(
      'categories',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}