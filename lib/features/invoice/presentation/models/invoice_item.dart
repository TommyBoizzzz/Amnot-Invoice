class InvoiceItem {
  // Item Catalog Information
  final int? id;
  final String itemName;
  final String itemCode;
  final String note;
  final String imagePath;

  // Invoice Information
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    this.id,
    this.itemName = '',
    this.itemCode = '',
    this.note = '',
    this.imagePath = '',
    String? description,
    this.quantity = 1,
    this.unitPrice = 0,
  }) : description = description ?? (itemName.isNotEmpty ? itemName : '');

  double get total => quantity * unitPrice;

  // Convert to Map (useful for JSON / SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'itemCode': itemCode,
      'note': note,
      'imagePath': imagePath,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  // Create object from Map
  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      itemName: map['itemName'] ?? map['item_name'] ?? '',
      itemCode: map['itemCode'] ?? map['item_code'] ?? '',
      note: map['note'] ?? '',
      imagePath: map['imagePath'] ?? map['image_path'] ?? '',
      description: map['description'],
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unitPrice'] ?? map['unit_price'] ?? 0).toDouble(),
    );
  }

  // Create a copy with modified fields
  InvoiceItem copyWith({
    int? id,
    String? itemName,
    String? itemCode,
    String? note,
    String? imagePath,
    String? description,
    int? quantity,
    double? unitPrice,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
