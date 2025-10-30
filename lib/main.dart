import 'package:bionic_reader/bloc/library_cubit.dart';
import 'package:bionic_reader/notifiers/theme_notifier.dart';
import 'package:bionic_reader/service_locator.dart';
import 'package:bionic_reader/services/database/database_provider.dart';
import 'package:bionic_reader/services/database/database_schema.dart';
import 'package:bionic_reader/theme/app_text_styles.dart';
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
                theme: ThemeData(
                  brightness: Brightness.light,
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: notifier.seedColor),
                  useMaterial3: true,
                  fontFamily: 'Inter',
                  extensions: const <ThemeExtension<dynamic>>[
                    AppTextStyles(
                      body: TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                        color: Colors.black,
                      ),
                      bodyBold: TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                      caption: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: notifier.seedColor,
                    brightness: Brightness.dark,
                  ),
                  useMaterial3: true,
                  fontFamily: 'Inter',
                  extensions: <ThemeExtension<dynamic>>[
                    AppTextStyles(
                      body: const TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                        color: Colors.white,
                      ),
                      bodyBold: TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                        color: notifier.seedColor, // Use seed color for highlights
                        fontWeight: FontWeight.w900,
                      ),
                      caption: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                themeMode: notifier.themeMode,
                initialRoute: Routes.library.path,
                routes: Navigation.screensByRoutes()));
      },
    );
  }
}
