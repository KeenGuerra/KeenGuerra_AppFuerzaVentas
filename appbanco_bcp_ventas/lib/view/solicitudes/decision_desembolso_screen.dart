import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/cliente_cartera_model.dart';
import '../../ui/theme/app_theme.dart';

class DecisionDesembolsoScreen extends StatefulWidget {
  const DecisionDesembolsoScreen({super.key});

  @override
  State<DecisionDesembolsoScreen> createState() => _DecisionDesembolsoScreenState();
}

class _DecisionDesembolsoScreenState extends State<DecisionDesembolsoScreen> {
  final supabase = Supabase.instance.client;
  ClienteCarteraModel? cliente;

  bool _loading = false;
  Map<String, dynamic>? _solicitud;
  String? _error;

  // Variables de decisión
  String _decisionComite = 'APROBADO'; // APROBADO, CONDICIONADO, RECHAZADO
  final _montoAprobadoController = TextEditingController();
  final _motivoRechazoController = TextEditingController();

  // Variables de desembolso
  int _diaPago = 3;
  DateTime _fechaDesembolso = DateTime.now();

  // Fórmulas francesas calculadas
  double cuotaCalculada = 0.0;
  List<Map<String, dynamic>> cronogramaPagos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ClienteCarteraModel && cliente == null) {
      cliente = args;
      _buscarSolicitudActiva();
    }
  }

  @override
  void dispose() {
    _montoAprobadoController.dispose();
    _motivoRechazoController.dispose();
    super.dispose();
  }

  Future<void> _buscarSolicitudActiva() async {
    if (cliente == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await supabase
          .from('solicitudes_credito')
          .select()
          .eq('cliente_id', cliente!.idCliente)
          .order('created_at', ascending: false);

      if (list.isNotEmpty) {
        setState(() {
          _solicitud = list.first;
          _montoAprobadoController.text = _solicitud!['monto_solicitado'].toString();
        });
        _recalcularAmortizacion();
      } else {
        setState(() {
          _error = 'No se encontró ninguna solicitud de crédito para este cliente.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al consultar: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _recalcularAmortizacion() {
    if (_solicitud == null) return;

    double P = double.tryParse(_montoAprobadoController.text) ?? 0.0;
    if (_decisionComite == 'APROBADO') {
      P = double.parse(_solicitud!['monto_solicitado'].toString());
    }

    final int n = _solicitud!['plazo_meses'];
    final double tea = double.parse(_solicitud!['tea'].toString());

    if (P <= 0 || n <= 0) {
      setState(() {
        cuotaCalculada = 0.0;
        cronogramaPagos = [];
      });
      return;
    }

    final double TEM = pow(1 + (tea / 100), 1 / 12) - 1;
    final double factor = pow(1 + TEM, n).toDouble();
    final double cuota = P * (TEM * factor) / (factor - 1);

    // Generar cronograma de pagos
    List<Map<String, dynamic>> schedule = [];
    double saldoRestante = P;
    DateTime tempFecha = _fechaDesembolso;

    for (int i = 1; i <= n; i++) {
      // Avanzar al mes siguiente con el día de pago seleccionado
      int proxMes = tempFecha.month + 1;
      int proxAnio = tempFecha.year;
      if (proxMes > 12) {
        proxMes = 1;
        proxAnio++;
      }
      // Asegurar que el día sea válido
      int maxDias = DateTime(proxAnio, proxMes + 1, 0).day;
      int diaElegido = _diaPago > maxDias ? maxDias : _diaPago;
      tempFecha = DateTime(proxAnio, proxMes, diaElegido);

      final double interes = saldoRestante * TEM;
      final double capital = cuota - interes;
      saldoRestante = saldoRestante - capital;

      if (i == n) {
        // Ajuste decimal en la última cuota para cuadrar a 0.00
        schedule.add({
          'n': i,
          'fecha': '${tempFecha.day.toString().padLeft(2, '0')}/${tempFecha.month.toString().padLeft(2, '0')}/${tempFecha.year}',
          'cuota': cuota,
          'capital': capital + saldoRestante,
          'interes': interes,
          'saldo': 0.00,
        });
      } else {
        schedule.add({
          'n': i,
          'fecha': '${tempFecha.day.toString().padLeft(2, '0')}/${tempFecha.month.toString().padLeft(2, '0')}/${tempFecha.year}',
          'cuota': cuota,
          'capital': capital,
          'interes': interes,
          'saldo': saldoRestante,
        });
      }
    }

    setState(() {
      cuotaCalculada = cuota;
      cronogramaPagos = schedule;
    });
  }

  // Avanzar estado recibido_comite -> en_evaluacion
  Future<void> _actualizarEstado(String nuevoEstado) async {
    if (_solicitud == null) return;
    setState(() {
      _loading = true;
    });

    try {
      await supabase
          .from('solicitudes_credito')
          .update({
            'estado': nuevoEstado,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _solicitud!['id']);

      await _buscarSolicitudActiva();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.neonRed),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Registrar decisión del comité (Aprobado/Condicionado/Rechazado)
  Future<void> _registrarDecision() async {
    if (_solicitud == null) return;
    setState(() {
      _loading = true;
    });

    try {
      final String nuevoEstado = _decisionComite.toLowerCase();
      final double P_aprobado = _decisionComite == 'RECHAZADO'
          ? 0.0
          : (double.tryParse(_montoAprobadoController.text) ?? _solicitud!['monto_solicitado']);

      await supabase
          .from('solicitudes_credito')
          .update({
            'estado': nuevoEstado,
            'monto_aprobado': P_aprobado, // actualiza monto aprobado
            'motivo_rechazo': _decisionComite == 'RECHAZADO' ? _motivoRechazoController.text.trim() : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _solicitud!['id']);

      // Si es rechazado, cerrar también en cartera
      if (nuevoEstado == 'rechazado') {
        await supabase
            .from('cartera_diaria')
            .update({'estado': 'Reprogramado', 'observacion': 'Rechazado en comité.'})
            .eq('cliente_id', cliente!.idCliente)
            .eq('tipo_gestion', 'NUEVA_SOLICITUD');
      }

      await _buscarSolicitudActiva();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.neonRed),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Desembolsar y registrar el cronograma final
  Future<void> _desembolsarCredito() async {
    if (_solicitud == null) return;
    setState(() {
      _loading = true;
    });

    try {
      // 1. Cambiar estado de solicitud a desembolsado
      await supabase
          .from('solicitudes_credito')
          .update({
            'estado': 'desembolsado',
            'monto_aprobado': _decisionComite == 'CONDICIONADO' 
                ? (double.tryParse(_montoAprobadoController.text) ?? _solicitud!['monto_solicitado'])
                : _solicitud!['monto_solicitado'],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _solicitud!['id']);

      // 2. Marcar visita como completada en cartera
      await supabase
          .from('cartera_diaria')
          .update({'estado': 'Visitado', 'observacion': 'Crédito desembolsado y liquidado.'})
          .eq('cliente_id', cliente!.idCliente)
          .eq('tipo_gestion', 'NUEVA_SOLICITUD');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Crédito desembolsado con éxito! Cronograma de pagos activado.'),
          backgroundColor: AppTheme.neonGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.neonRed),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Comité y Desembolso'),
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: _loading && _solicitud == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _solicitud == null
                    ? const Center(child: Text('Cargando expediente...'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoPanel(),
                            const SizedBox(height: 14),
                            _buildWorkflowPanel(),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    final estado = _solicitud!['estado'].toString().toUpperCase();
    
    Color colorEstado = AppTheme.bcpCyan;
    if (estado == 'APROBADO' || estado == 'DESEMBOLSADO') colorEstado = AppTheme.neonGreen;
    if (estado == 'CONDICIONADO') colorEstado = Colors.amberAccent;
    if (estado == 'RECHAZADO') colorEstado = AppTheme.neonRed;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassDecoration(
        color: AppTheme.cardDark,
        opacity: 0.85,
        borderRadius: 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expediente: ${_solicitud!['id']}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorEstado.withOpacity(0.3)),
                ),
                child: Text(
                  estado,
                  style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildInfoFila('Monto Solicitado', 'S/ ${_solicitud!['monto_solicitado']}'),
          _buildInfoFila('Plazo', '${_solicitud!['plazo_meses']} meses'),
          _buildInfoFila('TEA Aplicada', '${_solicitud!['tea']}%'),
          _buildInfoFila('Garantía', _solicitud!['garantia'] ?? 'sin garantia'),
          _buildInfoFila('Seguro Desgravamen', _solicitud!['seguro_desgravamen'] == true ? 'SÍ' : 'NO'),
        ],
      ),
    );
  }

  Widget _buildWorkflowPanel() {
    final estado = _solicitud!['estado'].toString();

    // 1. Fase Recibido Comité
    if (estado == 'enviado') {
      return _buildPasoLayout(
        titulo: 'Fase 7: Comité de Crédito',
        subtitulo: 'La solicitud se encuentra en cola de comité del núcleo core financiero.',
        child: SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.bcpCyanGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: () => _actualizarEstado('recibido_comite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: const Text('PROMOVER A RECIBIDO COMITÉ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      );
    }

    // 2. Fase En Evaluación
    if (estado == 'recibido_comite') {
      return _buildPasoLayout(
        titulo: 'Fase 7: Evaluación de Riesgo',
        subtitulo: 'La solicitud ha sido recibida en el comité. Inicie la evaluación formal.',
        child: SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.bcpOrangeGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: () => _actualizarEstado('en_evaluacion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: const Text('INICIAR EVALUACIÓN DE COMITÉ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      );
    }

    // 3. Fase Decisión del Comité (Aprobar, Condicionar, Rechazar)
    if (estado == 'en_evaluacion') {
      return _buildPasoLayout(
        titulo: 'Fase 8: Decisión del Comité',
        subtitulo: 'El comité evalúa las garantías, el buró y la pre-evaluación para emitir dictamen.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _decisionComite,
              dropdownColor: AppTheme.cardDark,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Dictamen de Decisión'),
              items: const [
                DropdownMenuItem(value: 'APROBADO', child: Text('Aprobado')),
                DropdownMenuItem(value: 'CONDICIONADO', child: Text('Condicionado (Monto sugerido)')),
                DropdownMenuItem(value: 'RECHAZADO', child: Text('Rechazado')),
              ],
              onChanged: (val) {
                setState(() {
                  _decisionComite = val ?? 'APROBADO';
                });
                _recalcularAmortizacion();
              },
            ),
            const SizedBox(height: 14),

            // Campos adicionales según la decisión
            if (_decisionComite == 'CONDICIONADO') ...[
              TextField(
                controller: _montoAprobadoController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto Aprobado Reducido (S/)',
                ),
                onChanged: (_) => _recalcularAmortizacion(),
              ),
              const SizedBox(height: 10),
              const Text(
                'Nota: Las solicitudes condicionadas exigen recalcular la cuota sobre el monto reducido.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 14),
            ],

            if (_decisionComite == 'RECHAZADO') ...[
              TextField(
                controller: _motivoRechazoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Motivo del Rechazo del Expediente',
                ),
              ),
              const SizedBox(height: 14),
            ],

            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _decisionComite == 'RECHAZADO' ? null : AppTheme.bcpOrangeGradient,
                  color: _decisionComite == 'RECHAZADO' ? AppTheme.neonRed.withOpacity(0.8) : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: _registrarDecision,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text('REGISTRAR DECISIÓN DE COMITÉ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 4. Fase Desembolso y Cronograma
    if (estado == 'aprobado' || estado == 'condicionado') {
      return _buildPasoLayout(
        titulo: 'Fase 8: Desembolso y Cronograma',
        subtitulo: 'Genere el calendario de cuotas y desembolse los fondos.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _diaPago,
                    dropdownColor: AppTheme.cardDark,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Día de pago mensual'),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('Día 03')),
                      DropdownMenuItem(value: 5, child: Text('Día 05')),
                      DropdownMenuItem(value: 10, child: Text('Día 10')),
                      DropdownMenuItem(value: 15, child: Text('Día 15')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _diaPago = val ?? 3;
                      });
                      _recalcularAmortizacion();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _fechaDesembolso,
                          firstDate: DateTime(2026, 1, 1),
                          lastDate: DateTime(2027, 12, 31),
                        );
                        if (date != null) {
                          setState(() {
                            _fechaDesembolso = date;
                          });
                          _recalcularAmortizacion();
                        }
                      },
                      icon: const Icon(Icons.date_range, color: AppTheme.bcpOrange),
                      label: Text(
                        'Desembolso:\n${_fechaDesembolso.day.toString().padLeft(2, '0')}/${_fechaDesembolso.month.toString().padLeft(2, '0')}/${_fechaDesembolso.year}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Amortización calculada cuota fija
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.bcpBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.bcpCyan.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cuota Mensual Fija Francesa:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    'S/ ${cuotaCalculada.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppTheme.neonOrange, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Calendario de Amortización (Cronograma Final):',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            const SizedBox(height: 8),

            // Tabla de cronograma
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: cronogramaPagos.length,
                itemBuilder: (context, index) {
                  final row = cronogramaPagos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.01),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cuota ${row['n']} (${row['fecha']})',
                            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Cuota: S/ ${double.parse(row['cuota'].toString()).toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                              Text(
                                'Capital: S/ ${double.parse(row['capital'].toString()).toStringAsFixed(2)} | Interés: S/ ${double.parse(row['interes'].toString()).toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white30, fontSize: 9.5),
                              ),
                              Text(
                                'Saldo: S/ ${double.parse(row['saldo'].toString()).toStringAsFixed(2)}',
                                style: const TextStyle(color: AppTheme.neonCyan, fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.bcpCyanGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.neonGlowShadow(color: AppTheme.bcpCyan, opacity: 0.25),
                ),
                child: ElevatedButton.icon(
                  onPressed: _desembolsarCredito,
                  icon: const Icon(Icons.paid_outlined),
                  label: const Text('PROCESAR Y LIQUIDAR DESEMBOLSO', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 5. Finalizado (Desembolsado o Rechazado)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: (estado == 'desembolsado' ? AppTheme.neonGreen : AppTheme.neonRed).withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: (estado == 'desembolsado' ? AppTheme.neonGreen : AppTheme.neonRed).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            estado == 'desembolsado' ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: estado == 'desembolsado' ? AppTheme.neonGreen : AppTheme.neonRed,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            estado == 'desembolsado' ? 'CRÉDITO LIQUIDADO Y DESEMBOLSADO' : 'EXPEDIENTE CERRADO Y RECHAZADO',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: estado == 'desembolsado' ? AppTheme.neonGreen : AppTheme.neonRed,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            estado == 'desembolsado'
                ? 'El cronograma de pagos ha sido generado y activado para el cobro mensual del cliente.'
                : 'Motive: ${_solicitud!['motivo_rechazo'] ?? 'Sin especificar.'}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPasoLayout({required String titulo, required String subtitulo, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassDecoration(
        color: AppTheme.cardDark,
        opacity: 0.85,
        borderRadius: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15.5)),
          const SizedBox(height: 2),
          Text(subtitulo, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const Divider(color: Colors.white10, height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoFila(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
