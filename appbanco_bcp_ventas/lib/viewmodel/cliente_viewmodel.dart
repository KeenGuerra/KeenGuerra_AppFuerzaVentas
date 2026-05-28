import 'package:flutter/material.dart';

import '../model/cliente_model.dart';
import '../services/cliente_service.dart';

class ClienteViewModel extends ChangeNotifier {
  final ClienteService _clienteService = ClienteService();

  bool loading = false;
  String? error;

  ClienteModel? cliente;
  List<Map<String, dynamic>> historialCrediticio = [];
  List<Map<String, dynamic>> productosActivos = [];

  Future<void> cargarFichaCliente(String clienteId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      cliente = await _clienteService.obtenerClientePorId(clienteId);

      historialCrediticio = await _clienteService.obtenerHistorialCrediticio(
        clienteId,
      );

      productosActivos = await _clienteService.obtenerProductosActivos(
        clienteId,
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}