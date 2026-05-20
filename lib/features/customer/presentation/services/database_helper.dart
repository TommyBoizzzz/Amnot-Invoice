import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/customer_model.dart';

class CustomerDatabaseHelper {
  static final CustomerDatabaseHelper instance = CustomerDatabaseHelper._init();

  static Database? _database;

  CustomerDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('customer.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2, // 🔥 IMPORTANT: bump version to force upgrade
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        alternativePhone TEXT,
        vatTin TEXT,
        address TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // 🔥 FIX: handle old DB schema
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS customers');
    await _createDB(db, newVersion);
  }

  // =========================
  // CREATE
  // =========================
  Future<int> insertCustomer(Customer customer) async {
    try {
      final db = await database;

      final result = await db.insert('customers', customer.toMap());

      print("✅ CUSTOMER SAVED ID: $result");

      return result;
    } catch (e) {
      print("❌ INSERT ERROR: $e");
      rethrow;
    }
  }

  // =========================
  // READ ALL
  // =========================
  Future<List<Customer>> getCustomers() async {
    try {
      final db = await database;
      final result = await db.query('customers');

      return result.map((e) => Customer.fromMap(e)).toList();
    } catch (e) {
      print("❌ GET ERROR: $e");
      return [];
    }
  }

  // =========================
  // UPDATE
  // =========================
  Future<int> updateCustomer(Customer customer) async {
    try {
      final db = await database;

      return await db.update(
        'customers',
        customer.toMap(),
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    } catch (e) {
      print("❌ UPDATE ERROR: $e");
      rethrow;
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<int> deleteCustomer(int id) async {
    try {
      final db = await database;

      return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("❌ DELETE ERROR: $e");
      rethrow;
    }
  }
}
