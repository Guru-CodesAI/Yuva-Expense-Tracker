import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/app_controller.dart';
import '../theme.dart';
import '../services/pdf_service.dart';
import 'package:intl/intl.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    
    // Filter expenses by selected month and year
    final filteredExpenses = controller.expenses.where((e) => 
      e.date.month == _selectedMonth.month && e.date.year == _selectedMonth.year
    ).toList();

    double monthlyTotal = filteredExpenses.fold(0, (sum, e) => sum + e.amount);
    double monthlySavings = controller.monthlySalary - monthlyTotal;

    // Group expenses by category
    Map<String, double> categoryTotals = {};
    for (var expense in filteredExpenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('மாத சுருக்கம்', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () => PdfService.exportExpenseSummary(
              expenses: filteredExpenses,
              totalExpense: monthlyTotal,
              savings: monthlySavings,
              salary: controller.monthlySalary,
              month: _selectedMonth,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _previousMonth,
                ),
                const SizedBox(width: 20),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Pie Chart
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 70,
                      sections: _buildPieSections(categoryTotals),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('மொத்த செலவு', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        '₹${monthlyTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Legend / Category List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: categoryTotals.isEmpty 
                ? const Center(child: Text('இந்த மாதம் செலவுகள் இல்லை'))
                : Column(
                children: categoryTotals.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text('₹${entry.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Savings Card
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: Colors.orange, size: 40),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('இந்த மாத சேமிப்பு', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text(
                          '₹${monthlySavings.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.monetization_on_rounded, color: Colors.orangeAccent, size: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> data) {
    if (data.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '',
          radius: 40,
        )
      ];
    }
    
    return data.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '',
        radius: 40,
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'மளிகை': return Colors.orange;
      case 'மருந்து': return Colors.teal;
      case 'பில்': return Colors.blue;
      case 'போக்குவரத்து': return Colors.indigo;
      case 'உணவு': return Colors.red;
      default: return Colors.purple;
    }
  }
}
