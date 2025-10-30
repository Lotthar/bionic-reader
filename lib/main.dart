import 'package:bionic_reader/bloc/library_cubit.dart';
import 'package:bionic_reader/notifiers/theme_notifier.dart';
import 'package:bionic_reader/service_locator.dart';
import 'package:bionic_reader/services/database/database_provider.dart';
import 'package:bionic_reader/services/database/database_schema.dart';
import 'package:bionic_reader/theme/app_theme.dart';
import 'package:bionic_reader/utils/navigation_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await locator<DatabaseProvider>().init(
    dbName: 'bionic_reader.db',
    tableCreationSqls: allTables,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(locator()),
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
        return BlocProvider(
          create: (context) => LibraryCubit(locator(), locator(), locator()),
          child: MaterialApp(
            title: 'Bionic Reader',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(notifier.seedColor),
            darkTheme: AppTheme.dark(notifier.seedColor),
            themeMode: notifier.themeMode,
            initialRoute: Routes.library.path,
            routes: Navigation.screensByRoutes(),
          ),
        );
      },
    );
  }
}
