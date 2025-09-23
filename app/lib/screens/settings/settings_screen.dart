import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/localization_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../constants/strings.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';
  
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  // Theme Mode Selection
                  ListTile(
                    leading: const Icon(Icons.brightness_medium),
                    title: const Text('Theme Mode'),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeProvider.themeMode,
                      onChanged: (ThemeMode? newValue) {
                        if (newValue != null) {
                          themeProvider.setThemeMode(newValue);
                        }
                      },
                      items: ThemeMode.values.map((ThemeMode mode) {
                        return DropdownMenuItem<ThemeMode>(
                          value: mode,
                          child: Text(
                            mode.toString().split('.').last,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  // Language Selection
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('App Language'),
                    trailing: DropdownButton<Locale>(
                      value: LocalizationService.currentLocale,
                      onChanged: (Locale? newLocale) async {
                        if (newLocale != null) {
                          await localization.setLocale(newLocale);
                        }
                      },
                      items: LocalizationService.supportedLocalesList.map((locale) {
                        return DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(
                            _getLanguageName(locale.languageCode),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Version'),
                    subtitle: Text(Strings.version),
                  ),
                  Builder(
                    builder: (context) => ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      onTap: () => _navigateToPrivacyPolicy(context),
                    ),
                  ),
                  Builder(
                    builder: (context) => ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms of Service'),
                      onTap: () => _navigateToTermsOfService(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToPrivacyPolicy(BuildContext context) {
    // For now, show a snackbar. In a real app, you would navigate to a privacy policy screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Policy - Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToTermsOfService(BuildContext context) {
    // For now, show a snackbar. In a real app, you would navigate to a terms of service screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms of Service - Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return 'English';
    }
  }
}
