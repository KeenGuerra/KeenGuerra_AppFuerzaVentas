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
        content: Text('Gestión actualizada como visitada.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClienteViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.bcpBlue,
        title: const Text('Ficha del Cliente'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: viewModel.loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : viewModel.error != null
                ? Center(
                    child: Text(
                      viewModel.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
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
                            _CabeceraCliente(
                              nombre: viewModel.cliente!.nombreCompleto,
                              dni: viewModel.cliente!.dni,
                              estado: viewModel.cliente!.estado,
                            ),

                            const SizedBox(height: 12),

                            // Alertas de Cartera y Semáforo de Riesgo
                            _buildRiesgoYAlertasSection(),

                            const SizedBox(height: 12),

                            // Ofertas Preaprobadas
                            _buildOfertasPreaprobadasCard(),

                            const SizedBox(height: 12),

                            _SeccionCard(
                              titulo: 'Información General',
                              icono: Icons.person_outline,
                              children: [
                                _DatoItem(
                                  titulo: 'Teléfono',
                                  valor: viewModel.cliente!.telefono ??
                                      'No registrado',
                                ),
                                _DatoItem(
                                  titulo: 'Dirección',
                                  valor: viewModel.cliente!.direccion ??
                                      'No registrada',
                                ),
                                _DatoItem(
                                  titulo: 'Negocio',
                                  valor: viewModel.cliente!.negocio ??
                                      'No registrado',
                                ),
                                _DatoItem(
                                  titulo: 'Actividad Económica',
                                  valor: viewModel.cliente!.actividadEconomica ??
                                      'No registrada',
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            _SeccionCard(
                              titulo: 'Gestión de Cartera Diaria',
                              icono: Icons.assignment_outlined,
                              children: [
                                _DatoItem(
                                    titulo: 'Tipo de gestión',
                                    valor: clienteCartera?.tipoGestion ?? 'Sin dato'),
                                _DatoItem(
                                    titulo: 'Estado actual de hoy',
                                    valor: clienteCartera?.estado ?? 'Sin dato'),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: marcarComoVisitado,
                                    icon: const Icon(Icons.check_circle_outline),
                                    label: const Text('Marcar como visitado'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Historial de Pagos y Gráfico CustomPainter
                            _buildGraficoPagosCard(),

                            const SizedBox(height: 12),

                            _SeccionCard(
                              titulo: 'Productos Activos BCP',
                              icono: Icons.credit_card_outlined,
                              children: viewModel.productosActivos.isEmpty
                                  ? const [
                                      Text(
                                        'No hay productos activos registrados.',
                                        style: TextStyle(color: Colors.white38),
                                      ),
                                    ]
                                  : viewModel.productosActivos.map((producto) {
                                      return _DatoItem(
                                        titulo:
                                            producto['producto']?.toString() ??
                                                'Producto',
                                        valor:
                                            'Saldo: S/ ${producto['saldo'] ?? '0.00'}',
                                      );
                                    }).toList(),
                            ),

                            const SizedBox(height: 12),

                            _SeccionCard(
                              titulo: 'Historial Crediticio',
                              icono: Icons.history_outlined,
                              children: viewModel.historialCrediticio.isEmpty
                                  ? const [
                                      Text(
                                        'No hay historial crediticio registrado.',
                                        style: TextStyle(color: Colors.white38),
                                      ),
                                    ]
                                  : viewModel.historialCrediticio.map((item) {
                                      return _DatoItem(
                                        titulo:
                                            item['producto']?.toString() ??
                                                'Crédito',
                                        valor:
                                            'Monto: S/ ${item['monto']} | Estado: ${item['estado']}',
                                      );
                                    }).toList(),
                            ),

                            const SizedBox(height: 18),

                            _AccionesCliente(
                              cliente: clienteCartera,
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildRiesgoYAlertasSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Semáforo de riesgo
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withOpacity(0.9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.04),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  const Text(
                    'Score Buró',
                    style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withOpacity(0.08),
                      border: Border.all(color: Colors.greenAccent, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'A+',
                        style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Score: 740 / 850', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const Text('RIESGO BAJO', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Alertas de cartera
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withOpacity(0.9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.04),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alertas de Campo',
                    style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.cake_outlined, color: AppTheme.bcpOrange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '¡Cumpleaños del cliente hoy!',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_outline_rounded, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cliente clasificado Excelente.',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
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
        gradient: LinearGradient(
          colors: [
            AppTheme.bcpBlue.withOpacity(0.8),
            const Color(0xFF001A40),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.bcpCyan.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.bcpCyan,
              child: Icon(Icons.stars, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Oferta Campaña Pre-aprobada',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.bcpCyan, fontSize: 13, letterSpacing: 0.5),
                  ),
                  const Text(
                    'BCP Micro-crédito: S/ 15,000',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Tasa preferencial: 15.5% TEA a 12 meses',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.nuevaSolicitud,
                  arguments: clienteCartera,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.bcpOrange,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tomar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoPagosCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart_outlined, color: AppTheme.bcpOrange),
                SizedBox(width: 8),
                Text(
                  'Historial de Pagos de Cuotas',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.5),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                Text('Ene (S/350)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('Feb (S/350)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('Mar (S/350)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('Abr (S/350)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('May (S/350)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('Jun (S/350)', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double stepX = size.width / 5;
    final List<double> ptsY = [0.8, 0.76, 0.85, 0.82, 0.92, 0.89];

    final linePaint = Paint()
      ..color = AppTheme.bcpCyan
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.bcpCyan.withOpacity(0.25), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height - (size.height * ptsY[0]));

    for (int i = 1; i < ptsY.length; i++) {
      path.lineTo(stepX * i, size.height - (size.height * ptsY[i]));
    }

    canvas.drawPath(path, linePaint);

    // Rellenar área bajo la curva
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);

    // Puntos decorativos
    final dotPaint = Paint()..color = Colors.white;
    final borderDotPaint = Paint()
      ..color = AppTheme.bcpCyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < ptsY.length; i++) {
      final center = Offset(stepX * i, size.height - (size.height * ptsY[i]));
      canvas.drawCircle(center, 4.5, dotPaint);
      canvas.drawCircle(center, 4.5, borderDotPaint);
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
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.bcpOrange, width: 2),
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DNI: $dni',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.green.withOpacity(0.4), width: 1),
                    ),
                    child: Text(
                      estado,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
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
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: AppTheme.bcpCyan, size: 22),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
          icono: Icons.request_page_outlined,
          texto: 'Nueva solicitud de crédito',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.nuevaSolicitud,
              arguments: cliente,
            );
          },
        ),
        _AccionButton(
          icono: Icons.folder_open_outlined,
          texto: 'Capturar documentos',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.capturaDocumentos,
              arguments: cliente,
            );
          },
        ),
        _AccionButton(
          icono: Icons.search_outlined,
          texto: 'Consultar buró',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.consultaBuro,
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
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1.2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(
          icono,
          color: AppTheme.bcpOrange,
          size: 22,
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
          Icons.arrow_forward_ios,
          color: Colors.white30,
          size: 14,
        ),
      ),
    );
  }
}