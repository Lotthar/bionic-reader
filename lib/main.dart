import 'package:bionic_reader/notifiers/theme_notifier.dart';
import 'package:bionic_reader/utils/navigation_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const BionicReaderApp(),
    ),
  );
}

class BionicReaderApp extends StatelessWidget {
  const BionicReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, child) {
        return MaterialApp(
          title: 'Bionic Reader',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: notifier.seedColor),
            useMaterial3: true,
            fontFamily: 'Inter',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: notifier.seedColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            fontFamily: 'Inter',
          ),
          themeMode: notifier.themeMode,
          initialRoute: Routes.home.path,
          routes: Navigation.screensByRoutes()
        );
      },
    );
  }
}
