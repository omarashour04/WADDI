import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/smart_back_button.dart';
import '../providers/accessibility_provider.dart';

class AccessibilitySettingsPage extends ConsumerWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);
    final notifier = ref.read(accessibilityProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
        leading: const SmartBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Text & Display'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Text Size'),
                    subtitle: Text('${(settings.textScaleFactor * 100).toInt()}%'),
                    trailing: SizedBox(
                      width: 200,
                      child: Slider(
                        value: settings.textScaleFactor,
                        min: 0.8,
                        max: 2.0,
                        divisions: 12,
                        onChanged: (value) {
                          notifier.setTextScaleFactor(value);
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Bold Text'),
                    subtitle: const Text('Make text bold for better readability'),
                    value: settings.boldTextEnabled,
                    onChanged: (value) {
                      notifier.toggleBoldText();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Large Text'),
                    subtitle: const Text('Increase text size throughout the app'),
                    value: settings.largeTextEnabled,
                    onChanged: (value) {
                      notifier.toggleLargeText();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader('Visual'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('High Contrast'),
                    subtitle: const Text('Increase contrast for better visibility'),
                    value: settings.highContrastEnabled,
                    onChanged: (value) {
                      notifier.toggleHighContrast();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Show Animations'),
                    subtitle: const Text('Enable or disable app animations'),
                    value: settings.showAnimations,
                    onChanged: (value) {
                      notifier.toggleAnimations();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader('Motion'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Reduce Motion'),
                    subtitle: const Text('Minimize animations and transitions'),
                    value: settings.reduceMotionEnabled,
                    onChanged: (value) {
                      notifier.toggleReduceMotion();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader('Screen Reader'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Screen Reader Support'),
                    subtitle: const Text('Enable enhanced screen reader support'),
                    value: settings.screenReaderEnabled,
                    onChanged: (value) {
                      notifier.toggleScreenReader();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader('Actions'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('Detect Device Settings'),
                    subtitle: const Text('Automatically apply your device accessibility settings'),
                    onTap: () {
                      notifier.detectAndApplyDeviceSettings(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Device accessibility settings detected and applied'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Reset to Device Defaults'),
                    subtitle: const Text('Restore your device accessibility settings'),
                    onTap: () {
                      notifier.resetToDeviceDefaults(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reset to device defaults'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_backup_restore),
                    title: const Text('Reset to App Defaults'),
                    subtitle: const Text('Restore default app accessibility settings'),
                    onTap: () {
                      _showResetDialog(context, notifier);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader('Preview'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Text',
                      style: TextStyle(
                        fontSize: 16 * settings.textScaleFactor,
                        fontWeight: settings.boldTextEnabled ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is how text will appear with your current settings.',
                      style: TextStyle(
                        fontSize: 14 * settings.textScaleFactor,
                        fontWeight: settings.boldTextEnabled ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, AccessibilityNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all accessibility settings to app defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.resetToAppDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reset to app defaults'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
} 