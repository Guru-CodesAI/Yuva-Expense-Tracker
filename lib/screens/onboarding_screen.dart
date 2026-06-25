import 'package:flutter/material.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'எளிய\nசெலவு & சேமிப்பு\nஉங்கள் கையில்',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 40),
            // Illustration (Using a placeholder image)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Image.network(
                'https://cdni.iconscout.com/illustration/premium/thumb/elderly-couple-doing-savings-4487140-3726269.png',
                height: 300,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.people_alt_rounded, size: 200, color: Colors.blue),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      SizedBox(width: 15),
                      Text(
                        'தொடங்குங்கள்',
                        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
