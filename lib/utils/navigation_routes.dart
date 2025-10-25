
import 'package:flutter/material.dart';
import '../screens/reader_screen.dart';
import '../screens/settings_screen.dart';

enum Routes {

  home(path: "/", name: Text("Home"), icon: Icon(Icons.home)),
  settings(path: "/settings", name: Text("Settings"), icon: Icon(Icons.settings));

  const Routes({
    required this.path,
    required this.name,
    required this.icon
  });

  final String path;
  final Text name;
  final Icon icon;

}

class Navigation {

  static Map<String, WidgetBuilder> screensByRoutes() {
    return {
        Routes.home.path: (context) => const ReaderScreen(),
        Routes.settings.path: (context) => const SettingsScreen(),
    };
  }

  static List<Widget> listTilesFromRoutes(BuildContext context) {
      return Routes.values.map((route) {
        return ListTile(
          leading: route.icon,
          title: route.name,
          onTap: () {
            Navigator.pushReplacementNamed(context, route.path);
          });
      }).toList();
  }

}