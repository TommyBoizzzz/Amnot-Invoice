// lib/features/items/presentation/screens/update_item_screen.dart

import 'package:flutter/material.dart';
import 'package:invoice_create_app/features/items/presentation/model/item_model.dart';
import 'package:invoice_create_app/features/items/presentation/services/database_helper.dart';

class UpdateItemScreen extends StatefulWidget {
  final Item item;

  const UpdateItemScreen({super.key, required this.item});

  @override
  State<UpdateItemScreen> createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final ItemDatabaseHelper _dbHelper = ItemDatabaseHelper.instance;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.item.itemName;
    codeController.text = widget.item.itemCode;
    noteController.text = widget.item.note;
    priceController.text = widget.item.unitPrice.toString();
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    noteController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // ================= UPDATE ITEM =================
  Future<void> _updateItem() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item name is required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updatedItem = Item(
      id: widget.item.id,
      itemName: nameController.text.trim(),
      itemCode: codeController.text.trim(),
      note: noteController.text.trim(),
      unitPrice: double.tryParse(priceController.text.trim()) ?? 0.0,
      imagePath: widget.item.imagePath,
    );

    await _dbHelper.updateItem(updatedItem);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  // ================= INPUT FIELD =================
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
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

  // ================= CARD =================
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

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Update Item',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _updateItem,
            child: Text(
              _isSaving ? 'Saving...' : 'Update',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BASIC INFO
            _buildCard(
              child: Column(
                children: [
                  _buildField(
                    label: 'Item Name',
                    hint: 'Enter item name',
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Item Code',
                    hint: 'Enter item code',
                    controller: codeController,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Unit Price',
                    hint: '0.00',
                    controller: priceController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // NOTE
            _buildCard(
              child: _buildField(
                label: 'Note',
                hint: 'Write your note',
                controller: noteController,
                maxLines: 4,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
