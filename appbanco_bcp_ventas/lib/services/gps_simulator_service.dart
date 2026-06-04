import 'dart:math';

class GpsPoint {
  final double lat;
  final double lng;
  final String label;

  GpsPoint(this.lat, this.lng, [this.label = '']);
}

class GpsSimulatorService {
  static final GpsSimulatorService _instance = GpsSimulatorService._internal();
  factory GpsSimulatorService() => _instance;
  GpsSimulatorService._internal();

  // Ubicación inicial del asesor (BCP Lima - Sede Central o similar)
  GpsPoint ubicacionAsesor = GpsPoint(-12.0847, -77.0315, 'Sede Central BCP');

  // Polígono de la geocerca asignada al asesor (ej. San Isidro / Lince)
  final List<GpsPoint> geocercaAsesor = [
    GpsPoint(-12.0800, -77.0400),
    GpsPoint(-12.0800, -77.0200),
    GpsPoint(-12.0950, -77.0200),
    GpsPoint(-12.0950, -77.0400),
  ];

  // Actualizar la ubicación actual del asesor
  void actualizarUbicacionAsesor(double lat, double lng) {
    ubicacionAsesor = GpsPoint(lat, lng, 'Ubicación Actual');
  }

  // Algoritmo Ray Casting para validación de geocerca
  bool estaDentroDeGeocerca(double lat, double lng) {
    int i, j = geocercaAsesor.length - 1;
    bool dentro = false;

    for (i = 0; i < geocercaAsesor.length; i++) {
      if ((geocercaAsesor[i].lng < lng && geocercaAsesor[j].lng >= lng ||
              geocercaAsesor[j].lng < lng && geocercaAsesor[i].lng >= lng) &&
          (geocercaAsesor[i].lat +
                  (lng - geocercaAsesor[i].lng) /
                      (geocercaAsesor[j].lng - geocercaAsesor[i].lng) *
                      (geocercaAsesor[j].lat - geocercaAsesor[i].lat) <
              lat)) {
        dentro = !dentro;
      }
      j = i;
    }
    return dentro;
  }

  // Distancia haversine entre dos puntos en km
  double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371; // Radio de la Tierra en km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // Algoritmo Nearest Neighbor para optimizar ruta
  List<T> optimizarRuta<T>({
    required double latInicial,
    required double lngInicial,
    required List<T> items,
    required double? Function(T) getLat,
    required double? Function(T) getLng,
  }) {
    if (items.isEmpty) return [];

    final List<T> pendientes = List.from(items);
    final List<T> optimizado = [];

    double currentLat = latInicial;
    double currentLng = lngInicial;

    while (pendientes.isNotEmpty) {
      T? masCercano;
      double minD = double.infinity;
      int indexMasCercano = -1;

      for (int i = 0; i < pendientes.length; i++) {
        final item = pendientes[i];
        final lat = getLat(item);
        final lng = getLng(item);

        if (lat == null || lng == null) {
          // Si no tiene coordenadas, lo ponemos al final
          if (masCercano == null && minD == double.infinity) {
            indexMasCercano = i;
          }
          continue;
        }

        final d = calcularDistancia(currentLat, currentLng, lat, lng);
        if (d < minD) {
          minD = d;
          masCercano = item;
          indexMasCercano = i;
        }
      }

      if (indexMasCercano != -1) {
        final item = pendientes.removeAt(indexMasCercano);
        optimizado.add(item);
        final lat = getLat(item);
        final lng = getLng(item);
        if (lat != null && lng != null) {
          currentLat = lat;
          currentLng = lng;
        }
      } else {
        // Romper si hay algún error
        optimizado.addAll(pendientes);
        break;
      }
    }

    return optimizado;
  }
}
