import 'package:flutter/material.dart';
import 'bionic_reader_screen.dart'; // We'll create this next

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bionic Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const BionicReaderHomeScreen(title: 'Bionic Reader'),
    );
  }
}
