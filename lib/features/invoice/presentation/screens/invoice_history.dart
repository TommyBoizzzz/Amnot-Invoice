import 'package:flutter/material.dart';
import 'package:invoice_create_app/features/invoice/presentation/models/invoice.dart';
import '../services/database_helper.dart';
import 'invoice_preview_screen.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  late Future<List<Invoice>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  void _loadInvoices() {
    _invoicesFuture = DatabaseHelper.instance.getInvoices();
  }

  Future<void> _refreshInvoices() async {
    setState(() {
      _loadInvoices();
    });
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    if (invoice.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete invoice for ${invoice.customerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await DatabaseHelper.instance.deleteInvoice(invoice.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice deleted successfully')),
    );

    _refreshInvoices();
  }

  void _openInvoice(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoice: invoice)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice History')),
      body: RefreshIndicator(
        onRefresh: _refreshInvoices,
        child: FutureBuilder<List<Invoice>>(
          future: _invoicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final invoices = snapshot.data ?? [];

            if (invoices.isEmpty) {
              return const Center(
                child: Text(
                  'No invoices found',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        invoice.customerName.isNotEmpty
                            ? invoice.customerName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      invoice.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${_formatDate(invoice.createdAt)}'),
                        Text('Items: ${invoice.items.length}'),
                        Text(
                          'Total: \$${invoice.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => _openInvoice(invoice),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteInvoice(invoice),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
