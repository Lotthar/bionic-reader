import 'package:bionic_reader/utils/navigation_routes.dart';
import 'package:flutter/material.dart';

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
      routes: Navigation.screensByRoutes(),
    );
  }
}
