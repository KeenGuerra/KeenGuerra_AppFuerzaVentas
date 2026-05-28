import 'cliente_model.dart';

class CarteraModel {
  final String id;
  final String oficialId;
  final String clienteId;
  final DateTime fecha;
  final String tipoGestion;
  final String estado;
  final int prioridad;
  final String? observacion;
  final ClienteModel? cliente;

  CarteraModel({
    required this.id,
    required this.oficialId,
    required this.clienteId,
    required this.fecha,
    required this.tipoGestion,
    required this.estado,
    required this.prioridad,
    this.observacion,
    this.cliente,
  });

  factory CarteraModel.fromJson(Map<String, dynamic> json) {
    return CarteraModel(
      id: json['id'].toString(),
      oficialId: json['oficial_id'].toString(),
      clienteId: json['cliente_id'].toString(),
      fecha: DateTime.parse(json['fecha'].toString()),
      tipoGestion: json['tipo_gestion']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'Pendiente',
      prioridad: json['prioridad'] ?? 1,
      observacion: json['observacion']?.toString(),
      cliente: json['clientes'] == null
          ? null
          : ClienteModel.fromJson(
              Map<String, dynamic>.from(json['clientes']),
            ),
    );
  }
}