import 'package:flutter/material.dart';

import '../model/buro_credito_model.dart';
import '../services/buro_credito_service.dart';

class BuroCreditoViewModel extends ChangeNotifier {
  final BuroCreditoService _buroService = BuroCreditoService();

  bool loading = false;
  String? error;

  BuroCreditoModel? ultimaConsulta;
  List<BuroCreditoModel> consultas = [];

  Future<void> consultarBuro({
    required String clienteId,
    required String oficialId,
    required String dni,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      ultimaConsulta = await _buroService.consultarBuroSimulado(
        clienteId: clienteId,
        oficialId: oficialId,
        dni: dni,
      );

      consultas.insert(0, ultimaConsulta!);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> cargarConsultas(String clienteId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      consultas = await _buroService.obtenerConsultasCliente(clienteId);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}