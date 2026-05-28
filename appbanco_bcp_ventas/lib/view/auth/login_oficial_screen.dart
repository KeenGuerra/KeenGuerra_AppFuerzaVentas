import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  void ingresar() async {
    final viewModel = context.read<AuthOficialViewModel>();

    await viewModel.login(
      codigoController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (viewModel.success) {
      Navigator.pushReplacementNamed(context, AppRoutes.cartera);
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthOficialViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 12,
              color: AppTheme.cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 150,
                      height: 90,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Image.asset(
                        'assets/images/logo_bcp.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Portal Oficial de Crédito',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Banco de Crédito del Perú',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      controller: codigoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Código de empleado',
                        helperText: 'Ejemplo: OFI001',
                        helperStyle: const TextStyle(color: Colors.white38),
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.badge,
                          color: AppTheme.bcpOrange,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTheme.bcpOrange,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: AppTheme.bcpOrange,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppTheme.bcpOrange,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (viewModel.error != null)
                      Text(
                        viewModel.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.loading ? null : ingresar,
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
                                'Ingresar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'El acceso ahora se valida con Supabase Auth.\n'
                        'Crea el usuario Auth como: ofi001@fuerzaventas.local',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}