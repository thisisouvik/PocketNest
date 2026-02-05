import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocketnest/config/environment_config.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvironmentConfig.supabaseUrl,
      anonKey: EnvironmentConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
