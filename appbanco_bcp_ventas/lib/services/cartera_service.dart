import '../model/cartera_model.dart';
import '../model/cliente_cartera_model.dart';
import '../model/ruta_visita_model.dart';
import 'supabase_service.dart';

class CarteraService {
  final _client = SupabaseService.client;

  Future<List<CarteraModel>> obtenerCarteraDiaria(String oficialId) async {
    final data = await _client
        .from('cartera_diaria')
        .select('''
          id,
          oficial_id,
          cliente_id,
          fecha,
          tipo_gestion,
          estado,
          prioridad,
          observacion,
          clientes (
            id,
            oficial_id,
            dni,
            nombres,
            apellidos,
            telefono,
            direccion,
            negocio,
            actividad_economica,
            latitud,
            longitud,
            estado
          )
        ''')
        .eq('oficial_id', oficialId)
        .order('prioridad', ascending: false);

    return data.map<CarteraModel>((item) {
      return CarteraModel.fromJson(item);
    }).toList();
  }

  Future<List<ClienteCarteraModel>> obtenerClientesAsignados(
    String oficialId,
  ) async {
    final cartera = await obtenerCarteraDiaria(oficialId);

    return cartera.map((item) {
      final cliente = item.cliente;

      return ClienteCarteraModel(
        idCartera: item.id,
        idCliente: item.clienteId,
        nombre: cliente?.nombreCompleto ?? 'Cliente sin nombre',
        tipoGestion: item.tipoGestion,
        estado: item.estado,
        direccion: cliente?.direccion,
        latitud: cliente?.latitud,
        longitud: cliente?.longitud,
        prioridad: item.prioridad,
      );
    }).toList();
  }

  Future<List<RutaVisitaModel>> obtenerRutaVisitas(String oficialId) async {
    final data = await _client
        .from('cartera_diaria')
        .select('''
          id,
          cliente_id,
          tipo_gestion,
          estado,
          clientes (
            nombres,
            apellidos,
            direccion,
            latitud,
            longitud
          )
        ''')
        .eq('oficial_id', oficialId)
        .not('clientes.latitud', 'is', null)
        .not('clientes.longitud', 'is', null);

    return data.map<RutaVisitaModel>((item) {
      return RutaVisitaModel.fromCarteraJson(item);
    }).toList();
  }

  Future<void> actualizarEstadoGestion({
    required String idCartera,
    required String nuevoEstado,
    String? observacion,
  }) async {
    await _client.from('cartera_diaria').update({
      'estado': nuevoEstado,
      'observacion': observacion,
    }).eq('id', idCartera);
  }
}