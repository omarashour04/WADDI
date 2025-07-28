import 'package:flutter/material.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for help',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.primaryLight.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            enabled: false, // Placeholder
          ),
          const SizedBox(height: 24),
          // Popular Topics
          Text(
            'Popular Topics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _TopicButton(icon: Icons.calendar_month, label: 'Bookings'),
              _TopicButton(icon: Icons.person, label: 'Account'),
              _TopicButton(icon: Icons.payment, label: 'Payments'),
              _TopicButton(icon: Icons.build, label: 'Technical Issues'),
            ],
          ),
          const SizedBox(height: 32),
          // FAQs
          Text(
            'FAQs',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _FaqTile(
            question: 'How do I make a reservation?',
            subtitle: 'Learn how to book a gaming space',
          ),
          _FaqTile(
            question: 'How do I update my profile?',
            subtitle: 'Manage your account details',
          ),
          _FaqTile(
            question: 'What if the app is not working?',
            subtitle: 'Troubleshoot common app issues',
          ),
          const SizedBox(height: 32),
          // Contact Support
          Text(
            'Contact Support',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: AppColors.primary),
            title: const Text('Email...'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Contact support placeholder')));
            },
          ),
        ],
      ),
    );
  }
}

class _TopicButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TopicButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        elevation: 0,
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"$label" topic placeholder')));
      },
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String subtitle;
  const _FaqTile({required this.question, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(question),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('FAQ: $question (placeholder)')));
      },
    );
  }
}
