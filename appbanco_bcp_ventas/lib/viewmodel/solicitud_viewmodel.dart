import 'package:flutter/material.dart';

import '../model/solicitud_credito_model.dart';
import '../services/solicitud_service.dart';

class SolicitudViewModel extends ChangeNotifier {
  final SolicitudService _solicitudService = SolicitudService();

  bool loading = false;
  String? error;
  SolicitudCreditoModel? solicitudRegistrada;

  List<SolicitudCreditoModel> solicitudes = [];

  Future<void> registrarSolicitud(SolicitudCreditoModel solicitud) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      solicitudRegistrada = await _solicitudService.registrarSolicitud(
        solicitud,
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> cargarSolicitudes(String oficialId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      solicitudes = await _solicitudService.obtenerSolicitudesPorOficial(
        oficialId,
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}