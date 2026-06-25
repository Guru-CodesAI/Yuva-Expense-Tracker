import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    // Note: Use the original list indices carefully if reversed
    final originalExpenses = controller.expenses;
    final reversedIndices = List.generate(originalExpenses.length, (index) => originalExpenses.length - 1 - index);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('செலவு வரலாறு', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: originalExpenses.isEmpty
          ? const Center(child: Text('செலவுகள் எதுவும் இல்லை'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: originalExpenses.length,
              itemBuilder: (context, displayIndex) {
                final originalIndex = reversedIndices[displayIndex];
                final expense = originalExpenses[originalIndex];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(expense.category).withValues(alpha: 0.1),
                      child: Icon(_getCategoryIcon(expense.category), color: _getCategoryColor(expense.category)),
                    ),
                    title: Text(expense.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM, yyyy • hh:mm a').format(expense.date), style: const TextStyle(fontSize: 14)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${expense.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(context, controller, originalIndex);
                            } else if (value == 'delete') {
                              _showDeleteConfirm(context, controller, originalIndex);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('மாற்றுக')])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('நீக்குக', style: TextStyle(color: Colors.red))])),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showEditDialog(BuildContext context, AppController controller, int index) {
    final expense = controller.expenses[index];
    final amountController = TextEditingController(text: expense.amount.toString());
    String selectedCategory = expense.category;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('செலவை மாற்றுக'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'தொகை'),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: AppController.tamilCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategory = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('ரத்து')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                controller.updateExpense(index, amount, selectedCategory, expense.date);
                Navigator.pop(context);
              },
              child: const Text('சேமி'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AppController controller, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('உறுதியாக நீக்க வேண்டுமா?'),
        content: const Text('இந்தச் செலவு விவரம் நிரந்தரமாக நீக்கப்படும்.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('இல்லை')),
          TextButton(
            onPressed: () {
              controller.deleteExpense(index);
              Navigator.pop(context);
            },
            child: const Text('ஆம், நீக்குக', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'மளிகை': return Icons.shopping_basket;
      case 'மருந்து': return Icons.medical_services;
      case 'மின்சாரம்': return Icons.receipt;
      case 'போக்குவரத்து': return Icons.directions_bus;
      case 'உணவு': return Icons.restaurant;
      default: return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'மளிகை': return Colors.orange;
      case 'மருந்து': return Colors.teal;
      case 'மின்சாரம்': return Colors.blue;
      case 'போக்குவரத்து': return Colors.indigo;
      case 'உணவு': return Colors.red;
      default: return Colors.grey;
    }
  }
}
