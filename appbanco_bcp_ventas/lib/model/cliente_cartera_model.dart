class ClienteCarteraModel {
  final String idCartera;
  final String idCliente;
  final String nombre;
  final String tipoGestion;
  final String estado;
  final String? direccion;
  final double? latitud;
  final double? longitud;
  final int prioridad;

  ClienteCarteraModel({
    required this.idCartera,
    required this.idCliente,
    required this.nombre,
    required this.tipoGestion,
    required this.estado,
    this.direccion,
    this.latitud,
    this.longitud,
    this.prioridad = 1,
  });
}