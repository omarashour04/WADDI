import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AccessibilitySettings {
  final bool screenReaderEnabled;
  final double textScaleFactor;
  final bool highContrastEnabled;
  final bool reduceMotionEnabled;
  final bool boldTextEnabled;
  final bool largeTextEnabled;
  final bool showAnimations;

  AccessibilitySettings({
    this.screenReaderEnabled = false,
    this.textScaleFactor = 1.0,
    this.highContrastEnabled = false,
    this.reduceMotionEnabled = false,
    this.boldTextEnabled = false,
    this.largeTextEnabled = false,
    this.showAnimations = true,
  });

  AccessibilitySettings copyWith({
    bool? screenReaderEnabled,
    double? textScaleFactor,
    bool? highContrastEnabled,
    bool? reduceMotionEnabled,
    bool? boldTextEnabled,
    bool? largeTextEnabled,
    bool? showAnimations,
  }) {
    return AccessibilitySettings(
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      highContrastEnabled: highContrastEnabled ?? this.highContrastEnabled,
      reduceMotionEnabled: reduceMotionEnabled ?? this.reduceMotionEnabled,
      boldTextEnabled: boldTextEnabled ?? this.boldTextEnabled,
      largeTextEnabled: largeTextEnabled ?? this.largeTextEnabled,
      showAnimations: showAnimations ?? this.showAnimations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'screenReaderEnabled': screenReaderEnabled,
      'textScaleFactor': textScaleFactor,
      'highContrastEnabled': highContrastEnabled,
      'reduceMotionEnabled': reduceMotionEnabled,
      'boldTextEnabled': boldTextEnabled,
      'largeTextEnabled': largeTextEnabled,
      'showAnimations': showAnimations,
    };
  }

  factory AccessibilitySettings.fromMap(Map<String, dynamic> map) {
    return AccessibilitySettings(
      screenReaderEnabled: map['screenReaderEnabled'] ?? false,
      textScaleFactor: (map['textScaleFactor'] ?? 1.0).toDouble(),
      highContrastEnabled: map['highContrastEnabled'] ?? false,
      reduceMotionEnabled: map['reduceMotionEnabled'] ?? false,
      boldTextEnabled: map['boldTextEnabled'] ?? false,
      largeTextEnabled: map['largeTextEnabled'] ?? false,
      showAnimations: map['showAnimations'] ?? true,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsMap = toMap();
    for (final entry in settingsMap.entries) {
      if (entry.value is bool) {
        await prefs.setBool('accessibility_${entry.key}', entry.value as bool);
      } else if (entry.value is double) {
        await prefs.setDouble('accessibility_${entry.key}', entry.value as double);
      }
    }
  }

  static Future<AccessibilitySettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AccessibilitySettings(
      screenReaderEnabled: prefs.getBool('accessibility_screenReaderEnabled') ?? false,
      textScaleFactor: prefs.getDouble('accessibility_textScaleFactor') ?? 1.0,
      highContrastEnabled: prefs.getBool('accessibility_highContrastEnabled') ?? false,
      reduceMotionEnabled: prefs.getBool('accessibility_reduceMotionEnabled') ?? false,
      boldTextEnabled: prefs.getBool('accessibility_boldTextEnabled') ?? false,
      largeTextEnabled: prefs.getBool('accessibility_largeTextEnabled') ?? false,
      showAnimations: prefs.getBool('accessibility_showAnimations') ?? true,
    );
  }

  // Detect device accessibility settings
  static Future<AccessibilitySettings> detectDeviceSettings(BuildContext context) async {
    final mediaQuery = MediaQuery.of(context);
    final platformDispatcher = PlatformDispatcher.instance;
    
    return AccessibilitySettings(
      screenReaderEnabled: mediaQuery.accessibleNavigation,
      textScaleFactor: mediaQuery.textScaleFactor,
      highContrastEnabled: mediaQuery.highContrast,
      reduceMotionEnabled: mediaQuery.platformBrightness == Brightness.dark && 
                          platformDispatcher.views.first.platformDispatcher.onBeginFrame == null,
      boldTextEnabled: mediaQuery.boldText,
      largeTextEnabled: mediaQuery.textScaleFactor > 1.0,
      showAnimations: !mediaQuery.disableAnimations,
    );
  }
} 