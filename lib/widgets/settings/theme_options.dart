
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../notifiers/theme_notifier.dart';

class ThemeOptions {
  /// Builds the section for theme selection.
  static Widget buildThemeOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Theme Options',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
}