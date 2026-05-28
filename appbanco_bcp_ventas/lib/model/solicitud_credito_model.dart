class SolicitudCreditoModel {
  final String? id;
  final String oficialId;
  final String clienteId;
  final double montoSolicitado;
  final int plazoMeses;
  final String destinoCredito;
  final String estado;
  final String syncStatus;

  SolicitudCreditoModel({
    this.id,
    required this.oficialId,
    required this.clienteId,
    required this.montoSolicitado,
    required this.plazoMeses,
    required this.destinoCredito,
    this.estado = 'REGISTRADA',
    this.syncStatus = 'PENDIENTE',
  });

  factory SolicitudCreditoModel.fromJson(Map<String, dynamic> json) {
    return SolicitudCreditoModel(
      id: json['id'],
      oficialId: json['oficial_id'],
      clienteId: json['cliente_id'],
      montoSolicitado: double.parse(json['monto_solicitado'].toString()),
      plazoMeses: json['plazo_meses'],
      destinoCredito: json['destino_credito'],
      estado: json['estado'],
      syncStatus: json['sync_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'oficial_id': oficialId,
      'cliente_id': clienteId,
      'monto_solicitado': montoSolicitado,
      'plazo_meses': plazoMeses,
      'destino_credito': destinoCredito,
      'estado': estado,
      'sync_status': syncStatus,
    };
  }
}