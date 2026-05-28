import 'dart:io';

import '../model/documento_model.dart';
import 'supabase_service.dart';

class DocumentoService {
  final _client = SupabaseService.client;

  static const String bucketName = 'documentos-clientes';

  Future<DocumentoModel> subirDocumento({
    required String oficialId,
    required String clienteId,
    required String? solicitudId,
    required String tipoDocumento,
    required String filePath,
  }) async {
    final file = File(filePath);
    final fileName = file.path.split('/').last;

    final storagePath =
        '$oficialId/$clienteId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    // Sube el archivo al bucket de Supabase Storage.
    // El bucket debe existir previamente en Supabase.
    await _client.storage.from(bucketName).upload(storagePath, file);

    final publicUrl = _client.storage.from(bucketName).getPublicUrl(storagePath);

    final data = await _client.from('documentos').insert({
      'solicitud_id': solicitudId,
      'cliente_id': clienteId,
      'oficial_id': oficialId,
      'tipo_documento': tipoDocumento,
      'nombre_archivo': fileName,
      'storage_path': storagePath,
      'url_publica': publicUrl,
      'sync_status': 'SINCRONIZADO',
    }).select().single();

    return DocumentoModel.fromJson(data);
  }

  Future<List<DocumentoModel>> obtenerDocumentosCliente(String clienteId) async {
    final data = await _client
        .from('documentos')
        .select()
        .eq('cliente_id', clienteId)
        .order('created_at', ascending: false);

    return data.map<DocumentoModel>((item) {
      return DocumentoModel.fromJson(item);
    }).toList();
  }
}