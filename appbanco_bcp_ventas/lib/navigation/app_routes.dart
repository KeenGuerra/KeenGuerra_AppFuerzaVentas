import 'package:flutter/material.dart';

import '../view/auth/login_oficial_screen.dart';
import '../view/home/cartera_diaria_screen.dart';
import '../view/cliente/detalle_cliente_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String cartera = '/cartera';
  static const String detalleCliente = '/detalle-cliente';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginOficialScreen(),
    cartera: (context) => const CarteraDiariaScreen(),
    detalleCliente: (context) => const DetalleClienteScreen(),
  };
}