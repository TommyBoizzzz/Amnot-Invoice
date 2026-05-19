import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoice_create_app/features/invoice/presentation/models/invoice_item.dart';
import 'package:invoice_create_app/services/database_helper.dart';

class AdjustItemScreen extends StatefulWidget {
  const AdjustItemScreen({super.key});

  @override
  State<AdjustItemScreen> createState() => _AdjustItemScreenState();
}

class _AdjustItemScreenState extends State<AdjustItemScreen> {
  List<InvoiceItem> catalogItems = [];
  InvoiceItem? selectedItem;

  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(
    text: '1',
  );

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadItems();

    unitPriceController.addListener(() => setState(() {}));
    quantityController.addListener(() => setState(() {}));
  }

  Future<void> loadItems() async {
    final items = await DatabaseHelper.instance.getItems();

    if (!mounted) return;

    setState(() {
      catalogItems = items;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    unitPriceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  int get quantity => int.tryParse(quantityController.text.trim()) ?? 0;
  double get unitPrice => double.tryParse(unitPriceController.text.trim()) ?? 0;
  double get total => quantity * unitPrice;

  void selectItem(InvoiceItem item) {
    setState(() {
      selectedItem = item;

      if (item.unitPrice > 0) {
        unitPriceController.text = item.unitPrice.toStringAsFixed(2);
      }
    });
  }

  void saveItem() {
    if (selectedItem == null) return;

    final adjustedItem = selectedItem!.copyWith(
      description: selectedItem!.itemName,
      quantity: quantity,
      unitPrice: unitPrice,
    );

    Navigator.pop(context, adjustedItem);
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
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
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSummaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 18 : 15,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 20 : 16,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemTile(InvoiceItem item) {
    final isSelected = selectedItem?.id == item.id;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => selectItem(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                  ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                  : const Icon(
                      Icons.inventory_2_outlined,
                      size: 28,
                      color: Color(0xFF6B7280),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.itemCode.isNotEmpty)
                    Text(
                      item.itemCode,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2563EB),
                size: 26,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Adjust Item',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : catalogItems.isEmpty
          ? const Center(
              child: Text(
                'No items found.\nPlease create an item first.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'Select Item',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),

                        ...catalogItems.map(buildItemTile),

                        const SizedBox(height: 24),

                        buildSectionCard(
                          child: Column(
                            children: [
                              buildInputField(
                                label: 'Unit Price',
                                controller: unitPriceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                icon: Icons.attach_money_rounded,
                              ),
                              const SizedBox(height: 20),
                              buildInputField(
                                label: 'Quantity',
                                controller: quantityController,
                                keyboardType: TextInputType.number,
                                icon: Icons.numbers_rounded,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        buildSectionCard(
                          child: Column(
                            children: [
                              buildSummaryRow(
                                'Item',
                                selectedItem?.itemName ?? '--',
                              ),
                              const Divider(height: 24),
                              buildSummaryRow(
                                'Total',
                                '\$${total.toStringAsFixed(2)}',
                                bold: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: selectedItem == null ? null : saveItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            disabledBackgroundColor: const Color(0xFF93C5FD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add to Invoice',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
