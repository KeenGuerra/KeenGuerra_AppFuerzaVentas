class BuroCreditoModel {
  final String? id;
  final String clienteId;
  final String oficialId;
  final int? score;
  final String resultado;
  final String fuente;
  final Map<String, dynamic>? payload;

  BuroCreditoModel({
    this.id,
    required this.clienteId,
    required this.oficialId,
    this.score,
    required this.resultado,
    this.fuente = 'SIMULADO',
    this.payload,
  });

  factory BuroCreditoModel.fromJson(Map<String, dynamic> json) {
    return BuroCreditoModel(
      id: json['id'],
      clienteId: json['cliente_id'],
      oficialId: json['oficial_id'],
      score: json['score'],
      resultado: json['resultado'],
      fuente: json['fuente'],
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': clienteId,
      'oficial_id': oficialId,
      'score': score,
      'resultado': resultado,
      'fuente': fuente,
      'payload': payload,
    };
  }
}