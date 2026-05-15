import 'package:flutter/material.dart';

class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ItemsScreen')),
      body: const Center(
        child: Text('Items Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
