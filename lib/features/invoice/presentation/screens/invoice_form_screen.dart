import 'package:flutter/material.dart';
import 'package:invoice_create_app/features/invoice/presentation/models/invoice.dart';
import 'package:invoice_create_app/features/invoice/presentation/models/invoice_item.dart';
import 'package:invoice_create_app/features/invoice/presentation/screens/invoice_history.dart';
import '../../../../services/database_helper.dart';
import 'invoice_preview_screen.dart';

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

  final List<InvoiceItem> items = [];

  @override
  void dispose() {
    customerController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

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

    // Save to local SQLite
    await DatabaseHelper.instance.insertInvoice(invoice);

    if (!mounted) return;

    // Open invoice preview
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

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Invoice History',
            onPressed: openHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  TextField(
                    controller: customerController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Item Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addItem,
                      child: const Text('Add Item'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('No items added yet')),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Card(
                          child: ListTile(
                            title: Text(item.description),
                            subtitle: Text(
                              '${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('\$${item.total.toStringAsFixed(2)}'),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => removeItem(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: createInvoice,
                      child: const Text('Generate Invoice'),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
