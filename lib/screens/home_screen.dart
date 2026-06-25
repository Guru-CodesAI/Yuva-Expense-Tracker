import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import 'voice_input_screen.dart';
import 'add_expense_screen.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    if (!controller.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'வணக்கம், ${controller.userName}!',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.network('https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Hand%20gestures/Waving%20Hand.png', height: 32, width: 32),
                          ],
                        ),
                        Text(
                          'இன்றைய நிலவரம்',
                          style: TextStyle(fontSize: 16, color: const Color(0xFF757575)),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.notifications_none_rounded, size: 30),
                      const SizedBox(width: 15),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: AppTheme.primaryColor,
                        backgroundImage: controller.avatarPath != null ? FileImage(File(controller.avatarPath!)) : null,
                        child: controller.avatarPath == null 
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Summary Cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSummaryCard(
                      'மாதச் சம்பளம்',
                      '₹${controller.monthlySalary.toStringAsFixed(0)}',
                      Colors.blue.shade400,
                      Icons.account_balance_wallet_rounded,
                    ),
                    _buildSummaryCard(
                      'மொத்த செலவு',
                      '₹${controller.totalExpenses.toStringAsFixed(0)}',
                      Colors.redAccent.shade100,
                      Icons.receipt_long_rounded,
                    ),
                    _buildSummaryCard(
                      'சேமிப்பு',
                      '₹${controller.savings.toStringAsFixed(0)}',
                      Colors.green.shade400,
                      Icons.savings_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Action Buttons
              _buildLargeActionButton(
                context,
                'பேசி செலவு சேர்க்க',
                const [Color(0xFF4285F4), Color(0xFF92278F)],
                Icons.mic_rounded,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceInputScreen())),
              ),
              const SizedBox(height: 15),
              _buildLargeActionButton(
                context,
                'கைமுறையாக சேர்க்க',
                const [Color(0xFFFF9800), Color(0xFFFF5722)],
                Icons.add_rounded,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
              ),

              const SizedBox(height: 30),

              // Quick Categories
              const Text(
                'விரைவு வகைகள்',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickCategory('மருந்து', Icons.medical_services_rounded, Colors.teal),
                  _buildQuickCategory('மளிகை', Icons.shopping_basket_rounded, Colors.orange),
                  _buildQuickCategory('பில்', Icons.receipt_rounded, Colors.blue),
                  _buildQuickCategory('போக்குவரத்து', Icons.directions_bus_rounded, Colors.indigo),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLargeActionButton(BuildContext context, String title, List<Color> gradient, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: gradient[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCategory(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
