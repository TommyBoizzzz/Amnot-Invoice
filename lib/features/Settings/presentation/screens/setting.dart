import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ItemsScreen')),
      body: const Center(
        child: Text('Setting Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
