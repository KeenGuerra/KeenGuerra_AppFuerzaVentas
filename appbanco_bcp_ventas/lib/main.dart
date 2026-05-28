import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'navigation/app_routes.dart';
import 'ui/theme/app_theme.dart';
import 'viewmodel/auth_oficial_viewmodel.dart';
import 'viewmodel/cartera_viewmodel.dart';
import 'viewmodel/cliente_viewmodel.dart';
import 'viewmodel/solicitud_viewmodel.dart';
import 'viewmodel/documento_viewmodel.dart';
import 'viewmodel/buro_credito_viewmodel.dart';
import 'viewmodel/transmision_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SupabaseConfig.validate();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const BcpVentasApp());
}

class BcpVentasApp extends StatelessWidget {
  const BcpVentasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthOficialViewModel()),
        ChangeNotifierProvider(create: (_) => CarteraViewModel()),
        ChangeNotifierProvider(create: (_) => ClienteViewModel()),
        ChangeNotifierProvider(create: (_) => SolicitudViewModel()),
        ChangeNotifierProvider(create: (_) => DocumentoViewModel()),
        ChangeNotifierProvider(create: (_) => BuroCreditoViewModel()),
        ChangeNotifierProvider(create: (_) => TransmisionViewModel()),
      ],
      child: MaterialApp(
        title: 'BCP Fuerza de Ventas',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: session == null ? AppRoutes.login : AppRoutes.cartera,
        routes: AppRoutes.routes,
      ),
    );
  }
}