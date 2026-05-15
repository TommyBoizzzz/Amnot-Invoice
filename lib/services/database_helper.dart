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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT NOT NULL,
            items_json TEXT NOT NULL,
            tax_rate REAL NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertInvoice(Invoice invoice) async {
    final db = await database;

    final itemsJson = jsonEncode(
      invoice.items
          .map(
            (item) => {
              'description': item.description,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
            },
          )
          .toList(),
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
          description: item['description'],
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
    await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }
}
