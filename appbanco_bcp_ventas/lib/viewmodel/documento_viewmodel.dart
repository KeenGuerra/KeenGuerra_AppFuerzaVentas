import 'package:flutter/material.dart';

import '../model/documento_model.dart';
import '../services/documento_service.dart';

class DocumentoViewModel extends ChangeNotifier {
  final DocumentoService _documentoService = DocumentoService();

  bool loading = false;
  String? error;

  List<DocumentoModel> documentos = [];

  Future<void> subirDocumento({
    required String oficialId,
    required String clienteId,
    required String? solicitudId,
    required String tipoDocumento,
    required String filePath,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final documento = await _documentoService.subirDocumento(
        oficialId: oficialId,
        clienteId: clienteId,
        solicitudId: solicitudId,
        tipoDocumento: tipoDocumento,
        filePath: filePath,
      );

      documentos.insert(0, documento);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> cargarDocumentosCliente(String clienteId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      documentos = await _documentoService.obtenerDocumentosCliente(clienteId);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}