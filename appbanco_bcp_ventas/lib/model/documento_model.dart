class DocumentoModel {
  final String? id;
  final String? solicitudId;
  final String clienteId;
  final String oficialId;
  final String tipoDocumento;
  final String nombreArchivo;
  final String storagePath;
  final String? urlPublica;
  final String syncStatus;

  DocumentoModel({
    this.id,
    this.solicitudId,
    required this.clienteId,
    required this.oficialId,
    required this.tipoDocumento,
    required this.nombreArchivo,
    required this.storagePath,
    this.urlPublica,
    this.syncStatus = 'PENDIENTE',
  });

  factory DocumentoModel.fromJson(Map<String, dynamic> json) {
    return DocumentoModel(
      id: json['id'],
      solicitudId: json['solicitud_id'],
      clienteId: json['cliente_id'],
      oficialId: json['oficial_id'],
      tipoDocumento: json['tipo_documento'],
      nombreArchivo: json['nombre_archivo'],
      storagePath: json['storage_path'],
      urlPublica: json['url_publica'],
      syncStatus: json['sync_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'solicitud_id': solicitudId,
      'cliente_id': clienteId,
      'oficial_id': oficialId,
      'tipo_documento': tipoDocumento,
      'nombre_archivo': nombreArchivo,
      'storage_path': storagePath,
      'url_publica': urlPublica,
      'sync_status': syncStatus,
    };
  }
}