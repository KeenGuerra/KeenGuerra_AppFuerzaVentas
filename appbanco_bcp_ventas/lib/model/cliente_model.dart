class ClienteModel {
  final String id;
  final String oficialId;
  final String dni;
  final String nombres;
  final String apellidos;
  final String? telefono;
  final String? direccion;
  final String? negocio;
  final String? actividadEconomica;
  final double? latitud;
  final double? longitud;
  final String estado;

  ClienteModel({
    required this.id,
    required this.oficialId,
    required this.dni,
    required this.nombres,
    required this.apellidos,
    this.telefono,
    this.direccion,
    this.negocio,
    this.actividadEconomica,
    this.latitud,
    this.longitud,
    required this.estado,
  });

  String get nombreCompleto => '$nombres $apellidos';

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'].toString(),
      oficialId: json['oficial_id'].toString(),
      dni: json['dni'].toString(),
      nombres: json['nombres'].toString(),
      apellidos: json['apellidos'].toString(),
      telefono: json['telefono']?.toString(),
      direccion: json['direccion']?.toString(),
      negocio: json['negocio']?.toString(),
      actividadEconomica: json['actividad_economica']?.toString(),
      latitud: json['latitud'] == null
          ? null
          : double.tryParse(json['latitud'].toString()),
      longitud: json['longitud'] == null
          ? null
          : double.tryParse(json['longitud'].toString()),
      estado: json['estado']?.toString() ?? 'ACTIVO',
    );
  }
}