import '../model/buro_credito_model.dart';
import 'supabase_service.dart';

class BuroCreditoService {
  final _client = SupabaseService.client;

  Future<BuroCreditoModel> consultarBuroSimulado({
    required String clienteId,
    required String oficialId,
    required String dni,
  }) async {
    final String ultimoDigito = dni.isNotEmpty ? dni.substring(dni.length - 1) : '0';
    
    int score = 740;
    String resultado = 'APTO';
    String riesgo = 'BAJO';
    String clasificacion = '100% Normal (CPP 0%)';
    double deudasSbs = 4500.00;
    int entidades = 1;
    int mayorMora = 0;
    bool inhabilitado = false;

    switch (ultimoDigito) {
      case '0':
        score = 740;
        resultado = 'APTO';
        riesgo = 'BAJO';
        clasificacion = '100% Normal (CPP 0%)';
        deudasSbs = 4500.00;
        entidades = 1;
        mayorMora = 0;
        inhabilitado = false;
        break;
      case '1':
        score = 740;
        resultado = 'APTO';
        riesgo = 'BAJO';
        clasificacion = '100% Normal (CPP 0%)';
        deudasSbs = 12000.00;
        entidades = 2;
        mayorMora = 0;
        inhabilitado = false;
        break;
      case '2':
        score = 650;
        resultado = 'CON CONDICIONES';
        riesgo = 'MEDIO';
        clasificacion = 'Con Problemas Potenciales (CPP)';
        deudasSbs = 18000.00;
        entidades = 2;
        mayorMora = 15;
        inhabilitado = false;
        break;
      case '3':
        score = 800;
        resultado = 'APTO';
        riesgo = 'BAJO';
        clasificacion = '100% Normal (CPP 0%)';
        deudasSbs = 0.00;
        entidades = 0;
        mayorMora = 0;
        inhabilitado = false;
        break;
      case '4':
        score = 420;
        resultado = 'RECHAZADO';
        riesgo = 'ALTO';
        clasificacion = 'Dudoso';
        deudasSbs = 25000.00;
        entidades = 3;
        mayorMora = 95;
        inhabilitado = false;
        break;
      case '5':
        score = 550;
        resultado = 'APTO con observaciones';
        riesgo = 'MEDIO';
        clasificacion = 'Deficiente';
        deudasSbs = 16000.00;
        entidades = 2;
        mayorMora = 45;
        inhabilitado = false;
        break;
      case '6':
        score = 740;
        resultado = 'APTO';
        riesgo = 'BAJO';
        clasificacion = '100% Normal (CPP 0%)';
        deudasSbs = 6000.00;
        entidades = 1;
        mayorMora = 0;
        inhabilitado = false;
        break;
      case '7':
        score = 300;
        resultado = 'RECHAZADO';
        riesgo = 'ALTO';
        clasificacion = 'Pérdida';
        deudasSbs = 40000.00;
        entidades = 4;
        mayorMora = 210;
        inhabilitado = true;
        break;
      case '8':
        score = 680;
        resultado = 'CON CONDICIONES';
        riesgo = 'MEDIO';
        clasificacion = 'Con Problemas Potenciales (CPP)';
        deudasSbs = 9000.00;
        entidades = 1;
        mayorMora = 20;
        inhabilitado = false;
        break;
      case '9':
        score = 740;
        resultado = 'APTO';
        riesgo = 'BAJO';
        clasificacion = '100% Normal (CPP 0%)';
        deudasSbs = 14000.00;
        entidades = 2;
        mayorMora = 0;
        inhabilitado = false;
        break;
    }

    final resultadoBuro = BuroCreditoModel(
      clienteId: clienteId,
      oficialId: oficialId,
      score: score,
      resultado: resultado,
      fuente: 'SIMULADO',
      payload: {
        'dni': dni,
        'riesgo': riesgo,
        'clasificacion': clasificacion,
        'deudas_sbs': deudasSbs,
        'entidades': entidades,
        'mayor_mora': mayorMora,
        'inhabilitado': inhabilitado,
      },
    );

    // Guardar en base de datos Supabase
    final data = await _client
        .from('buro_credito')
        .insert(resultadoBuro.toJson())
        .select()
        .single();

    // Si es inhabilitado, se bloquea la solicitud y se actualiza a rechazado en Supabase
    if (inhabilitado) {
      await _client
          .from('solicitudes_credito')
          .update({
            'estado': 'rechazado',
            'motivo_rechazo': 'Bloqueado en Buró: Cliente en lista de inhabilitados del sistema financiero (DNI terminado en 7).',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('cliente_id', clienteId)
          .eq('estado', 'enviado');
    }

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