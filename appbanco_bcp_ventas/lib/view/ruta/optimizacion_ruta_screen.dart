import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final MapController _mapController = MapController();
  double currentLat = -12.0686;
  double currentLng = -75.2100;
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
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(currentLat, currentLng),
                            initialZoom: 12.0,
                            minZoom: 3.0,
                            maxZoom: 18.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.bancoandino.fuerzaventas',
                            ),
                            PolygonLayer(
                              polygons: [
                                Polygon(
                                  points: _gpsService.geocercaAsesor
                                      .map((gp) => LatLng(gp.lat, gp.lng))
                                      .toList(),
                                  color: AppTheme.bcpCyan.withOpacity(0.12),
                                  borderColor: AppTheme.neonCyan.withOpacity(0.6),
                                  borderStrokeWidth: 2.5,
                                  isFilled: true,
                                ),
                              ],
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: [
                                    LatLng(currentLat, currentLng),
                                    ...rutaOptimizada
                                        .where((item) => item.latitud != null && item.longitud != null)
                                        .map((item) => LatLng(item.latitud, item.longitud))
                                        .toList(),
                                  ],
                                  color: AppTheme.neonOrange.withOpacity(0.85),
                                  strokeWidth: 3.5,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                // Advisor Marker
                                Marker(
                                  point: LatLng(currentLat, currentLng),
                                  width: 44,
                                  height: 44,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonCyan.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                      boxShadow: AppTheme.neonGlowShadow(color: AppTheme.neonCyan, opacity: 0.4, blurRadius: 10),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.navigation_rounded, color: AppTheme.neonCyan, size: 18),
                                    ),
                                  ),
                                ),
                                // Client Markers
                                ...List.generate(rutaOptimizada.length, (index) {
                                  final item = rutaOptimizada[index];
                                  final lat = item.latitud;
                                  final lng = item.longitud;
                                  if (lat == null || lng == null) return Marker(point: LatLng(0, 0), child: const SizedBox.shrink());
                                  return Marker(
                                    point: LatLng(lat, lng),
                                    width: 32,
                                    height: 32,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.neonOrange,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                        boxShadow: AppTheme.neonGlowShadow(color: AppTheme.neonOrange, opacity: 0.4, blurRadius: 8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).where((m) => m.point.latitude != 0.0).toList(),
                              ],
                            ),
                          ],
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
                                      currentLat = -12.0686;
                                      currentLng = -75.2100;
                                      _recalcularRuta();
                                    });
                                    _mapController.move(LatLng(currentLat, currentLng), 13.0);
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
                                      currentLat = -12.0847;
                                      currentLng = -77.0315;
                                      _recalcularRuta();
                                    });
                                    _mapController.move(LatLng(currentLat, currentLng), 9.0);
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

