import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/shared_providers.dart';

class AppStateService {
  final ProviderContainer container;

  AppStateService(this.container);

  void initialize() {
    // Initialize theme
    container.read(themeProvider);
    
    // Initialize language
    container.read(languageProvider);
  }

  void dispose() {
    // Cleanup if needed
  }
}
