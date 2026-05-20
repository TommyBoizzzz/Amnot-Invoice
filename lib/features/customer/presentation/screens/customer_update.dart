import 'package:flutter/material.dart';
import 'package:invoice_create_app/features/customer/presentation/model/customer_model.dart';
import 'package:invoice_create_app/features/customer/presentation/services/database_helper.dart';

class CustomerUpdateScreen extends StatefulWidget {
  final Customer customer;

  const CustomerUpdateScreen({super.key, required this.customer});

  @override
  State<CustomerUpdateScreen> createState() => _CustomerUpdateScreenState();
}

class _CustomerUpdateScreenState extends State<CustomerUpdateScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController altPhoneController;
  late TextEditingController vatTinController;
  late TextEditingController addressController;
  late TextEditingController noteController;

  final CustomerDatabaseHelper _db = CustomerDatabaseHelper.instance;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.customer.fullName);
    phoneController = TextEditingController(text: widget.customer.phoneNumber);
    altPhoneController = TextEditingController(
      text: widget.customer.alternativePhone,
    );
    vatTinController = TextEditingController(text: widget.customer.vatTin);
    addressController = TextEditingController(text: widget.customer.address);
    noteController = TextEditingController(text: widget.customer.note);
  }

  Future<void> _update() async {
    final updated = Customer(
      id: widget.customer.id,
      fullName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      alternativePhone: altPhoneController.text.trim(),
      vatTin: vatTinController.text.trim(),
      address: addressController.text.trim(),
      note: noteController.text.trim(),
    );

    await _db.updateCustomer(updated);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Customer"),
        actions: [TextButton(onPressed: _update, child: const Text("Save"))],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field("Full Name", nameController),
            _field("Phone", phoneController),
            _field("Alt Phone", altPhoneController),
            _field("VAT/TIN", vatTinController),
            _field("Address", addressController),
            _field("Note", noteController),
          ],
        ),
      ),
    );
  }
}
