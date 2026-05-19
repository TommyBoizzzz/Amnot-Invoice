import 'package:flutter/material.dart';
import 'package:invoice_create_app/features/items/presentation/screens/items.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  // ===================== SECTION TITLE =====================
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

  // ===================== CARD =====================
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
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

  // ===================== SETTING ITEM =====================
  Widget buildSettingItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
    );
  }

  Widget divider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
  }

  // ===================== NAVIGATION PLACEHOLDER =====================
  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title screen coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Application Settings',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Manage Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Items, customers, invoices and reports',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= DATA MANAGEMENT =================
              buildSectionTitle(
                'Data Management',
                icon: Icons.folder_open_rounded,
              ),

              buildCard(
                child: Column(
                  children: [
                    buildSettingItem(
                      context: context,
                      title: 'Items',
                      subtitle: 'Manage products and services',
                      icon: Icons.inventory_2_rounded,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ItemsScreen(),
                          ),
                        );
                        _showComingSoon(context, 'Items');
                      },
                    ),
                    divider(),
                    buildSettingItem(
                      context: context,
                      title: 'Customers',
                      subtitle: 'Manage customer information',
                      icon: Icons.people_alt_rounded,
                      color: Colors.green,
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => const CustomerScreen(),
                        //   ),
                        // );
                        _showComingSoon(context, 'Customers');
                      },
                    ),
                    divider(),
                    buildSettingItem(
                      context: context,
                      title: 'Invoice History',
                      subtitle: 'View all saved invoices',
                      icon: Icons.history_rounded,
                      color: Colors.orange,
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => const InvoiceHistoryScreen(),
                        //   ),
                        // );
                        _showComingSoon(context, 'Invoice History');
                      },
                    ),
                    divider(),
                    buildSettingItem(
                      context: context,
                      title: 'Reports',
                      subtitle: 'Sales and profit analysis',
                      icon: Icons.bar_chart_rounded,
                      color: Colors.purple,
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => const ReportScreen(),
                        //   ),
                        // );
                        _showComingSoon(context, 'Reports');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= SYSTEM =================
              buildSectionTitle(
                'System',
                icon: Icons.settings_applications_rounded,
              ),

              buildCard(
                child: Column(
                  children: [
                    buildSettingItem(
                      context: context,
                      title: 'Backup & Restore',
                      subtitle: 'Export and import database',
                      icon: Icons.backup_rounded,
                      color: Colors.teal,
                      onTap: () {
                        _showComingSoon(context, 'Backup & Restore');
                      },
                    ),
                    divider(),
                    buildSettingItem(
                      context: context,
                      title: 'About Application',
                      subtitle: 'Version 1.0.0',
                      icon: Icons.info_outline_rounded,
                      color: Colors.grey,
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Invoice Create App',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= FOOTER =================
              const Text(
                'Invoice Create App • Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
