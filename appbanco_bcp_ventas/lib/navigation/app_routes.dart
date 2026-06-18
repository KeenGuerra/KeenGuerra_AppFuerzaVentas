import 'package:flutter/material.dart';

import '../view/auth/login_oficial_screen.dart';
import '../view/auth/client_portal_screen.dart';
import '../view/home/cartera_diaria_screen.dart';
import '../view/cliente/detalle_cliente_screen.dart';
import '../view/ruta/optimizacion_ruta_screen.dart';
import '../view/prospeccion/prospeccion_screen.dart';
import '../view/solicitudes/nueva_solicitud_screen.dart';
import '../view/solicitudes/decision_desembolso_screen.dart';
import '../view/documentos/captura_documentos_screen.dart';
import '../view/buro/consulta_buro_screen.dart';
import '../view/transmision/transmision_screen.dart';
import '../view/estados/estados_solicitudes_screen.dart';
import '../view/cobranza/cobranza_screen.dart';
import '../view/supervision/supervision_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String clientPortal = '/client-portal';
  static const String cartera = '/cartera';
  static const String detalleCliente = '/detalle-cliente';
  static const String optimizacionRuta = '/optimizacion-ruta';
  static const String prospeccion = '/prospeccion';
  static const String nuevaSolicitud = '/nueva-solicitud';
  static const String decisionDesembolso = '/decision-desembolso';
  static const String capturaDocumentos = '/captura-documentos';
  static const String consultaBuro = '/consulta-buro';
  static const String transmision = '/transmision';
  static const String estadosSolicitudes = '/estados-solicitudes';
  static const String cobranza = '/cobranza';
  static const String supervision = '/supervision';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginOficialScreen(),
    clientPortal: (context) => const ClientPortalScreen(),
    cartera: (context) => const CarteraDiariaScreen(),
    detalleCliente: (context) => const DetalleClienteScreen(),
    optimizacionRuta: (context) => const OptimizacionRutaScreen(),
    prospeccion: (context) => const ProspeccionScreen(),
    nuevaSolicitud: (context) => const NuevaSolicitudScreen(),
    decisionDesembolso: (context) => const DecisionDesembolsoScreen(),
    capturaDocumentos: (context) => const CapturaDocumentosScreen(),
    consultaBuro: (context) => const ConsultaBuroScreen(),
    transmision: (context) => const TransmisionScreen(),
    estadosSolicitudes: (context) => const EstadosSolicitudesScreen(),
    cobranza: (context) => const CobranzaScreen(),
    supervision: (context) => const SupervisionScreen(),
  };
}