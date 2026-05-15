import 'package:flutter/material.dart';
import 'package:invoice_create_app/features/Settings/presentation/screens/setting.dart';
import 'package:invoice_create_app/features/customer/presentation/screens/customer.dart';
import 'package:invoice_create_app/features/invoice/presentation/screens/invoice_form_screen.dart';
import 'package:invoice_create_app/features/items/presentation/screens/items.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ItemScreen(),
    const CustomerScreen(),
    const InvoiceFormScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: _screens[_currentIndex],

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 4 tabs: Items, Customers, Invoices, Settings
                final double itemWidth = constraints.maxWidth / 4;

                return Stack(
                  children: [
                    /// Sliding glass indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      left: _currentIndex * itemWidth,
                      child: Container(
                        width: itemWidth,
                        height: 72,
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1E88E5,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: const Color(
                                0xFF1E88E5,
                              ).withValues(alpha: 0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1E88E5,
                                ).withValues(alpha: 0.20),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// Navigation items
                    Row(
                      children: [
                        _buildItem(Icons.inventory_2_rounded, 'Items', 0),
                        _buildItem(Icons.people_rounded, 'Customers', 1),
                        _buildItem(Icons.receipt_long_rounded, 'Invoices', 2),
                        _buildItem(Icons.settings_rounded, 'Settings', 3),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: isSelected ? 1.25 : 1.0,
              child: Icon(
                icon,
                size: 26,
                color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 4),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[700],
                fontSize: isSelected ? 13.0 : 12.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
