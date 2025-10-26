
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../notifiers/theme_notifier.dart';

class ColorSchemeOptions {

  static Widget buildColorSchemeOptions(BuildContext context) {
    final notifier = Provider.of<ThemeNotifier>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Color Scheme',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        ListTile(
          title: const Text('Seed Color'),
          trailing: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notifier.seedColor,
              shape: BoxShape.circle,
            ),
          ),
          onTap: () => _showColorPicker(context, notifier),
        ),
      ],
    );
  }

  /// Shows the color picker dialog.
  static void _showColorPicker(BuildContext context, ThemeNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: notifier.seedColor,
              onColorChanged: (color) => notifier.seedColor = color,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}