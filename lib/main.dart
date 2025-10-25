import 'package:bionic_reader/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:bionic_reader/screens/home_screen.dart'; // Import the main screen

void main() {
  runApp(const BionicReaderApp());
}

class BionicReaderApp extends StatelessWidget {
  const BionicReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bionic Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber.shade300),
        useMaterial3: true,
        // Apply Inter font across the app (requires font configuration in pubspec)
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const BionicReaderHomeScreen(title: 'Bionic Reader'),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
