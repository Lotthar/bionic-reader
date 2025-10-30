import 'package:bionic_reader/services/background_conversion_service.dart';
import 'package:bionic_reader/services/book_cache_service.dart';
import 'package:bionic_reader/services/database/book_database_service.dart';
import 'package:bionic_reader/services/cover_image_service.dart';
import 'package:bionic_reader/services/database/database_provider.dart';
import 'package:bionic_reader/services/settings_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Core Services
  locator.registerSingleton<DatabaseProvider>(DatabaseProvider());
  locator.registerSingleton<BookDatabaseService>(BookDatabaseService(locator()));

  // App-specific Services
  locator.registerSingleton<BookCacheService>(BookCacheService());
  locator.registerSingleton<BackgroundConversionService>(
      BackgroundConversionService());
  locator.registerLazySingleton(() => CoverImageService());
  locator.registerLazySingleton(() => SettingsService());
}
