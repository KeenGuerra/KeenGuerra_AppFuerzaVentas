import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../model/cliente_cartera_model.dart';
import '../../ui/theme/app_theme.dart';
import '../../viewmodel/cliente_viewmodel.dart';
import '../../viewmodel/cartera_viewmodel.dart';
import '../../navigation/app_routes.dart';

class DetalleClienteScreen extends StatefulWidget {
  const DetalleClienteScreen({super.key});

  @override
  State<DetalleClienteScreen> createState() => _DetalleClienteScreenState();
}

class _DetalleClienteScreenState extends State<DetalleClienteScreen> {
  ClienteCarteraModel? clienteCartera;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is ClienteCarteraModel && clienteCartera == null) {
      clienteCartera = args;

      Future.microtask(() {
        context
            .read<ClienteViewModel>()
            .cargarFichaCliente(args.idCliente);
      });
    }
  }

  Future<void> marcarComoVisitado() async {
    if (clienteCartera == null) return;

    await context.read<CarteraViewModel>().actualizarEstadoGestion(
          idCartera: clienteCartera!.idCartera,
          nuevoEstado: 'Visitado',
          observacion: 'Cliente visitado desde la ficha del cliente.',
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gestión actualizada como visitada con éxito.'),
        backgroundColor: AppTheme.neonGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClienteViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: const Text('Expediente del Cliente'),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: viewModel.loading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.bcpOrange),
              )
            : viewModel.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        viewModel.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.neonRed, fontSize: 15),
                      ),
                    ),
                  )
                : viewModel.cliente == null
                    ? const Center(
                        child: Text(
                          'No se encontró información del cliente.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabecera Premium
                            _CabeceraCliente(
                              nombre: viewModel.cliente!.nombreCompleto,
                              dni: viewModel.cliente!.dni,
                              estado: viewModel.cliente!.estado,
                            ),

                            const SizedBox(height: 12),

                            // Alertas de Cartera y Semáforo de Riesgo (Glassmorphic panels)
                            _buildRiesgoYAlertasSection(),

                            const SizedBox(height: 12),

                            // Oferta Campaña Destacada (Con gradiente de contraste)
                            _buildOfertasPreaprobadasCard(),

                            const SizedBox(height: 12),

                            // Tarjeta de Información General
                            _SeccionCard(
                              titulo: 'Información General',
                              icono: Icons.person_outline_rounded,
                              children: [
                                _buildDatoFila(
                                  titulo: 'Teléfono o Celular',
                                  valor: viewModel.cliente!.telefono ?? 'No registrado',
                                  icono: Icons.phone_android_rounded,
                                ),
                                const Divider(color: Colors.white10, height: 16),
                                _buildDatoFila(
                                  titulo: 'Dirección del Domicilio',
                                  valor: viewModel.cliente!.direccion ?? 'No registrada',
                                  icono: Icons.home_work_outlined,
                                ),
                                const Divider(color: Colors.white10, height: 16),
                                _buildDatoFila(
                                  titulo: 'Nombre del Negocio',
                                  valor: viewModel.cliente!.negocio ?? 'No registrado',
                                  icono: Icons.storefront_outlined,
                                ),
                                const Divider(color: Colors.white10, height: 16),
                                _buildDatoFila(
                                  titulo: 'Actividad Económica principal',
                                  valor: viewModel.cliente!.actividadEconomica ?? 'No registrada',
                                  icono: Icons.monetization_on_outlined,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Estado de Gestión en Campo
                            _SeccionCard(
                              titulo: 'Gestión en Campo Diaria',
                              icono: Icons.assignment_turned_in_outlined,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _DatoItem(
                                        titulo: 'Tipo de gestión',
                                        valor: clienteCartera?.tipoGestion ?? 'No Asignado',
                                      ),
                                    ),
                                    Expanded(
                                      child: _DatoItem(
                                        titulo: 'Estado actual hoy',
                                        valor: clienteCartera?.estado ?? 'Pendiente',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                if (clienteCartera?.estado != 'Visitado')
                                  SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.bcpCyanGradient,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: AppTheme.neonGlowShadow(
                                          color: AppTheme.bcpCyan,
                                          opacity: 0.2,
                                        ),
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: marcarComoVisitado,
                                        icon: const Icon(Icons.check_circle_outline_rounded),
                                        label: const Text('MARCAR COMO VISITADO'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          surfaceTintColor: Colors.transparent,
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonGreen.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'VISITA REGISTRADA CON ÉXITO',
                                          style: TextStyle(
                                            color: AppTheme.neonGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Historial de Pagos y Gráfico Bezier
                            _buildGraficoPagosCard(),

                            const SizedBox(height: 12),

                            // Productos Activos BCP
                            _SeccionCard(
                              titulo: 'Productos Activos BCP',
                              icono: Icons.credit_card_rounded,
                              children: viewModel.productosActivos.isEmpty
                                  ? const [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          'No hay productos activos registrados.',
                                          style: TextStyle(color: Colors.white30, fontSize: 13),
                                        ),
                                      ),
                                    ]
                                  : viewModel.productosActivos.map((producto) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.03),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                producto['producto']?.toString() ?? 'Producto BCP',
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                              Text(
                                                'Saldo: S/ ${producto['saldo'] ?? '0.00'}',
                                                style: const TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                            ),

                            const SizedBox(height: 12),

                            // Historial Crediticio
                            _SeccionCard(
                              titulo: 'Historial Crediticio',
                              icono: Icons.history_edu_rounded,
                              children: viewModel.historialCrediticio.isEmpty
                                  ? const [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          'No hay historial crediticio registrado.',
                                          style: TextStyle(color: Colors.white30, fontSize: 13),
                                        ),
                                      ),
                                    ]
                                  : viewModel.historialCrediticio.map((item) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.02),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['producto']?.toString() ?? 'Préstamo',
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              Text(
                                                'S/ ${item['monto']} [${item['estado']}]',
                                                style: TextStyle(
                                                  color: item['estado'] == 'Cancelado' || item['estado'] == 'Pagado'
                                                      ? AppTheme.neonGreen
                                                      : AppTheme.neonOrange,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                            ),

                            const SizedBox(height: 20),

                            // Bloque de Acciones Rápidas con flechas y gradientes
                            _AccionesCliente(
                              cliente: clienteCartera,
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildDatoFila({required String titulo, required String valor, required IconData icono}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: AppTheme.bcpCyan, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                valor,
                style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiesgoYAlertasSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Semáforo de riesgo rediseñado
        Expanded(
          flex: 4,
          child: Container(
            decoration: AppTheme.glassDecoration(
              color: AppTheme.cardDark,
              opacity: 0.85,
              borderRadius: 24,
              borderColor: AppTheme.neonGreen,
              borderOpacity: 0.15,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Score SBS',
                    style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.2),
                      border: Border.all(color: AppTheme.neonGreen, width: 3.5),
                      boxShadow: AppTheme.neonGlowShadow(color: AppTheme.neonGreen, opacity: 0.25, blurRadius: 10),
                    ),
                    child: const Center(
                      child: Text(
                        'A+',
                        style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Score: 740 / 850', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  const SizedBox(height: 3),
                  const Text(
                    'RIESGO BAJO',
                    style: TextStyle(
                      color: AppTheme.neonGreen, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 10, 
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Alertas de cartera rediseñadas
        Expanded(
          flex: 6,
          child: Container(
            height: 155, // Igualar altura del bloque izquierdo
            decoration: AppTheme.glassDecoration(
              color: AppTheme.cardDark,
              opacity: 0.85,
              borderRadius: 24,
              borderColor: Colors.white,
              borderOpacity: 0.05,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alertas del Sistema',
                    style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppTheme.bcpOrange.withOpacity(0.12), shape: BoxShape.circle),
                        child: const Icon(Icons.cake_outlined, color: AppTheme.neonOrange, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '¡Cumpleaños hoy!',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.12), shape: BoxShape.circle),
                        child: const Icon(Icons.star_outline_rounded, color: Colors.amberAccent, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Calificación: Excelente.',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfertasPreaprobadasCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C2554), Color(0xFF07183B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.bcpCyan.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: AppTheme.neonGlowShadow(color: AppTheme.bcpCyan, opacity: 0.15, blurRadius: 12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.bcpCyan.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, color: AppTheme.neonCyan, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CAMPAÑA PREAPROBADA BCP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: AppTheme.neonCyan, 
                      fontSize: 11, 
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Micro-crédito: S/ 15,000',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tasa preferencial: 15.5% TEA a 12 meses',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.bcpOrangeGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.neonGlowShadow(color: AppTheme.bcpOrange, opacity: 0.25),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.nuevaSolicitud,
                    arguments: clienteCartera,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'TOMAR',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoPagosCard() {
    return Container(
      decoration: AppTheme.glassDecoration(
        color: AppTheme.cardDark,
        opacity: 0.85,
        borderRadius: 24,
        borderColor: Colors.white,
        borderOpacity: 0.04,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart_rounded, color: AppTheme.bcpOrange),
                SizedBox(width: 8),
                Text(
                  'Historial de Pagos de Cuotas',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              height: 110,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: CustomPaint(
                painter: _PaymentGraphPainter(),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ene (S/350)', style: TextStyle(color: Colors.white30, fontSize: 9.5)),
                Text('Feb (S/350)', style: TextStyle(color: Colors.white30, fontSize: 9.5)),
                Text('Mar (S/350)', style: TextStyle(color: Colors.white30, fontSize: 9.5)),
                Text('Abr (S/350)', style: TextStyle(color: Colors.white30, fontSize: 9.5)),
                Text('May (S/350)', style: TextStyle(color: Colors.white30, fontSize: 9.5)),
                Text('Jun (S/350)', style: TextStyle(color: Colors.white30, fontSize: 9.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter de Gráficos Bezier Premium con degradado neón
class _PaymentGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double stepX = size.width / 5;
    // Puntos normalizados (0 a 1) para representar altura
    final List<double> ptsY = [0.8, 0.76, 0.85, 0.82, 0.92, 0.89];

    // Dibujar líneas verticales sutiles de la cuadrícula de fondo
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    for (int i = 0; i < ptsY.length; i++) {
      canvas.drawLine(Offset(stepX * i, 0), Offset(stepX * i, size.height), gridPaint);
    }

    final linePaint = Paint()
      ..color = AppTheme.neonCyan
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.bcpCyan.withOpacity(0.3), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height - (size.height * ptsY[0]));

    // Dibujar curvas Bezier suaves (Spline)
    for (int i = 0; i < ptsY.length - 1; i++) {
      final x1 = stepX * i;
      final y1 = size.height - (size.height * ptsY[i]);
      final x2 = stepX * (i + 1);
      final y2 = size.height - (size.height * ptsY[i + 1]);
      
      final cx = (x1 + x2) / 2;
      path.cubicTo(cx, y1, cx, y2, x2, y2);
    }

    canvas.drawPath(path, linePaint);

    // Rellenar área bajo la curva suave
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    // Puntos decorativos con resplandor neón
    final dotPaint = Paint()..color = Colors.white;
    final dotGlow = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < ptsY.length; i++) {
      final center = Offset(stepX * i, size.height - (size.height * ptsY[i]));
      canvas.drawCircle(center, 7, dotGlow);
      canvas.drawCircle(center, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CabeceraCliente extends StatelessWidget {
  final String nombre;
  final String dni;
  final String estado;

  const _CabeceraCliente({
    required this.nombre,
    required this.dni,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassDecoration(
        color: AppTheme.cardDark,
        opacity: 0.85,
        borderRadius: 26,
        borderColor: AppTheme.bcpCyan,
        borderOpacity: 0.12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.bcpOrange, width: 2.5),
                boxShadow: AppTheme.neonGlowShadow(color: AppTheme.bcpOrange, opacity: 0.25),
              ),
              child: const CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.darkBackground,
                child: Icon(
                  Icons.person_outline_sharp,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Documento Nacional de Identidad: $dni',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neonGreen.withOpacity(0.4)),
                    ),
                    child: Text(
                      estado.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.neonGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> children;

  const _SeccionCard({
    required this.titulo,
    required this.icono,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassDecoration(
        color: AppTheme.cardDark,
        opacity: 0.85,
        borderRadius: 24,
        borderColor: Colors.white,
        borderOpacity: 0.04,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.bcpCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: AppTheme.bcpCyan, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Divider(color: Colors.white10, height: 1),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DatoItem extends StatelessWidget {
  final String titulo;
  final String valor;

  const _DatoItem({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AccionesCliente extends StatelessWidget {
  final ClienteCarteraModel? cliente;

  const _AccionesCliente({
    required this.cliente,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccionButton(
          icono: Icons.description_outlined,
          texto: 'Nueva Solicitud de Crédito',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.nuevaSolicitud,
              arguments: cliente,
            );
          },
        ),
        _AccionButton(
          icono: Icons.camera_alt_outlined,
          texto: 'Capturar Documentos de Soporte',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.capturaDocumentos,
              arguments: cliente,
            );
          },
        ),
        _AccionButton(
          icono: Icons.screen_search_desktop_outlined,
          texto: 'Consultar Buró de Crédito SBS',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.consultaBuro,
              arguments: cliente,
            );
          },
        ),
        _AccionButton(
          icono: Icons.gavel_rounded,
          texto: 'Gestionar Comité y Desembolso',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.decisionDesembolso,
              arguments: cliente,
            );
          },
        ),
      ],
    );
  }
}

class _AccionButton extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _AccionButton({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.glassDecoration(
        color: AppTheme.cardDark,
        opacity: 0.85,
        borderRadius: 20,
        borderColor: AppTheme.bcpOrange,
        borderOpacity: 0.08,
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.bcpOrange.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icono,
            color: AppTheme.neonOrange,
            size: 20,
          ),
        ),
        title: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white30,
          size: 14,
        ),
      ),
    );
  }
}