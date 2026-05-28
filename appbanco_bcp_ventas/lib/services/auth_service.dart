import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/oficial_model.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  Future<OficialModel> login({
    required String codigoEmpleado,
    required String password,
  }) async {
    try {
      final emailLogin = _buildEmailFromCodigo(codigoEmpleado);

      final authResponse = await _client.auth.signInWithPassword(
        email: emailLogin,
        password: password,
      );

      final user = authResponse.user;

      if (user == null) {
        throw Exception('No se pudo iniciar sesión.');
      }

      final data = await _client
          .from('oficiales')
          .select()
          .eq('auth_user_id', user.id)
          .eq('estado', 'ACTIVO')
          .single();

      return OficialModel.fromJson(data);
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<OficialModel?> getCurrentOficial() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _client
        .from('oficiales')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return OficialModel.fromJson(data);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  bool get hasSession => _client.auth.currentSession != null;

  String _buildEmailFromCodigo(String codigoEmpleado) {
    final codigo = codigoEmpleado.trim().toLowerCase();

    // Se usa correo técnico para mantener login por código de empleado.
    // Ejemplo: OFI001 -> ofi001@fuerzaventas.local
    if (codigo.contains('@')) {
      return codigo;
    }

    return '$codigo@fuerzaventas.local';
  }

  String _mapAuthError(String message) {
    if (message.toLowerCase().contains('invalid login credentials')) {
      return 'Código o contraseña incorrectos.';
    }

    return message;
  }
}