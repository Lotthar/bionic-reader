import 'package:bionic_reader/services/background_conversion_service.dart';
import 'package:bionic_reader/services/book_cache_service.dart';
import 'package:bionic_reader/services/cover_image_service.dart';
import 'package:bionic_reader/services/database_service.dart';
import 'package:bionic_reader/services/settings_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<DatabaseService>(DatabaseService());
  locator.registerSingleton<BookCacheService>(BookCacheService());
  locator.registerSingleton<BackgroundConversionService>(
      BackgroundConversionService());
  locator.registerLazySingleton(() => CoverImageService());
  locator.registerLazySingleton(() => SettingsService());
}
