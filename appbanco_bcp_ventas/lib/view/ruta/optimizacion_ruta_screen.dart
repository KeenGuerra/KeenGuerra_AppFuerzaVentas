import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../ui/theme/app_theme.dart';
import '../../viewmodel/cartera_viewmodel.dart';
import '../../services/gps_simulator_service.dart';

class OptimizacionRutaScreen extends StatefulWidget {
  const OptimizacionRutaScreen({super.key});

  @override
  State<OptimizacionRutaScreen> createState() => _OptimizacionRutaScreenState();
}

class _OptimizacionRutaScreenState extends State<OptimizacionRutaScreen> {
  final GpsSimulatorService _gpsService = GpsSimulatorService();
  double currentLat = -12.0847;
  double currentLng = -77.0315;
  bool isInsideGeofence = true;
  List<dynamic> rutaOptimizada = [];

  @override
  void initState() {
    super.initState();
    _recalcularRuta();
  }

  void _recalcularRuta() {
    final carteraViewModel = context.read<CarteraViewModel>();
    final clientes = carteraViewModel.clientes;

    // Nearest Neighbor optimization
    rutaOptimizada = _gpsService.optimizarRuta<dynamic>(
      latInicial: currentLat,
      lngInicial: currentLng,
      items: clientes,
      getLat: (item) => item.latitud,
      getLng: (item) => item.longitud,
    );

    isInsideGeofence = _gpsService.estaDentroDeGeocerca(currentLat, currentLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Optimización de Ruta GPS'),
        backgroundColor: AppTheme.bcpBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Panel de Geocerca
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isInsideGeofence
                      ? Colors.green.withOpacity(0.08)
                      : Colors.redAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isInsideGeofence ? Colors.greenAccent : Colors.redAccent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isInsideGeofence ? Icons.gpp_good_outlined : Icons.gpp_bad_outlined,
                      color: isInsideGeofence ? Colors.greenAccent : Colors.redAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isInsideGeofence
                                ? 'Dentro de Zona Asignada'
                                : 'Fuera de Zona (Alerta de Geocerca)',
                            style: TextStyle(
                              color: isInsideGeofence
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isInsideGeofence
                                ? 'Tu ubicación actual coincide con tu polígono de visitas diario.'
                                : 'ADVERTENCIA: Estás fuera de la geocerca. El Ray-Casting detectó desvío.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mapa Vectorial de Ruta Simulado
              Container(
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.04),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // Custom Painter for Map
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MapVectorPainter(
                            advisorLat: currentLat,
                            advisorLng: currentLng,
                            geofence: _gpsService.geocercaAsesor,
                            clients: rutaOptimizada,
                          ),
                        ),
                      ),
                      // Indicadores del mapa
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(
                                  radius: 4, backgroundColor: AppTheme.bcpOrange),
                              SizedBox(width: 6),
                              Text('Clientes',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.white)),
                              SizedBox(width: 12),
                              CircleAvatar(radius: 4, backgroundColor: AppTheme.bcpCyan),
                              SizedBox(width: 6),
                              Text('Tú',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Controles de Simulación GPS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: AppTheme.cardDark.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Simulación de Ubicación GPS',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    // Simular estar DENTRO de la geocerca
                                    currentLat = -12.0870;
                                    currentLng = -77.0310;
                                    _recalcularRuta();
                                  });
                                },
                                icon: const Icon(Icons.location_on_outlined),
                                label: const Text('Simular Dentro'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    // Simular estar FUERA de la geocerca
                                    currentLat = -12.1200;
                                    currentLng = -77.0100;
                                    _recalcularRuta();
                                  });
                                },
                                icon: const Icon(Icons.navigation_outlined),
                                label: const Text('Simular Fuera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lista de Ruta Optimizada
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ruta de Visitas Sugerida',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: rutaOptimizada.length,
                itemBuilder: (context, index) {
                  final item = rutaOptimizada[index];
                  final double dist = _gpsService.calcularDistancia(
                    currentLat,
                    currentLng,
                    item.latitud ?? 0,
                    item.longitud ?? 0,
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                        width: 1.2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.bcpOrange,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        item.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            item.direccion ?? 'Dirección no especificada',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Aprox. a ${dist.toStringAsFixed(2)} km de ti',
                            style: const TextStyle(
                              color: AppTheme.bcpCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.directions_outlined, color: AppTheme.bcpOrange),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Abriendo navegación Waze/Google Maps para ${item.nombre}...'),
                            ),
                          );
                        },
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
}

class _MapVectorPainter extends CustomPainter {
  final double advisorLat;
  final double advisorLng;
  final List<GpsPoint> geofence;
  final List<dynamic> clients;

  _MapVectorPainter({
    required this.advisorLat,
    required this.advisorLng,
    required this.geofence,
    required this.clients,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double minLat = -12.1300;
    const double maxLat = -12.0700;
    const double minLng = -77.0500;
    const double maxLng = -77.0000;

    double mapX(double lng) {
      return size.width * (lng - minLng) / (maxLng - minLng);
    }

    double mapY(double lat) {
      return size.height * (maxLat - lat) / (maxLat - minLat);
    }

    final streetPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        streetPaint,
      );
    }
    for (int j = 0; j < size.height; j += 40) {
      canvas.drawLine(
        Offset(0, j.toDouble()),
        Offset(size.width, j.toDouble()),
        streetPaint,
      );
    }

    // Dibujar Geocerca (Polígono)
    if (geofence.isNotEmpty) {
      final geofencePaint = Paint()
        ..color = AppTheme.bcpCyan.withOpacity(0.06)
        ..style = PaintingStyle.fill;

      final geofenceBorderPaint = Paint()
        ..color = AppTheme.bcpCyan.withOpacity(0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(mapX(geofence[0].lng), mapY(geofence[0].lat));
      for (int i = 1; i < geofence.length; i++) {
        path.lineTo(mapX(geofence[i].lng), mapY(geofence[i].lat));
      }
      path.close();

      canvas.drawPath(path, geofencePaint);
      canvas.drawPath(path, geofenceBorderPaint);
    }

    // Dibujar Ruta Conectora
    final routePaint = Paint()
      ..color = AppTheme.bcpOrange.withOpacity(0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double currentX = mapX(advisorLng);
    double currentY = mapY(advisorLat);

    for (final client in clients) {
      if (client.latitud != null && client.longitud != null) {
        final double nextX = mapX(client.longitud);
        final double nextY = mapY(client.latitud);

        canvas.drawLine(Offset(currentX, currentY), Offset(nextX, nextY), routePaint);
        currentX = nextX;
        currentY = nextY;
      }
    }

    // Dibujar Clientes
    final clientPaint = Paint()..color = AppTheme.bcpOrange;
    for (final client in clients) {
      if (client.latitud != null && client.longitud != null) {
        final double cx = mapX(client.longitud);
        final double cy = mapY(client.latitud);
        canvas.drawCircle(Offset(cx, cy), 7, clientPaint);
        canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
      }
    }

    // Dibujar ubicación del Asesor (Cyan BCP)
    final advisorPaint = Paint()..color = AppTheme.bcpCyan;
    final double ax = mapX(advisorLng);
    final double ay = mapY(advisorLat);
    canvas.drawCircle(Offset(ax, ay), 9, advisorPaint);
    canvas.drawCircle(Offset(ax, ay), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
