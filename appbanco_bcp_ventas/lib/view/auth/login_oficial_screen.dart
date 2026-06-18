import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../navigation/app_routes.dart';
import '../../ui/theme/app_theme.dart';
import '../../viewmodel/auth_oficial_viewmodel.dart';

class LoginOficialScreen extends StatefulWidget {
  const LoginOficialScreen({super.key});

  @override
  State<LoginOficialScreen> createState() => _LoginOficialScreenState();
}

class _LoginOficialScreenState extends State<LoginOficialScreen> {
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int _intentosFallidos = 0;
  int _segundosBloqueo = 0;
  Timer? _timer;

  void _iniciarBloqueo() {
    setState(() {
      _segundosBloqueo = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosBloqueo == 1) {
        timer.cancel();
        setState(() {
          _segundosBloqueo = 0;
          _intentosFallidos = 0;
        });
      } else {
        setState(() {
          _segundosBloqueo--;
        });
      }
    });
  }

  void ingresar() async {
    if (_segundosBloqueo > 0) return;

    final viewModel = context.read<AuthOficialViewModel>();

    await viewModel.login(
      codigoController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (viewModel.success) {
      _intentosFallidos = 0;
      Navigator.pushReplacementNamed(context, AppRoutes.cartera);
    } else {
      setState(() {
        _intentosFallidos++;
        if (_intentosFallidos >= 3) {
          _iniciarBloqueo();
        }
      });
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthOficialViewModel>();
    final estaBloqueado = _segundosBloqueo > 0;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo gradiente oficial
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.bcpGradient,
              ),
            ),
          ),
          
          // Pintor de curvas de luz geométrica para el fondo premium
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animación de entrada para el Logo BCP
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, val, child) {
                        return Transform.scale(
                          scale: val,
                          child: Opacity(
                            opacity: val,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 150,
                        height: 90,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.bcpCyan.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo_bcp.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Animación de entrada para los Textos del Encabezado
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, val, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - val)),
                          child: Opacity(
                            opacity: val,
                            child: child,
                          ),
                        );
                      },
                      child: const Column(
                        children: [
                          Text(
                            'Portal Fuerza de Ventas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Ingresa tus credenciales oficiales de campo BCP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Animación de entrada para la Tarjeta de Login Glassmorphic
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1200),
                      builder: (context, val, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - val)),
                          child: Opacity(
                            opacity: val,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: AppTheme.glassDecoration(
                          color: AppTheme.cardDark,
                          opacity: 0.82,
                          borderRadius: 30,
                          borderColor: AppTheme.bcpCyan,
                          borderOpacity: 0.12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Inicio de Sesión',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Campo de Código
                            TextField(
                              controller: codigoController,
                              enabled: !estaBloqueado,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                labelText: 'Código de empleado',
                                helperText: 'Formato requerido: OFI001',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.bcpOrange.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.badge_outlined,
                                      color: AppTheme.neonOrange,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Campo de Contraseña
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              enabled: !estaBloqueado,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.bcpOrange.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppTheme.neonOrange,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Mensajes de Alerta y Bloqueo con estilo de cristal
                            if (estaBloqueado)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonRed.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.neonRed.withOpacity(0.4), width: 1.2),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.security_rounded, color: AppTheme.neonRed, size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Acceso bloqueado temporalmente.\nIntenta de nuevo en $_segundosBloqueo segundos.',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (viewModel.error != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonOrange.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.neonOrange.withOpacity(0.4), width: 1.2),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: AppTheme.neonOrange, size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        viewModel.error!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 28),

                            // Botón de Ingreso con Gradiente Premium y sombra neón
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.bcpOrangeGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppTheme.neonGlowShadow(
                                    color: AppTheme.bcpOrange,
                                    opacity: (viewModel.loading || estaBloqueado) ? 0.0 : 0.35,
                                    blurRadius: 18,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: (viewModel.loading || estaBloqueado) ? null : ingresar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                    elevation: 0,
                                  ),
                                  child: viewModel.loading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'INGRESAR AL PORTAL',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Botón para acceder al Portal de Clientes
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.clientPortal);
                        },
                        icon: const Icon(Icons.phonelink_ring_rounded, color: AppTheme.neonCyan, size: 20),
                        label: const Text(
                          'SIMULAR PORTAL DE CLIENTES',
                          style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.bcpCyan, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pie de página elegante informativo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: AppTheme.glassDecoration(
                        color: Colors.white,
                        opacity: 0.03,
                        borderRadius: 20,
                        borderColor: Colors.white,
                        borderOpacity: 0.04,
                      ),
                      child: const Text(
                        'Acceso oficial restringido. Conexión protegida SSL de extremo a extremo.\n'
                        'Pruebas: Empleado [ofi001], Contraseña de Supabase.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white38,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor de fondo geométrico tecnológico
class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Curva superior izquierda
    paint.color = AppTheme.bcpCyan.withOpacity(0.08);
    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.25,
      size.width * 0.6,
      0,
    );
    canvas.drawPath(path1, paint);

    // Curva superior izquierda alternativa
    paint.color = AppTheme.bcpOrange.withOpacity(0.05);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.4);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.3,
      size.width * 0.7,
      0,
    );
    canvas.drawPath(path2, paint);

    // Círculo decorativo en esquina inferior derecha
    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.bcpBlue.withOpacity(0.12);
    canvas.drawCircle(Offset(size.width * 1.1, size.height * 0.8), size.width * 0.4, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.bcpCyan.withOpacity(0.06);
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(size.width * 1.1, size.height * 0.8), size.width * 0.42, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}