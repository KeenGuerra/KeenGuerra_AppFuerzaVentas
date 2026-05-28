class OficialModel {
  final String id;
  final String authUserId;
  final String codigoEmpleado;
  final String nombres;
  final String apellidos;
  final String? agencia;
  final String? cargo;
  final String estado;

  OficialModel({
    required this.id,
    required this.authUserId,
    required this.codigoEmpleado,
    required this.nombres,
    required this.apellidos,
    this.agencia,
    this.cargo,
    required this.estado,
  });

  String get nombreCompleto => '$nombres $apellidos';

  factory OficialModel.fromJson(Map<String, dynamic> json) {
    return OficialModel(
      id: json['id'],
      authUserId: json['auth_user_id'],
      codigoEmpleado: json['codigo_empleado'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      agencia: json['agencia'],
      cargo: json['cargo'],
      estado: json['estado'],
    );
  }
}