import 'dart:convert';
import 'package:invoice_create_app/features/invoice/presentation/models/invoice.dart';
import 'package:invoice_create_app/features/invoice/presentation/models/invoice_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('invoice.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Invoices table
        await db.execute('''
          CREATE TABLE invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT NOT NULL,
            items_json TEXT NOT NULL,
            tax_rate REAL NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        // Item catalog table
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,
            item_code TEXT,
            note TEXT,
            image_path TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              item_name TEXT NOT NULL,
              item_code TEXT,
              note TEXT,
              image_path TEXT,
              created_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  // =========================================================
  // INVOICE METHODS
  // =========================================================

  Future<int> insertInvoice(Invoice invoice) async {
    final db = await database;

    final itemsJson = jsonEncode(
      invoice.items.map((item) {
        return {
          'id': item.id,
          'itemName': item.itemName,
          'itemCode': item.itemCode,
          'note': item.note,
          'imagePath': item.imagePath,
          'description': item.description,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
        };
      }).toList(),
    );

    return db.insert('invoices', {
      'customer_name': invoice.customerName,
      'items_json': itemsJson,
      'tax_rate': invoice.taxRate,
      'created_at': invoice.createdAt.toIso8601String(),
    });
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final maps = await db.query('invoices', orderBy: 'id DESC');

    return maps.map((map) {
      final decoded = jsonDecode(map['items_json'] as String) as List;

      final items = decoded.map((item) {
        return InvoiceItem(
          id: item['id'],
          itemName: item['itemName'] ?? '',
          itemCode: item['itemCode'] ?? '',
          note: item['note'] ?? '',
          imagePath: item['imagePath'] ?? '',
          description: item['description'] ?? '',
          quantity: item['quantity'],
          unitPrice: (item['unitPrice'] as num).toDouble(),
        );
      }).toList();

      return Invoice(
        id: map['id'] as int,
        customerName: map['customer_name'] as String,
        items: items,
        taxRate: (map['tax_rate'] as num).toDouble(),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    }).toList();
  }

  Future<void> deleteInvoice(int id) async {
    final db = await database;
    await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================
  // ITEM CATALOG METHODS
  // =========================================================

  Future<int> insertItem(InvoiceItem item) async {
    final db = await database;

    return db.insert('items', {
      'item_name': item.itemName,
      'item_code': item.itemCode,
      'note': item.note,
      'image_path': item.imagePath,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<InvoiceItem>> getItems() async {
    final db = await database;
    final maps = await db.query(
      'items',
      orderBy: 'item_name ASC',
    );

    return maps.map((map) {
      return InvoiceItem(
        id: map['id'] as int,
        itemName: map['item_name'] as String,
        itemCode: map['item_code'] as String? ?? '',
        note: map['note'] as String? ?? '',
        imagePath: map['image_path'] as String? ?? '',
        description: map['note'] as String? ?? '',
        quantity: 1,
        unitPrice: 0,
      );
    }).toList();
  }

  Future<int> updateItem(InvoiceItem item) async {
    final db = await database;

    return db.update(
      'items',
      {
        'item_name': item.itemName,
        'item_code': item.itemCode,
        'note': item.note,
        'image_path': item.imagePath,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;

    return db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}