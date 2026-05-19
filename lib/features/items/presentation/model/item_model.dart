class Item {
  final int? id;
  final String itemName;
  final String itemCode;
  final String note;
  final double unitPrice;
  final String imagePath;

  Item({
    this.id,
    required this.itemName,
    required this.itemCode,
    this.note = '',
    required this.unitPrice,
    this.imagePath = '',
  });

  Item copyWith({
    int? id,
    String? itemName,
    String? itemCode,
    String? note,
    double? unitPrice,
    String? imagePath,
  }) {
    return Item(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      note: note ?? this.note,
      unitPrice: unitPrice ?? this.unitPrice,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'itemCode': itemCode,
      'note': note,
      'unitPrice': unitPrice,
      'imagePath': imagePath,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      itemName: map['itemName'] ?? '',
      itemCode: map['itemCode'] ?? '',
      note: map['note'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      imagePath: map['imagePath'] ?? '',
    );
  }
}
