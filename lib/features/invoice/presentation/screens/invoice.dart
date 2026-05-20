import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_create_app/features/invoice/presentation/models/invoice.dart';
import 'package:invoice_create_app/features/invoice/presentation/models/invoice_item.dart';
import 'package:invoice_create_app/features/invoice/presentation/screens/invoice_history.dart';
import 'package:invoice_create_app/features/invoice/presentation/screens/invoice_preview_screen.dart';
import '../services/database_helper.dart';

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final TextEditingController customerController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  DateTime invoiceDate = DateTime.now();
  final List<InvoiceItem> items = [];

  // Summary values
  double discount = 0;
  double deliveryFee = 0;
  double vat = 0;
  double deposit = 0;

  @override
  void dispose() {
    customerController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // ===================== CALCULATIONS =====================

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);

  double get discountAmount => subtotal * (discount / 100);

  double get vatAmount =>
      ((subtotal - discountAmount) + deliveryFee) * (vat / 100);

  double get total =>
      subtotal - discountAmount + deliveryFee + vatAmount - deposit;

  // ===================== ITEM METHODS =====================

  void addItem() {
    if (descriptionController.text.isEmpty ||
        quantityController.text.isEmpty ||
        priceController.text.isEmpty) {
      return;
    }

    final item = InvoiceItem(
      description: descriptionController.text,
      quantity: int.parse(quantityController.text),
      unitPrice: double.parse(priceController.text),
    );

    setState(() {
      items.add(item);
    });

    descriptionController.clear();
    quantityController.clear();
    priceController.clear();
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  // ===================== DATE PICKER =====================

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        invoiceDate = picked;
      });
    }
  }

  // ===================== SAVE INVOICE =====================

  Future<void> createInvoice() async {
    if (customerController.text.isEmpty || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter customer name and add at least one item.',
          ),
        ),
      );
      return;
    }

    final invoice = Invoice(
      customerName: customerController.text,
      items: List.from(items),
    );

    await DatabaseHelper.instance.insertInvoice(invoice);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoice: invoice)),
    );
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InvoiceHistoryScreen()),
    );
  }

  // ===================== BEAUTIFUL UI HELPERS =====================

  Widget buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFCFCFD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildRowItem(
    String label,
    String value, {
    bool bold = false,
    VoidCallback? onTap,
  }) {
    final isClickable = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: const Color(0xFF2563EB).withOpacity(0.06),
        highlightColor: const Color(0xFF2563EB).withOpacity(0.03),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Row(
            children: [
              // Label
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: bold ? 21 : 16,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                    color: bold
                        ? const Color(0xFF111827)
                        : const Color(0xFF374151),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Value
              Expanded(
                flex: 5,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: bold ? 21 : 16,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    color: bold
                        ? const Color(0xFF111827)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),

              // Arrow >
              if (isClickable) ...[
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRowItems(
    String label,
    String value, {
    bool bold = false,
    VoidCallback? onTap,
  }) {
    final isClickable = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: bold ? 22 : 17,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF111827),
                ),
              ),
            ),

            // Value
            Text(
              value,
              style: TextStyle(
                fontSize: bold ? 22 : 17,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? const Color(0xFF111827) : const Color(0xFF6B7280),
              ),
            ),

            // Arrow >
            if (isClickable) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 22,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Divider(height: 1, thickness: 1, color: const Color(0xFFF3F4F6)),
    );
  }

  // ===================== BUILD METHOD =====================

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd MMM yyyy').format(invoiceDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Light gray background
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF9FAFB),
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 90,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Left Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Create Invoice',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'USD Currency',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Done Button
              GestureDetector(
                onTap: createInvoice,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildSectionTitle('Invoice Info'),
              buildCard(
                child: Column(
                  children: [
                    buildRowItem('Invoice Date', dateText, onTap: pickDate),
                    divider(),
                    buildRowItem(
                      'Customer',
                      customerController.text.isEmpty
                          ? 'Select Customer'
                          : customerController.text,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= Items =================
              buildSectionTitle('Items'),
              buildCard(
                child: Column(
                  children: [
                    if (items.isNotEmpty)
                      ...List.generate(items.length, (index) {
                        final item = items[index];
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.description,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${item.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => removeItem(index),
                                ),
                              ],
                            ),
                            if (index != items.length - 1) ...[
                              const SizedBox(height: 12),
                              divider(),
                              const SizedBox(height: 12),
                            ],
                          ],
                        );
                      }),

                    if (items.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      divider(),
                      const SizedBox(height: 16),
                    ],

                    InkWell(
                      // onTap: () async {
                      //   final InvoiceItem? item = await Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (_) => const AdjustItemScreen(),
                      //     ),
                      //   );

                      //   if (item != null) {
                      //     setState(() {
                      //       items.add(item);
                      //     });
                      //   }
                      // },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Item',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // // ================= Summary =================
              buildSectionTitle('Summary'),
              buildCard(
                child: Column(
                  children: [
                    buildRowItems(
                      'Discount',
                      '${discount.toStringAsFixed(0)}%',
                      onTap: () {
                        // Open Discount page or dialog
                      },
                    ),
                    divider(),

                    buildRowItems(
                      'Delivery Fee',
                      '\$${deliveryFee.toStringAsFixed(2)}',
                      onTap: () {
                        // Open Delivery Fee page or dialog
                      },
                    ),
                    divider(),

                    buildRowItems(
                      'VAT',
                      '${vat.toStringAsFixed(2)}%',
                      onTap: () {
                        // Open VAT page or dialog
                      },
                    ),
                    divider(),

                    buildRowItems(
                      'Deposit',
                      '\$${deposit.toStringAsFixed(2)}',
                      onTap: () {
                        // Open Deposit page or dialog
                      },
                    ),
                    divider(),

                    buildRowItems(
                      'Total',
                      '\$${total.toStringAsFixed(2)}',
                      // bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ================= Note =================
              buildSectionTitle('Note'),
              buildCard(child: buildRowItem('Invoice Note', '--')),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
