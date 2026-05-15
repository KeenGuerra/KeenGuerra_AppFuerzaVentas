import 'package:flutter/material.dart';
import 'navigation/app_routes.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const BcpVentasApp());
}

class BcpVentasApp extends StatelessWidget {
  const BcpVentasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BCP Fuerza de Ventas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}