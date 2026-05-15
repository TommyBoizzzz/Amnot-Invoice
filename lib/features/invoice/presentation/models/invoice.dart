import 'invoice_item.dart';

class Invoice {
  final int? id;
  final String customerName;
  final List<InvoiceItem> items;
  final double taxRate;
  final DateTime createdAt;

  Invoice({
    this.id,
    required this.customerName,
    required this.items,
    this.taxRate = 0.10,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.total);

  double get tax => subtotal * taxRate;

  double get grandTotal => subtotal + tax;
}