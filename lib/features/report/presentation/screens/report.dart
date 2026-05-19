import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // ===================== MONTH LIST =====================
  final List<String> months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late String selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateFormat('MMMM').format(DateTime.now());
  }

  // ===================== EXPORT FUNCTION =====================
  void exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting $selectedMonth report to Excel...')),
    );

    // TODO:
    // Call your Excel export function here
    // Example:
    // await ExcelService.exportMonthlyReport(selectedMonth);
  }

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

  // ===================== STAT CARD =====================
  Widget buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== REPORT ITEM =====================
  Widget buildReportItem({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget divider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
  }

  // ===================== EXPORT SECTION =====================
  Widget buildExportSection() {
    return buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Month',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),

          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonth,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: months.map((month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMonth = value;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Export Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: exportReport,
              icon: const Icon(Icons.download_rounded),
              label: Text(
                'Export $selectedMonth',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    final currentMonthYear = DateFormat('MMMM yyyy').format(DateTime.now());

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Sales Overview',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '\$12,450.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total Revenue - $currentMonthYear',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= QUICK SUMMARY =================
              buildSectionTitle('Quick Summary', icon: Icons.analytics_rounded),

              buildCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        buildStatCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Invoices',
                          value: '48',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        buildStatCard(
                          icon: Icons.people_alt_rounded,
                          title: 'Customers',
                          value: '22',
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        buildStatCard(
                          icon: Icons.trending_up_rounded,
                          title: 'Avg Sale',
                          value: '\$259',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        buildStatCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Profit',
                          value: '\$5,430',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= RECENT REPORTS =================
              buildSectionTitle('Recent Reports', icon: Icons.history_rounded),

              buildCard(
                child: Column(
                  children: [
                    buildReportItem(
                      title: 'Monthly Sales Report',
                      subtitle: currentMonthYear,
                      value: '\$12,450',
                      icon: Icons.bar_chart_rounded,
                      color: Colors.blue,
                    ),
                    divider(),
                    buildReportItem(
                      title: 'Customer Summary',
                      subtitle: '22 Active Customers',
                      value: '22',
                      icon: Icons.people_alt_rounded,
                      color: Colors.green,
                    ),
                    divider(),
                    buildReportItem(
                      title: 'Profit Analysis',
                      subtitle: 'Net Income',
                      value: '\$5,430',
                      icon: Icons.analytics_rounded,
                      color: Colors.purple,
                    ),
                    divider(),
                    buildReportItem(
                      title: 'Invoice Summary',
                      subtitle: 'Total Invoices',
                      value: '48',
                      icon: Icons.receipt_rounded,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= EXPORT SECTION =================
              buildSectionTitle(
                'Export to Excel',
                icon: Icons.file_download_rounded,
              ),

              buildExportSection(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
