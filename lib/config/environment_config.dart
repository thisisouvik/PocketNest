import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static String get googleWebClientId {
    return dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  }

  static bool isProduction() {
    return dotenv.env['ENVIRONMENT'] == 'production';
  }
}
