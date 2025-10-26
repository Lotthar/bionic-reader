import 'package:bionic_reader/notifiers/theme_notifier.dart';
import 'package:bionic_reader/widgets/custom_app_bar.dart';
import 'package:bionic_reader/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildThemeOptions(context),
              const SizedBox(height: 20),
              _buildColorSchemeOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the section for theme selection.
  Widget _buildThemeOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Theme Options',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Consumer<ThemeNotifier>(
          builder: (context, notifier, child) {
            return RadioGroup<ThemeMode>(
              groupValue: notifier.themeMode,
              onChanged: (value) {
                if (value != null) {
                  notifier.themeMode = value;
                }
              },
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text('System Default'),
                    value: ThemeMode.system,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Light'),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Dark'),
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Builds the section for color scheme selection.
  Widget _buildColorSchemeOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Color Scheme',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Consumer<ThemeNotifier>(
          builder: (context, notifier, child) {
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: notifier.availableColors.map((color) {
                return GestureDetector(
                  onTap: () => notifier.seedColor = color,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: notifier.seedColor == color
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
