import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../ui/theme/app_theme.dart';
import '../../model/cliente_cartera_model.dart';
import '../../model/solicitud_credito_model.dart';
import '../../viewmodel/auth_oficial_viewmodel.dart';
import '../../viewmodel/solicitud_viewmodel.dart';
import '../../services/offline_storage_service.dart';

class NuevaSolicitudScreen extends StatefulWidget {
  const NuevaSolicitudScreen({super.key});

  @override
  State<NuevaSolicitudScreen> createState() => _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState extends State<NuevaSolicitudScreen> {
  int currentStep = 0;
  final _offlineService = OfflineStorageService();

  // Paso 1: Solicitante
  final _nombresController = TextEditingController();
  final _dniController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ingresosController = TextEditingController(text: '3500');

  // Paso 2: Negocio
  final _negocioController = TextEditingController();
  final _giroController = TextEditingController(text: 'Bodega');
  final _ventasController = TextEditingController(text: '5000');

  // Paso 3: Condiciones
  final _montoController = TextEditingController(text: '10000');
  final _plazoController = TextEditingController(text: '12');
  final _teaController = TextEditingController(text: '28.5');

  // Simulación
  double cuotaMensual = 0.0;
  double totalAPagar = 0.0;
  double costoFinanciero = 0.0;

  // Paso 4: Firma
  final List<Offset?> points = [];
  bool isSigned = false;
  String clienteId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ClienteCarteraModel && clienteId.isEmpty) {
      clienteId = args.idCliente;
      _nombresController.text = args.nombre;
      _dniController.text = ''; 
      _negocioController.text = 'Negocio de ${args.nombre}';
    }
  }

  @override
  void initState() {
    super.initState();
    _calcularAmortizacion();
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _ingresosController.dispose();
    _negocioController.dispose();
    _giroController.dispose();
    _ventasController.dispose();
    _montoController.dispose();
    _plazoController.dispose();
    _teaController.dispose();
    super.dispose();
  }

  void _calcularAmortizacion() {
    final double P = double.tryParse(_montoController.text) ?? 0;
    final int n = int.tryParse(_plazoController.text) ?? 0;
    final double TEA = double.tryParse(_teaController.text) ?? 0;

    if (P <= 0 || n <= 0 || TEA <= 0) return;

    final double TEM = pow(1 + (TEA / 100), 1 / 12) - 1;
    final double factor = pow(1 + TEM, n).toDouble();
    cuotaMensual = P * (TEM * factor) / (factor - 1);
    totalAPagar = cuotaMensual * n;
    costoFinanciero = totalAPagar - P;
  }

  Future<void> _guardarComoBorrador() async {
    final authViewModel = context.read<AuthOficialViewModel>();
    final oficialId = authViewModel.oficial?.id ?? 'ofi_local';

    final borrador = SolicitudCreditoModel(
      oficialId: oficialId,
      clienteId: clienteId.isNotEmpty ? clienteId : 'cli_nuevo',
      montoSolicitado: double.tryParse(_montoController.text) ?? 0.0,
      plazoMeses: int.tryParse(_plazoController.text) ?? 12,
      destinoCredito: _giroController.text,
      estado: 'BORRADOR',
      syncStatus: 'PENDIENTE',
    );

    await _offlineService.guardarBorrador(borrador);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitud guardada localmente como Borrador Offline.'),
        backgroundColor: Colors.blueAccent,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _finalizarSolicitud() async {
    if (!isSigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe registrar la firma digital del cliente.')),
      );
      return;
    }

    final authViewModel = context.read<AuthOficialViewModel>();
    final solicitudViewModel = context.read<SolicitudViewModel>();
    final oficialId = authViewModel.oficial?.id ?? 'ofi_local';

    final nuevaSolicitud = SolicitudCreditoModel(
      oficialId: oficialId,
      clienteId: clienteId.isNotEmpty ? clienteId : 'cli_nuevo',
      montoSolicitado: double.tryParse(_montoController.text) ?? 0.0,
      plazoMeses: int.tryParse(_plazoController.text) ?? 12,
      destinoCredito: _giroController.text,
      estado: 'REGISTRADA',
      syncStatus: 'SINCRONIZADO',
    );

    await solicitudViewModel.registrarSolicitud(nuevaSolicitud);

    if (!mounted) return;

    if (solicitudViewModel.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud transmitida y aprobada por sistema.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: ${solicitudViewModel.error}. Guardado en cola local.')),
      );
      _guardarComoBorrador();
    }
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return _buildStepContainer(
      titulo: 'Datos del Solicitante',
      children: [
        TextField(
          controller: _nombresController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre Completo',
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.bcpOrange),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dniController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'DNI / RUC',
                  prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.bcpOrange),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _telefonoController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.bcpOrange),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _ingresosController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Ingresos Mensuales Declarados (S/)',
            prefixIcon: Icon(Icons.monetization_on_outlined, color: AppTheme.bcpOrange),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return _buildStepContainer(
      titulo: 'Datos del Negocio',
      children: [
        TextField(
          controller: _negocioController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre Comercial del Negocio',
            prefixIcon: Icon(Icons.storefront_outlined, color: AppTheme.bcpOrange),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _giroController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Giro del Negocio / Actividad',
            prefixIcon: Icon(Icons.category_outlined, color: AppTheme.bcpOrange),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _ventasController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Ventas Mensuales Estimadas (S/)',
            prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppTheme.bcpOrange),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return _buildStepContainer(
      titulo: 'Condiciones y Simulación Francesa',
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _montoController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto (S/)',
                  prefixIcon: Icon(Icons.attach_money_outlined, color: AppTheme.bcpOrange),
                ),
                onChanged: (_) => setState(() => _calcularAmortizacion()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _plazoController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Plazo (Meses)',
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: AppTheme.bcpOrange),
                ),
                onChanged: (_) => setState(() => _calcularAmortizacion()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _teaController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Tasa Efectiva Anual - TEA (%)',
            prefixIcon: Icon(Icons.percent_outlined, color: AppTheme.bcpOrange),
          ),
          onChanged: (_) => setState(() => _calcularAmortizacion()),
        ),
        const SizedBox(height: 20),

        // Resultados
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.inputFieldColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.bcpCyan.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Simulación Financiera Sugerida',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.bcpCyan, fontSize: 13, letterSpacing: 0.5),
              ),
              const Divider(color: Colors.white12, height: 18),
              _buildSimDato('Cuota Mensual Estimada', 'S/ ${cuotaMensual.toStringAsFixed(2)}'),
              _buildSimDato('Total a Pagar', 'S/ ${totalAPagar.toStringAsFixed(2)}'),
              _buildSimDato('Costo Financiero (Intereses)', 'S/ ${costoFinanciero.toStringAsFixed(2)}', isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimDato(String desc, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            val,
            style: TextStyle(
              color: isBold ? AppTheme.bcpOrange : Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 15 : 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return _buildStepContainer(
      titulo: 'Firma Digital del Solicitante',
      children: [
        const Text(
          'Solicite al cliente firmar dentro del panel para validar su consentimiento de consulta SBS y solicitud formal de crédito.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 16),

        // Panel de Dibujo de Firma
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                GestureDetector(
                  onPanUpdate: (DragUpdateDetails details) {
                    final box = context.findRenderObject() as RenderBox;
                    final point = box.globalToLocal(details.globalPosition);
                    setState(() {
                      points.add(point);
                      isSigned = true;
                    });
                  },
                  onPanEnd: (DragEndDetails details) {
                    points.add(null);
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(points: points),
                    size: Size.infinite,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          points.clear();
                          isSigned = false;
                        });
                      },
                      tooltip: 'Limpiar Firma',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContainer({required String titulo, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
          ),
          const Divider(color: Colors.white12, height: 24),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Nueva Solicitud'),
        backgroundColor: AppTheme.bcpBlue,
        actions: [
          TextButton.icon(
            onPressed: _guardarComoBorrador,
            icon: const Icon(Icons.save_outlined, color: AppTheme.bcpOrange, size: 20),
            label: const Text('Guardar Borrador', style: TextStyle(color: AppTheme.bcpOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Indicador de pasos
              Row(
                children: List.generate(4, (index) {
                  final active = index <= currentStep;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 5,
                      decoration: BoxDecoration(
                        color: active ? AppTheme.bcpOrange : Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Contenido del paso
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(),
                ),
              ),

              // Botones de navegación
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 0)
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Atrás', style: TextStyle(color: Colors.white)),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: () {
                      if (currentStep < 3) {
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        _finalizarSolicitud();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(currentStep < 3 ? 'Siguiente' : 'Enviar Solicitud'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
