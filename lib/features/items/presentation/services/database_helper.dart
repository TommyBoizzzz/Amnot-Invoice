import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:invoice_create_app/features/items/presentation/model/item_model.dart';

class ItemDatabaseHelper {
  // Singleton instance
  static final ItemDatabaseHelper instance = ItemDatabaseHelper._init();
  static Database? _database;

  ItemDatabaseHelper._init();

  // GET DATABASE INSTANCE
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('item.db');
    return _database!;
  }

  // INITIALIZE DATABASE
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // CREATE TABLE
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemName TEXT NOT NULL,
        itemCode TEXT,
        note TEXT,
        unitPrice REAL NOT NULL,
        imagePath TEXT
      )
    ''');
  }

  // INSERT ITEM
  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // GET ALL ITEMS
  Future<List<Item>> getItems() async {
    final db = await database;

    final result = await db.query('items', orderBy: 'id DESC');

    return result.map((map) => Item.fromMap(map)).toList();
  }

  // GET ITEM BY ID
  Future<Item?> getItemById(int id) async {
    final db = await database;

    final result = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Item.fromMap(result.first);
    }
    return null;
  }

  // SEARCH ITEMS
  Future<List<Item>> searchItems(String keyword) async {
    final db = await database;

    final result = await db.query(
      'items',
      where: 'itemName LIKE ? OR itemCode LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'id DESC',
    );

    return result.map((map) => Item.fromMap(map)).toList();
  }

  // UPDATE ITEM
  Future<int> updateItem(Item item) async {
    final db = await database;

    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // DELETE ITEM
  Future<int> deleteItem(int id) async {
    final db = await database;

    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // COUNT ITEMS
  Future<int> getItemCount() async {
    final db = await database;

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM items');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // CLOSE DATABASE
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
