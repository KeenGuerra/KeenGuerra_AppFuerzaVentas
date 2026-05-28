import 'package:flutter/material.dart';

import '../model/oficial_model.dart';
import '../services/auth_service.dart';

class AuthOficialViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool loading = false;
  bool success = false;
  String? error;
  OficialModel? oficial;

  Future<void> login(String codigoEmpleado, String password) async {
    loading = true;
    success = false;
    error = null;
    notifyListeners();

    try {
      oficial = await _authService.login(
        codigoEmpleado: codigoEmpleado,
        password: password,
      );

      success = true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      success = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> cargarSesionActual() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      oficial = await _authService.getCurrentOficial();
      success = oficial != null;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();

    oficial = null;
    success = false;
    error = null;

    notifyListeners();
  }
}