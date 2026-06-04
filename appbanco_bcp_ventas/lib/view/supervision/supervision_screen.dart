import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class SupervisionScreen extends StatefulWidget {
  const SupervisionScreen({super.key});

  @override
  State<SupervisionScreen> createState() => _SupervisionScreenState();
}

class _SupervisionScreenState extends State<SupervisionScreen> {
  final List<Map<String, dynamic>> asesoresMetrics = [
    {
      'nombres': 'Carlos Prado',
      'colocado': 85000,
      'meta': 100000,
      'expedientes': 14,
      'mora': '1.2%'
    },
    {
      'nombres': 'Ana Gómez Valdivia',
      'colocado': 112000,
      'meta': 100000,
      'expedientes': 19,
      'mora': '0.8%'
    },
    {
      'nombres': 'Luis Felipe Medina',
      'colocado': 45000,
      'meta': 90000,
      'expedientes': 8,
      'mora': '2.5%'
    },
  ];

  void _exportarReportePDF() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando reporte PDF consolidado...'),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reporte PDF guardado en descargas (Reporte_Productividad_Junio.pdf)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalColocado = asesoresMetrics.fold(0.0, (sum, item) => sum + item['colocado']);
    double totalMeta = asesoresMetrics.fold(0.0, (sum, item) => sum + item['meta']);
    double porcentajeAvance = (totalColocado / totalMeta) * 100;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Consola de Supervisión Zonal'),
        backgroundColor: AppTheme.bcpBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.bcpOrange),
            onPressed: _exportarReportePDF,
            tooltip: 'Exportar PDF',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel de Resumen
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen Zonal - Junio 2026',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.3),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                                'Volumen Colocado', 'S/ ${totalColocado.toStringAsFixed(0)}'),
                          ),
                          Expanded(
                            child: _buildMetricTile(
                                'Meta Colectiva', 'S/ ${totalMeta.toStringAsFixed(0)}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Avance de la Meta: ${porcentajeAvance.toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: totalColocado / totalMeta,
                          backgroundColor: Colors.white12,
                          color: AppTheme.bcpOrange,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Gráfico CustomPainter
              const Text(
                'Desembolsos Semanales del Equipo',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3),
              ),
              const SizedBox(height: 12),

              Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                ),
                child: CustomPaint(
                  painter: _BarChartPainter(),
                  size: Size.infinite,
                ),
              ),

              const SizedBox(height: 20),

              // Lista de asesores
              const Text(
                'Productividad Individual de Asesores',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: asesoresMetrics.length,
                itemBuilder: (context, index) {
                  final a = asesoresMetrics[index];
                  double avance = (a['colocado'] / a['meta']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                a['nombres'],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                              ),
                              Text(
                                'Mora: ${a['mora']}',
                                style: TextStyle(
                                  color: a['mora'].toString().contains('2') ? Colors.redAccent : Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Colocado: S/ ${a['colocado']} • Meta: S/ ${a['meta']}',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                              Text(
                                '${(avance * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(color: AppTheme.bcpOrange, fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: avance,
                              backgroundColor: Colors.white12,
                              color: avance >= 1.0 ? Colors.greenAccent : AppTheme.bcpOrange,
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double barWidth = size.width / 9;
    final double space = size.width / 9;

    final List<double> values = [0.3, 0.5, 0.45, 0.75, 0.9];
    final List<String> labels = ['S1', 'S2', 'S3', 'S4', 'S5'];

    // Líneas horizontales de fondo
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double i = 0.0; i <= 1.0; i += 0.25) {
      double y = size.height * (1.0 - i);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.bcpOrange, Colors.orangeAccent],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      double x = space * i * 1.5 + space;
      double h = size.height * values[i];
      double y = size.height - h;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, h),
        const Radius.circular(6),
      );

      canvas.drawRRect(rrect, barPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (barWidth - textPainter.width) / 2, size.height + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
