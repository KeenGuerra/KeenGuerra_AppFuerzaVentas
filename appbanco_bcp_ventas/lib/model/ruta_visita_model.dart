class RutaVisitaModel {
  final String idCartera;
  final String clienteId;
  final String nombreCliente;
  final String direccion;
  final double latitud;
  final double longitud;
  final String estado;
  final String tipoGestion;

  RutaVisitaModel({
    required this.idCartera,
    required this.clienteId,
    required this.nombreCliente,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.estado,
    required this.tipoGestion,
  });

  factory RutaVisitaModel.fromCarteraJson(Map<String, dynamic> json) {
    final cliente = json['clientes'];

    return RutaVisitaModel(
      idCartera: json['id'],
      clienteId: json['cliente_id'],
      nombreCliente: '${cliente['nombres']} ${cliente['apellidos']}',
      direccion: cliente['direccion'] ?? 'Sin dirección registrada',
      latitud: double.parse(cliente['latitud'].toString()),
      longitud: double.parse(cliente['longitud'].toString()),
      estado: json['estado'],
      tipoGestion: json['tipo_gestion'],
    );
  }
}