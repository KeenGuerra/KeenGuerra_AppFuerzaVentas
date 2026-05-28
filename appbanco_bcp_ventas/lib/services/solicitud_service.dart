import '../model/solicitud_credito_model.dart';
import 'supabase_service.dart';

class SolicitudService {
  final _client = SupabaseService.client;

  Future<SolicitudCreditoModel> registrarSolicitud(
    SolicitudCreditoModel solicitud,
  ) async {
    final data = await _client
        .from('solicitudes_credito')
        .insert({
          ...solicitud.toJson(),

          // En este punto ya se sincronizó con Supabase.
          'sync_status': 'SINCRONIZADO',
        })
        .select()
        .single();

    return SolicitudCreditoModel.fromJson(data);
  }

  Future<List<SolicitudCreditoModel>> obtenerSolicitudesPorOficial(
    String oficialId,
  ) async {
    final data = await _client
        .from('solicitudes_credito')
        .select()
        .eq('oficial_id', oficialId)
        .order('created_at', ascending: false);

    return data.map<SolicitudCreditoModel>((item) {
      return SolicitudCreditoModel.fromJson(item);
    }).toList();
  }

  Future<void> actualizarEstadoSolicitud({
    required String solicitudId,
    required String estado,
  }) async {
    await _client.from('solicitudes_credito').update({
      'estado': estado,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', solicitudId);
  }
}