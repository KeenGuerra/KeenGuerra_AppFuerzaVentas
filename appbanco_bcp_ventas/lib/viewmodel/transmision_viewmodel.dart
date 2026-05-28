import 'package:flutter/material.dart';

import '../services/transmision_service.dart';

class TransmisionViewModel extends ChangeNotifier {
  final TransmisionService _transmisionService = TransmisionService();

  bool loading = false;
  String? error;

  List<Map<String, dynamic>> transmisiones = [];

  Future<void> transmitirSolicitud({
    required String oficialId,
    required String solicitudId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await _transmisionService.transmitirSolicitud(solicitudId);

      await _transmisionService.registrarTransmision(
        oficialId: oficialId,
        solicitudId: solicitudId,
        estado: 'ENVIADO',
        mensaje: 'Solicitud transmitida correctamente a Supabase.',
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');

      await _transmisionService.registrarTransmision(
        oficialId: oficialId,
        solicitudId: solicitudId,
        estado: 'ERROR',
        mensaje: error,
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> cargarTransmisiones(String oficialId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      transmisiones = await _transmisionService.obtenerTransmisiones(
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