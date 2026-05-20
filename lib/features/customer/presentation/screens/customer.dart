import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:invoice_create_app/features/customer/presentation/screens/customer_create.dart';
import 'package:invoice_create_app/features/customer/presentation/screens/customer_update.dart';
import 'package:invoice_create_app/features/customer/presentation/services/database_helper.dart';
import '../model/customer_model.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final CustomerDatabaseHelper _db = CustomerDatabaseHelper.instance;
  final TextEditingController searchController = TextEditingController();

  List<Customer> _customers = [];
  List<Customer> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();

    searchController.addListener(() {
      _filter(searchController.text);
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final data = await _db.getCustomers();

    setState(() {
      _customers = data;
      _filtered = data;
      _loading = false;
    });
  }

  void _filter(String key) {
    if (key.isEmpty) {
      setState(() => _filtered = _customers);
      return;
    }

    final lower = key.toLowerCase();

    setState(() {
      _filtered = _customers.where((c) {
        return c.fullName.toLowerCase().contains(lower) ||
            c.phoneNumber.toLowerCase().contains(lower) ||
            c.address.toLowerCase().contains(lower);
      }).toList();
    });
  }

  Future<void> _openCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateCustomerScreen()),
    );
    await _load();
  }

  Future<void> _delete(int id) async {
    await _db.deleteCustomer(id);
    await _load();
  }

  Widget _buildCard(Customer c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // 👈 spacing between cards
      child: Slidable(
        key: ValueKey(c.id),

        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,

          children: [
            const SizedBox(width: 8), // 👈 GAP between card & Edit
            // ================= EDIT =================
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerUpdateScreen(customer: c),
                    ),
                  );
                  await _load();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 0, bottom: 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                      SizedBox(height: 6),
                      Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ================= DELETE =================
            Expanded(
              child: GestureDetector(
                onTap: () => _confirmDelete(c),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.white, size: 22),
                      SizedBox(height: 6),
                      Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // ================= CARD =================
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.phoneNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Customer c) async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Delete Customer"),
          content: Text("Are you sure you want to delete ${c.fullName}?"),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);

                if (c.id != null) {
                  await _delete(c.id!);
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        title: const Text("Customers"),
        actions: [
          IconButton(onPressed: _openCreate, icon: const Icon(Icons.add)),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search customer...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? const Center(child: Text("No customers found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) => _buildCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
