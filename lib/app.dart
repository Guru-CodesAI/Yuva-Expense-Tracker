import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/app_controller.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';

class YuvaApp extends StatelessWidget {
  const YuvaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppController()..init(),
      child: MaterialApp(
        title: 'யுவா சேமிப்பு', // Yuva Savings in Tamil
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const OnboardingScreen(),
      ),
    );
  }
}
