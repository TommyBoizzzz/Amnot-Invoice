// lib/features/items/presentation/screens/items_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:invoice_create_app/features/items/presentation/model/item_model.dart';
import 'package:invoice_create_app/features/items/presentation/screens/items_create.dart';
import 'package:invoice_create_app/features/items/presentation/screens/items_update&delete.dart';
import 'package:invoice_create_app/features/items/presentation/services/database_helper.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final TextEditingController searchController = TextEditingController();
  final ItemDatabaseHelper _dbHelper = ItemDatabaseHelper.instance;

  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();

    searchController.addListener(() {
      _filterItems(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // LOAD ITEMS
  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    final items = await _dbHelper.getItems();

    if (!mounted) return;

    setState(() {
      _items = items;
      _filteredItems = items;
      _isLoading = false;
    });
  }

  // FILTER ITEMS
  void _filterItems(String keyword) {
    if (keyword.trim().isEmpty) {
      setState(() {
        _filteredItems = _items;
      });
      return;
    }

    final lower = keyword.toLowerCase();

    setState(() {
      _filteredItems = _items.where((item) {
        return item.itemName.toLowerCase().contains(lower) ||
            item.itemCode.toLowerCase().contains(lower) ||
            item.note.toLowerCase().contains(lower);
      }).toList();
    });
  }

  // OPEN CREATE SCREEN
  Future<void> _openCreateItemScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateItemScreen()),
    );

    await _loadItems();
  }

  // DELETE ITEM
  Future<void> _deleteItem(int id) async {
    await _dbHelper.deleteItem(id);
    await _loadItems();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // SHOW FULL IMAGE
  void _showFullImage(String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ITEM IMAGE
  Widget _buildItemImage(Item item) {
    final hasImage =
        item.imagePath.isNotEmpty && File(item.imagePath).existsSync();

    return GestureDetector(
      onLongPress: hasImage
          ? () {
              _showFullImage(item.imagePath);
            }
          : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(14),
          image: hasImage
              ? DecorationImage(
                  image: FileImage(File(item.imagePath)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: !hasImage
            ? const Icon(Icons.inventory_2_rounded, color: Color(0xFF2563EB))
            : null,
      ),
    );
  }

  // ITEM CARD
  Widget _buildItemCard(Item item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (item.id != null) {
          _deleteItem(item.id!);
        }
      },

      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UpdateItemScreen(item: item)),
          );

          await _loadItems();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildItemImage(item),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.itemCode.isEmpty ? "No Code" : item.itemCode} • \$${item.unitPrice.toStringAsFixed(2)}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Items',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _openCreateItemScreen,
              icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search item...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items found',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadItems,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return _buildItemCard(item);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
