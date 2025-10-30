import 'package:bionic_reader/widgets/custom_app_bar.dart';
import 'package:bionic_reader/widgets/custom_drawer.dart';
import 'package:bionic_reader/widgets/settings/color_scheme_options.dart';
import 'package:bionic_reader/widgets/settings/theme_options.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Settings'),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemeOptions.buildThemeOptions(context),
              const SizedBox(height: 20),
              ColorSchemeOptions.buildColorSchemeOptions(context),
            ],
          ),
        ),
      ),
    );
  }

}
