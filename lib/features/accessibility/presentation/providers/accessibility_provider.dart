import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/accessibility_settings.dart';

class AccessibilityNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilityNotifier() : super(AccessibilitySettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // First try to load saved settings
      final savedSettings = await AccessibilitySettings.load();
      
      // If no saved settings exist, use device defaults
      if (savedSettings.textScaleFactor == 1.0 && 
          !savedSettings.screenReaderEnabled && 
          !savedSettings.highContrastEnabled) {
        // This means no custom settings were saved, so we'll detect device settings
        // We'll set this in the UI when context is available
        state = savedSettings;
      } else {
        // Use saved settings
        state = savedSettings;
      }
    } catch (e) {
      print('Error loading accessibility settings: $e');
      // Fallback to default settings
      state = AccessibilitySettings();
    }
  }

  Future<void> updateSettings(AccessibilitySettings settings) async {
    try {
      await settings.save();
      state = settings;
    } catch (e) {
      print('Error saving accessibility settings: $e');
    }
  }

  // Detect and apply device settings
  Future<void> detectAndApplyDeviceSettings(BuildContext context) async {
    try {
      final deviceSettings = await AccessibilitySettings.detectDeviceSettings(context);
      
      // Merge device settings with any user customizations
      final mergedSettings = AccessibilitySettings(
        screenReaderEnabled: deviceSettings.screenReaderEnabled,
        textScaleFactor: deviceSettings.textScaleFactor,
        highContrastEnabled: deviceSettings.highContrastEnabled,
        reduceMotionEnabled: deviceSettings.reduceMotionEnabled,
        boldTextEnabled: deviceSettings.boldTextEnabled,
        largeTextEnabled: deviceSettings.largeTextEnabled,
        showAnimations: deviceSettings.showAnimations,
      );
      
      await updateSettings(mergedSettings);
      print('Device accessibility settings detected and applied');
    } catch (e) {
      print('Error detecting device accessibility settings: $e');
    }
  }

  // Reset to device defaults
  Future<void> resetToDeviceDefaults(BuildContext context) async {
    try {
      final deviceSettings = await AccessibilitySettings.detectDeviceSettings(context);
      await updateSettings(deviceSettings);
    } catch (e) {
      print('Error resetting to device defaults: $e');
    }
  }

  // Reset to app defaults
  Future<void> resetToAppDefaults() async {
    try {
      final defaultSettings = AccessibilitySettings();
      await updateSettings(defaultSettings);
    } catch (e) {
      print('Error resetting to app defaults: $e');
    }
  }

  // Toggle methods for individual settings
  Future<void> setTextScaleFactor(double factor) async {
    final newSettings = state.copyWith(textScaleFactor: factor);
    await updateSettings(newSettings);
  }

  Future<void> toggleBoldText() async {
    final newSettings = state.copyWith(boldTextEnabled: !state.boldTextEnabled);
    await updateSettings(newSettings);
  }

  Future<void> toggleLargeText() async {
    final newSettings = state.copyWith(largeTextEnabled: !state.largeTextEnabled);
    await updateSettings(newSettings);
  }

  Future<void> toggleHighContrast() async {
    final newSettings = state.copyWith(highContrastEnabled: !state.highContrastEnabled);
    await updateSettings(newSettings);
  }

  Future<void> toggleAnimations() async {
    final newSettings = state.copyWith(showAnimations: !state.showAnimations);
    await updateSettings(newSettings);
  }

  Future<void> toggleReduceMotion() async {
    final newSettings = state.copyWith(reduceMotionEnabled: !state.reduceMotionEnabled);
    await updateSettings(newSettings);
  }

  Future<void> toggleScreenReader() async {
    final newSettings = state.copyWith(screenReaderEnabled: !state.screenReaderEnabled);
    await updateSettings(newSettings);
  }
}

final accessibilityProvider = StateNotifierProvider<AccessibilityNotifier, AccessibilitySettings>((ref) {
  return AccessibilityNotifier();
}); 