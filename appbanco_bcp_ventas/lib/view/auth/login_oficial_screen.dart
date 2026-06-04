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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // Logo BCP Premium
                  Container(
                    width: 140,
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo_bcp.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Fuerza de Ventas BCP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Ingresa para gestionar tu cartera diaria',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tarjeta de Login Glassmorphic
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: codigoController,
                          enabled: !estaBloqueado,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Código de empleado',
                            helperText: 'Ejemplo: OFI001',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: AppTheme.bcpOrange,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          enabled: !estaBloqueado,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppTheme.bcpOrange,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (estaBloqueado)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Bloqueado por seguridad.\nReintenta en $_segundosBloqueo segundos.',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (viewModel.error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    viewModel.error!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (viewModel.loading || estaBloqueado) ? null : ingresar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.bcpOrange,
                              shadowColor: AppTheme.bcpOrange.withOpacity(0.4),
                              elevation: 4,
                            ),
                            child: viewModel.loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Ingresar al Portal',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: const Text(
                      'Acceso seguro encriptado.\n'
                      'Credenciales de prueba: ofi001 y contraseña de Supabase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}