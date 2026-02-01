import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL']!;
  }

  static Future<void> initialize() async {
    if (kDebugMode) {
      await dotenv.load(fileName: '.env.debug');
    } else {
      await dotenv.load(fileName: '.env.release');
    }
  }
}
