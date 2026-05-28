import 'package:flutter/material.dart';

import '../model/cliente_cartera_model.dart';
import '../model/oficial_model.dart';
import '../services/cartera_service.dart';

class CarteraViewModel extends ChangeNotifier {
  final CarteraService _carteraService = CarteraService();

  bool loading = false;
  String? error;

  OficialModel? oficial;

  final List<ClienteCarteraModel> clientes = [];

  String get nombreOficial {
    if (oficial == null) {
      return 'Oficial';
    }

    return oficial!.nombres;
  }

  int get totalVisitas => clientes.length;

  int get pendientes {
    return clientes.where((cliente) => cliente.estado == 'Pendiente').length;
  }

  int get visitados {
    return clientes.where((cliente) => cliente.estado == 'Visitado').length;
  }

  Future<void> cargarCartera(OficialModel oficialActual) async {
    loading = true;
    error = null;
    oficial = oficialActual;
    clientes.clear();
    notifyListeners();

    try {
      final data = await _carteraService.obtenerClientesAsignados(
        oficialActual.id,
      );

      clientes.addAll(data);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> actualizarEstadoGestion({
    required String idCartera,
    required String nuevoEstado,
    String? observacion,
  }) async {
    try {
      await _carteraService.actualizarEstadoGestion(
        idCartera: idCartera,
        nuevoEstado: nuevoEstado,
        observacion: observacion,
      );

      final index = clientes.indexWhere(
        (cliente) => cliente.idCartera == idCartera,
      );

      if (index != -1) {
        final actual = clientes[index];

        clientes[index] = ClienteCarteraModel(
          idCartera: actual.idCartera,
          idCliente: actual.idCliente,
          nombre: actual.nombre,
          tipoGestion: actual.tipoGestion,
          estado: nuevoEstado,
          direccion: actual.direccion,
          latitud: actual.latitud,
          longitud: actual.longitud,
        );

        notifyListeners();
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void limpiar() {
    clientes.clear();
    oficial = null;
    error = null;
    loading = false;
    notifyListeners();
  }
}