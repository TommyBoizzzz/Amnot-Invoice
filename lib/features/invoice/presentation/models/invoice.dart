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

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  double get tax => subtotal * taxRate;

  double get grandTotal => subtotal + tax;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'taxRate': taxRate,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map, List<InvoiceItem> items) {
    return Invoice(
      id: map['id'],
      customerName: map['customer_name'] ?? map['customerName'],
      items: items,
      taxRate: (map['tax_rate'] ?? map['taxRate'] ?? 0.10).toDouble(),
      createdAt: DateTime.parse(
        map['created_at'] ??
            map['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Invoice copyWith({
    int? id,
    String? customerName,
    List<InvoiceItem>? items,
    double? taxRate,
    DateTime? createdAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      taxRate: taxRate ?? this.taxRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
