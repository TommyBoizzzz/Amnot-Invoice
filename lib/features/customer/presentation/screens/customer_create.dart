import 'package:flutter/material.dart';
import 'package:invoice_create_app/features/customer/presentation/model/customer_model.dart';
import 'package:invoice_create_app/features/customer/presentation/services/database_helper.dart';

class CreateCustomerScreen extends StatefulWidget {
  const CreateCustomerScreen({super.key});

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController altPhoneController = TextEditingController();
  final TextEditingController vatTinController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final CustomerDatabaseHelper _dbHelper = CustomerDatabaseHelper.instance;

  bool _isSaving = false;

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    altPhoneController.dispose();
    vatTinController.dispose();
    addressController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // ✅ ONLY NAME + PHONE REQUIRED
  bool get _isValid =>
      fullNameController.text.trim().isNotEmpty &&
      phoneController.text.trim().isNotEmpty;

  Future<void> _saveCustomer() async {
    final name = fullNameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full Name and Phone Number are required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final customer = Customer(
        id: null,
        fullName: name,
        phoneNumber: phone,
        alternativePhone: altPhoneController.text.trim(),
        vatTin: vatTinController.text.trim(),
        address: addressController.text.trim(), // optional
        note: noteController.text.trim(),
      );

      final id = await _dbHelper.insertCustomer(customer);

      debugPrint("CUSTOMER SAVED ID => $id");

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("SAVE ERROR => $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ======================
  // YOUR FIELD STYLE
  // ======================
  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Customer',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: (_isSaving || !_isValid) ? null : _saveCustomer,
            child: Text(
              _isSaving ? "Saving..." : "Save",
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= CARD 1 =================
            _buildCard(
              child: Column(
                children: [
                  _buildField(
                    label: "Full Name *",
                    hint: "Enter full name",
                    controller: fullNameController,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: "Phone Number *",
                    hint: "Enter phone number",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: "Alternative Phone",
                    hint: "Optional",
                    controller: altPhoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= CARD 2 =================
            _buildCard(
              child: Column(
                children: [
                  _buildField(
                    label: "VAT / TIN",
                    hint: "Optional tax number",
                    controller: vatTinController,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    label: "Address",
                    hint: "Optional address",
                    controller: addressController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= CARD 3 =================
            _buildCard(
              child: _buildField(
                label: "Note",
                hint: "Write note (optional)",
                controller: noteController,
                maxLines: 4,
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
