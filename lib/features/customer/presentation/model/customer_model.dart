class Customer {
  final int? id;
  final String fullName;
  final String phoneNumber;
  final String alternativePhone;
  final String vatTin;
  final String address;
  final String note;

  Customer({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    this.alternativePhone = '',
    this.vatTin = '',
    required this.address,
    this.note = '',
  }) {
    // 🔥 runtime safety (extra protection)
    assert(fullName.isNotEmpty, "fullName cannot be empty");
    assert(phoneNumber.isNotEmpty, "phoneNumber cannot be empty");
  }

  Customer copyWith({
    int? id,
    String? fullName,
    String? phoneNumber,
    String? alternativePhone,
    String? vatTin,
    String? address,
    String? note,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      vatTin: vatTin ?? this.vatTin,
      address: address ?? this.address,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'alternativePhone': alternativePhone,
      'vatTin': vatTin,
      'address': address,
      'note': note,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    final fullName = map['fullName'];
    final phoneNumber = map['phoneNumber'];

    if (fullName == null || phoneNumber == null) {
      throw Exception("Invalid database data: fullName or phoneNumber is null");
    }

    return Customer(
      id: map['id'],
      fullName: fullName,
      phoneNumber: phoneNumber,
      alternativePhone: map['alternativePhone'] ?? '',
      vatTin: map['vatTin'] ?? '',
      address: map['address'] ?? '',
      note: map['note'] ?? '',
    );
  }
}
