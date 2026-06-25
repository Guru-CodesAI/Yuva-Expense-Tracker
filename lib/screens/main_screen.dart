import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'summary_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SummaryScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'முகப்பு'),
            BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'சுருக்கம்'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'வரலாறு'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'அமைப்பு'),
          ],
        ),
      ),
    );
  }
}
