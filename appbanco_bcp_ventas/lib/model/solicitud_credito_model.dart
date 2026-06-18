class SolicitudCreditoModel {
  final String? id;
  final String oficialId;
  final String clienteId;
  final double montoSolicitado;
  final int plazoMeses;
  final String destinoCredito;
  final String estado;
  final String syncStatus;
  final double tea;
  final String garantia;
  final bool seguroDesgravamen;
  final double? montoAprobado;
  final String? motivoRechazo;
  final String? createdAt;
  final String? updatedAt;

  SolicitudCreditoModel({
    this.id,
    required this.oficialId,
    required this.clienteId,
    required this.montoSolicitado,
    required this.plazoMeses,
    required this.destinoCredito,
    this.estado = 'enviado',
    this.syncStatus = 'PENDIENTE',
    this.tea = 40.92,
    this.garantia = 'sin garantia',
    this.seguroDesgravamen = false,
    this.montoAprobado,
    this.motivoRechazo,
    this.createdAt,
    this.updatedAt,
  });

  factory SolicitudCreditoModel.fromJson(Map<String, dynamic> json) {
    return SolicitudCreditoModel(
      id: json['id'],
      oficialId: json['oficial_id'] ?? '',
      clienteId: json['cliente_id'] ?? '',
      montoSolicitado: double.parse((json['monto_solicitado'] ?? 0).toString()),
      plazoMeses: json['plazo_meses'] ?? 12,
      destinoCredito: json['destino_credito'] ?? '',
      estado: json['estado'] ?? 'enviado',
      syncStatus: json['sync_status'] ?? 'SINCRONIZADO',
      tea: double.parse((json['tea'] ?? 40.92).toString()),
      garantia: json['garantia'] ?? 'sin garantia',
      seguroDesgravamen: json['seguro_desgravamen'] == true,
      montoAprobado: json['monto_aprobado'] != null ? double.parse(json['monto_aprobado'].toString()) : null,
      motivoRechazo: json['motivo_rechazo'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
      'tea': tea,
      'garantia': garantia,
      'seguro_desgravamen': seguroDesgravamen,
      if (montoAprobado != null) 'monto_aprobado': montoAprobado,
      if (motivoRechazo != null) 'motivo_rechazo': motivoRechazo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}