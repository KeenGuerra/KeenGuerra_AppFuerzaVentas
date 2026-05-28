class SupabaseConfig {
  static const String url = 'https://civsljmbakaltenfzcls.supabase.co';

  static const String anonKey =
      'sb_publishable_15pQ_B8Wj_9QCnA_J3rkkQ_XPjN5_lN';

  static void validate() {
    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'Faltan credenciales de Supabase',
      );
    }
  }
}