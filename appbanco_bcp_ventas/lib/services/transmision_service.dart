import 'supabase_service.dart';

class TransmisionService {
  final _client = SupabaseService.client;

  Future<void> registrarTransmision({
    required String oficialId,
    required String solicitudId,
    required String estado,
    String? mensaje,
  }) async {
    await _client.from('transmisiones').insert({
      'oficial_id': oficialId,
      'solicitud_id': solicitudId,
      'estado': estado,
      'mensaje': mensaje,
    });
  }

  Future<void> transmitirSolicitud(String solicitudId) async {
    await _client.from('solicitudes_credito').update({
      'sync_status': 'SINCRONIZADO',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', solicitudId);
  }

  Future<List<Map<String, dynamic>>> obtenerTransmisiones(
    String oficialId,
  ) async {
    final data = await _client
        .from('transmisiones')
        .select()
        .eq('oficial_id', oficialId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}