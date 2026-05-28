import '../model/cliente_model.dart';
import 'supabase_service.dart';

class ClienteService {
  final _client = SupabaseService.client;

  Future<ClienteModel> obtenerClientePorId(String clienteId) async {
    final data = await _client
        .from('clientes')
        .select()
        .eq('id', clienteId)
        .single();

    return ClienteModel.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> obtenerHistorialCrediticio(
    String clienteId,
  ) async {
    final data = await _client
        .from('historial_crediticio')
        .select()
        .eq('cliente_id', clienteId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> obtenerProductosActivos(
    String clienteId,
  ) async {
    final data = await _client
        .from('productos_activos')
        .select()
        .eq('cliente_id', clienteId)
        .eq('estado', 'ACTIVO');

    return List<Map<String, dynamic>>.from(data);
  }
}