import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/app_controller.dart';
import '../theme.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('அமைப்புகள்', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor,
                    backgroundImage: controller.avatarPath != null ? FileImage(File(controller.avatarPath!)) : null,
                    child: controller.avatarPath == null 
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(controller.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(controller.userEmail, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            _buildSettingsItem(Icons.account_balance_wallet, 'சம்பளம் அமைக்க', () => _showSalaryDialog(context, controller)),
            _buildSettingsItem(Icons.category, 'வகைகள் மேலாண்மை', () => _showCategoriesDialog(context)),
            _buildSettingsItem(Icons.volume_up, 'ஒலி & மொழி', () => _showLanguageDialog(context)),
            _buildSettingsItem(Icons.security, 'தனியுரிமை/பகிர்வு', () => _showShareAndPrivacy(context)),
            _buildSettingsItem(Icons.help_outline, 'உதவி & ஆதரவு', () => _showHelpDialog(context)),
          ],
        ),
      ),
    );
  }

  void _showCategoriesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('செலவு வகைகள்', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppController.tamilCategories.map((cat) => ListTile(
            leading: const Icon(Icons.check_circle, color: AppTheme.successColor),
            title: Text(cat, style: const TextStyle(fontSize: 18)),
          )).toList(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('சரி', style: TextStyle(fontSize: 18)))],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('மொழி தேர்வு', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryColor),
              title: const Text('தமிழ்', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.check_circle, color: AppTheme.successColor),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.grey),
              title: const Text('English (Coming Soon)', style: TextStyle(fontSize: 18, color: Colors.grey)),
              onTap: () {},
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showShareAndPrivacy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('தனியுரிமை & பகிர்வு', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildActionTile(
              Icons.share_rounded, 
              'நண்பர்களுடன் பகிரவும்', 
              'இந்தச் செயலியை மற்றவர்களுக்கும் தெரியப்படுத்துங்கள்',
              () {
                Navigator.pop(context);
                Share.share('யுவா செலவு மேலாளர்: வயதானவர்களுக்கான எளிய தமிழ் குரல் வழி செலவு கணக்கு செயலி. இப்போதே பதிவிறக்கவும்!');
              }
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              Icons.privacy_tip_rounded, 
              'தனியுரிமைக் கொள்கை', 
              'உங்கள் தரவு எவ்வாறு பாதுகாக்கப்படுகிறது என்பதை அறியுங்கள்',
              () {
                Navigator.pop(context);
                _showPrivacyPolicy(context);
              }
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('தனியுரிமை பாதுகாப்பு', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            '1. உங்கள் தரவு உங்கள் சாதனத்திலேயே பாதுகாப்பாக உள்ளது.\n\n'
            '2. நாங்கள் எந்தவொரு தனிப்பட்ட தகவலையும் இணையத்தில் சேமிப்பதில்லை.\n\n'
            '3. உங்கள் கணக்கு விபரங்கள் முற்றிலும் ரகசியமானது.\n\n'
            '4. விளம்பரங்கள் எதுவும் கிடையாது.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('சரி', style: TextStyle(fontSize: 18)))],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('உதவி & ஆதரவு', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('செயலியைப் பயன்படுத்த உதவி தேவையா? எங்களைத் தொடர்பு கொள்ளவும்.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primaryColor),
              title: const Text('support@yuva.com'),
              onTap: () {},
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('சரி', style: TextStyle(fontSize: 18)))],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showSalaryDialog(BuildContext context, AppController controller) {
    final TextEditingController salaryController = TextEditingController(text: controller.monthlySalary.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('வருமானத்தை மாற்றவும்'),
        content: TextField(
          controller: salaryController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'ரூபாய்', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ரத்து')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(salaryController.text) ?? 0.0;
              controller.setSalary(amount);
              Navigator.pop(context);
            },
            child: const Text('சேமி'),
          ),
        ],
      ),
    );
  }
}
