import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/smart_back_button.dart';
import '../../../../shared/providers/shared_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _locationEnabled = prefs.getBool('locationEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('locationEnabled', _locationEnabled);
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const SmartBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Preferences'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Theme'),
                    subtitle: Text(_getThemeDisplayName(currentTheme)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showThemeDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Language'),
                    subtitle: Text(languageNotifier.getLanguageDisplayName(currentLanguage.languageCode)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Accessibility'),
                    subtitle: const Text('Text size, contrast, and motion settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.go('/accessibility-settings'),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Receive push notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Location Services'),
                    subtitle: const Text('Allow location access'),
                    value: _locationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _locationEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Legal'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms & Conditions'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showTermsAndConditions(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('FAQ'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showFAQ(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Support'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    subtitle: const Text('App version and information'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showAppInfo(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.contact_support),
                    title: const Text('Contact Support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showContactSupport(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final currentTheme = ref.read(themeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              subtitle: const Text('Always use light theme'),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setTheme(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              subtitle: const Text('Always use dark theme'),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setTheme(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow device theme'),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setTheme(value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageNotifier = ref.read(languageProvider.notifier);
    final currentLanguage = ref.read(languageProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'English',
            'العربية',
            'Français',
            'Español',
            'Deutsch',
          ].map((language) => RadioListTile<String>(
            title: Text(language),
            value: language,
            groupValue: languageNotifier.getLanguageDisplayName(currentLanguage.languageCode),
            onChanged: (value) async {
              if (value != null) {
                final languageCode = languageNotifier.getLanguageCode(value);
                print('DEBUG: Changing language to: $languageCode');
                await languageNotifier.setLanguage(languageCode);
                print('DEBUG: Language changed to: ${languageNotifier.state.languageCode}');
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terms and Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to WADDI Platform. By using our service, you agree to the following terms and conditions:',
                ),
                const SizedBox(height: 16),
                const Text(
                  '1. Acceptance of Terms\n'
                  'By accessing and using WADDI Platform, you accept and agree to be bound by the terms and provision of this agreement.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2. Use License\n'
                  'Permission is granted to temporarily download one copy of the materials (information or software) on WADDI Platform for personal, non-commercial transitory viewing only.',
                ),
                const SizedBox(height: 8),
                const Text(
                  '3. Disclaimer\n'
                  'The materials on WADDI Platform are provided on an \'as is\' basis. WADDI Platform makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                ),
                const SizedBox(height: 8),
                const Text(
                  '4. Limitations\n'
                  'In no event shall WADDI Platform or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on WADDI Platform.',
                ),
                const SizedBox(height: 8),
                const Text(
                  '5. Revisions and Errata\n'
                  'The materials appearing on WADDI Platform could include technical, typographical, or photographic errors. WADDI Platform does not warrant that any of the materials on its website are accurate, complete or current.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information.',
                ),
                const SizedBox(height: 16),
                const Text(
                  '1. Information We Collect\n'
                  'We collect information you provide directly to us, such as when you create an account, make a booking, or contact us.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2. How We Use Your Information\n'
                  'We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.',
                ),
                const SizedBox(height: 8),
                const Text(
                  '3. Information Sharing\n'
                  'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.',
                ),
                const SizedBox(height: 8),
                const Text(
                  '4. Data Security\n'
                  'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                ),
                const SizedBox(height: 8),
                const Text(
                  '5. Your Rights\n'
                  'You have the right to access, update, or delete your personal information. You can also opt out of certain communications.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FAQ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Q: How do I book a venue?\n'
                  'A: Browse venues, select one, choose a room, and follow the booking process.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Q: Can I cancel my booking?\n'
                  'A: Yes, you can cancel your booking through the bookings section in your profile.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Q: How do I contact support?\n'
                  'A: Use the contact support option in settings or email us directly.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Q: Is my payment information secure?\n'
                  'A: Yes, we use industry-standard encryption to protect your payment information.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Q: Can I change my booking details?\n'
                  'A: You can modify your booking details up to 24 hours before the scheduled time.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About WADDI Platform'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WADDI Platform',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A platform for booking venues and event spaces.'),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Browse and search venues'),
            Text('• Book rooms and spaces'),
            Text('• Manage bookings'),
            Text('• User reviews and ratings'),
            Text('• Secure payment processing'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in touch with our support team:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Email: support@waddi.com'),
            Text('Phone: +1 (555) 123-4567'),
            Text('Hours: Monday - Friday, 9 AM - 6 PM'),
            SizedBox(height: 16),
            Text(
              'For urgent issues, please call our support line.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 