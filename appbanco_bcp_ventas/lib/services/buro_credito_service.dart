import '../model/buro_credito_model.dart';
import 'supabase_service.dart';

class BuroCreditoService {
  final _client = SupabaseService.client;

  Future<BuroCreditoModel> consultarBuroSimulado({
    required String clienteId,
    required String oficialId,
    required String dni,
  }) async {
    // Preparado para API externa futura.
    // Por ahora se guarda una respuesta simulada pero estructurada.
    final resultado = BuroCreditoModel(
      clienteId: clienteId,
      oficialId: oficialId,
      score: 720,
      resultado: 'APROBABLE',
      fuente: 'SIMULADO',
      payload: {
        'dni': dni,
        'riesgo': 'BAJO',
        'mensaje': 'Consulta preparada para integración con API externa.',
      },
    );

    final data = await _client
        .from('buro_credito')
        .insert(resultado.toJson())
        .select()
        .single();

    return BuroCreditoModel.fromJson(data);
  }

  Future<List<BuroCreditoModel>> obtenerConsultasCliente(String clienteId) async {
    final data = await _client
        .from('buro_credito')
        .select()
        .eq('cliente_id', clienteId)
        .order('created_at', ascending: false);

    return data.map<BuroCreditoModel>((item) {
      return BuroCreditoModel.fromJson(item);
    }).toList();
  }
}