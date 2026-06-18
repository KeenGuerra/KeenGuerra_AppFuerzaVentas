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
        title: const Text('Optimización de Ruta'),
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Panel de Geocerca (Tactical glowing style)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isInsideGeofence
                        ? [AppTheme.neonGreen.withOpacity(0.12), AppTheme.neonGreen.withOpacity(0.02)]
                        : [AppTheme.neonRed.withOpacity(0.12), AppTheme.neonRed.withOpacity(0.02)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isInsideGeofence ? AppTheme.neonGreen.withOpacity(0.5) : AppTheme.neonRed.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: AppTheme.neonGlowShadow(
                    color: isInsideGeofence ? AppTheme.neonGreen : AppTheme.neonRed,
                    opacity: 0.1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isInsideGeofence ? AppTheme.neonGreen : AppTheme.neonRed).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInsideGeofence ? Icons.security_rounded : Icons.gpp_bad_rounded,
                        color: isInsideGeofence ? AppTheme.neonGreen : AppTheme.neonRed,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isInsideGeofence
                                ? 'DENTRO DE COBERTURA'
                                : 'ALERTA: FUERA DE GEOCERCA',
                            style: TextStyle(
                              color: isInsideGeofence ? AppTheme.neonGreen : AppTheme.neonRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isInsideGeofence
                                ? 'Tu GPS coincide con tu polígono de visitas diario asignado.'
                                : 'Desvío detectado mediante Ray-Casting. Registra visitas con precaución.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mapa Vectorial de Ruta Simulado (Cyberpunk grid style)
              Container(
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: AppTheme.glassDecoration(
                  color: AppTheme.cardDark,
                  opacity: 0.85,
                  borderRadius: 26,
                  borderColor: AppTheme.bcpCyan,
                  borderOpacity: 0.12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    children: [
                      // Grid y Painter del Mapa
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
                      // Leyenda del mapa flotante
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12, width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.neonOrange,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: AppTheme.neonOrange, blurRadius: 4)],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Clientes', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 14),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.neonCyan,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: AppTheme.neonCyan, blurRadius: 4)],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Tu Ubicación', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
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
                child: Container(
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
                            Icon(Icons.satellite_alt_rounded, color: AppTheme.bcpOrange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Simulador de Señal Satelital GPS',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.shade900.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.green.shade800.withOpacity(0.4)),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      currentLat = -12.0870;
                                      currentLng = -77.0310;
                                      _recalcularRuta();
                                    });
                                  },
                                  icon: const Icon(Icons.location_on_rounded, color: AppTheme.neonGreen),
                                  label: const Text('Simular Dentro', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.red.shade800.withOpacity(0.4)),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      currentLat = -12.1200;
                                      currentLng = -77.0100;
                                      _recalcularRuta();
                                    });
                                  },
                                  icon: const Icon(Icons.navigation_rounded, color: AppTheme.neonRed),
                                  label: const Text('Simular Fuera', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
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
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Icon(Icons.alt_route_rounded, color: AppTheme.bcpCyan, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Hoja de Ruta Optimizada (Nearest Neighbor)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
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
                    decoration: AppTheme.glassDecoration(
                      color: AppTheme.cardDark,
                      opacity: 0.85,
                      borderRadius: 22,
                      borderColor: Colors.white,
                      borderOpacity: 0.04,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: AppTheme.bcpOrangeGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.neonGlowShadow(color: AppTheme.bcpOrange, opacity: 0.2),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.direccion ?? 'Sin dirección especificada',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Distancia estimada: ${dist.toStringAsFixed(2)} km de ti',
                              style: const TextStyle(
                                color: AppTheme.neonCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.bcpOrange.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.bcpOrange.withOpacity(0.3)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.near_me_rounded, color: AppTheme.neonOrange, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Redireccionando a Google Maps para visitar a ${item.nombre}...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
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

// Pintor del Mapa Vectorial Cyberpunk
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
    // Límites de coordenadas para mapeo
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

    // Dibujar cuadrícula de calles de fondo estilo matriz tecnológica
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), gridPaint);
    }
    for (int j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j.toDouble()), Offset(size.width, j.toDouble()), gridPaint);
    }

    // Dibujar calles diagonales simuladas
    final streetPaint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.8), streetPaint);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.8, size.height), streetPaint);

    // Dibujar Geocerca (Polígono con relleno semitransparente neón)
    if (geofence.isNotEmpty) {
      final geofencePaint = Paint()
        ..color = AppTheme.bcpCyan.withOpacity(0.05)
        ..style = PaintingStyle.fill;

      final geofenceBorderPaint = Paint()
        ..color = AppTheme.neonCyan.withOpacity(0.35)
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

    // Dibujar Ruta Conectora de Clientes (Línea degradada/brillante de ruta)
    final routePaint = Paint()
      ..color = AppTheme.neonOrange.withOpacity(0.7)
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

    // Dibujar Nodos Clientes (Naranja neón con halo de brillo)
    final clientPaint = Paint()..color = AppTheme.neonOrange;
    final clientGlow = Paint()
      ..color = AppTheme.neonOrange.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (final client in clients) {
      if (client.latitud != null && client.longitud != null) {
        final double cx = mapX(client.longitud);
        final double cy = mapY(client.latitud);
        
        canvas.drawCircle(Offset(cx, cy), 9, clientGlow);
        canvas.drawCircle(Offset(cx, cy), 5, clientPaint);
        canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = Colors.white);
      }
    }

    // Dibujar ubicación del Asesor (Cyan BCP con doble resplandor)
    final advisorPaint = Paint()..color = AppTheme.neonCyan;
    final advisorGlow = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final double ax = mapX(advisorLng);
    final double ay = mapY(advisorLat);

    canvas.drawCircle(Offset(ax, ay), 12, advisorGlow);
    canvas.drawCircle(Offset(ax, ay), 7, advisorPaint);
    canvas.drawCircle(Offset(ax, ay), 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
