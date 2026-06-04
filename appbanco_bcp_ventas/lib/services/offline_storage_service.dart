import '../model/solicitud_credito_model.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance = OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  final List<SolicitudCreditoModel> _drafts = [];
  final List<Map<String, dynamic>> _offlineVisits = [];

  // Guardar solicitud como borrador offline
  Future<void> guardarBorrador(SolicitudCreditoModel solicitud) async {
    // Añadimos a la lista en memoria
    final idBorrador = 'draft_${DateTime.now().millisecondsSinceEpoch}';
    final borrador = SolicitudCreditoModel(
      id: idBorrador,
      oficialId: solicitud.oficialId,
      clienteId: solicitud.clienteId,
      montoSolicitado: solicitud.montoSolicitado,
      plazoMeses: solicitud.plazoMeses,
      destinoCredito: solicitud.destinoCredito,
      estado: 'BORRADOR',
      syncStatus: 'PENDIENTE',
    );
    _drafts.add(borrador);
  }

  // Obtener todos los borradores
  Future<List<SolicitudCreditoModel>> obtenerBorradores() async {
    return List.unmodifiable(_drafts);
  }

  // Eliminar un borrador (usualmente después de sincronizarlo)
  Future<void> eliminarBorrador(String draftId) async {
    _drafts.removeWhere((item) => item.id == draftId);
  }

  // Guardar visita offline
  Future<void> registrarVisitaOffline({
    required String idCartera,
    required String nuevoEstado,
    required String observacion,
    required double latitud,
    required double longitud,
  }) async {
    _offlineVisits.removeWhere((v) => v['id_cartera'] == idCartera);
    _offlineVisits.add({
      'id_cartera': idCartera,
      'nuevo_estado': nuevoEstado,
      'observacion': observacion,
      'latitud': latitud,
      'longitud': longitud,
      'fecha_registro': DateTime.now().toIso8601String(),
    });
  }

  // Obtener visitas offline pendientes
  Future<List<Map<String, dynamic>>> obtenerVisitasPendientes() async {
    return List.unmodifiable(_offlineVisits);
  }

  // Eliminar visita offline
  Future<void> eliminarVisitaOffline(String idCartera) async {
    _offlineVisits.removeWhere((item) => item['id_cartera'] == idCartera);
  }

  // Limpiar todo
  void limpiar() {
    _drafts.clear();
    _offlineVisits.clear();
  }
}
