import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static String get currentUserId {
    final user = currentUser;

    if (user == null) {
      throw Exception('No existe una sesión activa.');
    }

    return user.id;
  }
}