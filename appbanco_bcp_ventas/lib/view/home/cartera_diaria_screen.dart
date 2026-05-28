import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/app_routes.dart';
import '../../ui/theme/app_theme.dart';
import '../../viewmodel/auth_oficial_viewmodel.dart';
import '../../viewmodel/cartera_viewmodel.dart';

class CarteraDiariaScreen extends StatefulWidget {
  const CarteraDiariaScreen({super.key});

  @override
  State<CarteraDiariaScreen> createState() => _CarteraDiariaScreenState();
}

class _CarteraDiariaScreenState extends State<CarteraDiariaScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final authViewModel = context.read<AuthOficialViewModel>();
      final carteraViewModel = context.read<CarteraViewModel>();

      if (authViewModel.oficial == null) {
        await authViewModel.cargarSesionActual();
      }

      final oficial = authViewModel.oficial;

      if (oficial != null) {
        await carteraViewModel.cargarCartera(oficial);
      }
    });
  }

  Future<void> cerrarSesion() async {
    final authViewModel = context.read<AuthOficialViewModel>();
    final carteraViewModel = context.read<CarteraViewModel>();

    await authViewModel.logout();
    carteraViewModel.limpiar();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Color estadoColor(String estado) {
    if (estado == 'Visitado') {
      return Colors.green;
    }

    if (estado == 'Reprogramado') {
      return Colors.blueAccent;
    }

    return AppTheme.bcpOrange;
  }

  IconData gestionIcono(String tipoGestion) {
    if (tipoGestion == 'Cobranza') {
      return Icons.payments;
    } else if (tipoGestion == 'Renovación') {
      return Icons.refresh;
    }

    return Icons.person_add;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CarteraViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_bcp.png',
              height: 28,
            ),
            const SizedBox(width: 8),
            const Text('Cartera diaria'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final authViewModel = context.read<AuthOficialViewModel>();
          final oficial = authViewModel.oficial;

          if (oficial != null) {
            await context.read<CarteraViewModel>().cargarCartera(oficial);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: viewModel.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : viewModel.error != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          viewModel.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${viewModel.nombreOficial}',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Clientes asignados para visitar hoy',
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _ResumenCard(
                                titulo: 'Total',
                                valor: viewModel.totalVisitas.toString(),
                                icono: Icons.groups,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ResumenCard(
                                titulo: 'Pendientes',
                                valor: viewModel.pendientes.toString(),
                                icono: Icons.schedule,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ResumenCard(
                                titulo: 'Visitados',
                                valor: viewModel.visitados.toString(),
                                icono: Icons.check_circle,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Lista de clientes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Expanded(
                          child: viewModel.clientes.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay clientes asignados para hoy.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: viewModel.clientes.length,
                                  itemBuilder: (context, index) {
                                    final cliente = viewModel.clientes[index];

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppTheme.bcpOrange,
                                          child: Icon(
                                            gestionIcono(cliente.tipoGestion),
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          cliente.nombre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          cliente.tipoGestion,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: estadoColor(cliente.estado).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        cliente.estado,
        style: TextStyle(
          color: estadoColor(cliente.estado),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    const SizedBox(width: 8),
    const Icon(
      Icons.arrow_forward_ios,
      color: Colors.white54,
      size: 16,
    ),
  ],
),
onTap: () {
  Navigator.pushNamed(
    context,
    AppRoutes.detalleCliente,
    arguments: cliente,
  );
},


                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const _ResumenCard({
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 10,
        ),
        child: Column(
          children: [
            Icon(
              icono,
              color: AppTheme.bcpOrange,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}