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
  String searchPattern = '';
  String filterEstado = 'Todos';
  String filterGestion = 'Todos';

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
      return Colors.greenAccent;
    }
    if (estado == 'Reprogramado') {
      return AppTheme.bcpCyan;
    }
    return AppTheme.bcpOrange;
  }

  Color prioridadColor(int prioridad) {
    if (prioridad >= 3) return Colors.redAccent;
    if (prioridad == 2) return Colors.amberAccent;
    return Colors.greenAccent;
  }

  String prioridadTexto(int prioridad) {
    if (prioridad >= 3) return 'ALTA';
    if (prioridad == 2) return 'MEDIA';
    return 'BAJA';
  }

  IconData gestionIcono(String tipoGestion) {
    if (tipoGestion == 'Cobranza') {
      return Icons.payments_outlined;
    } else if (tipoGestion == 'Renovación') {
      return Icons.autorenew_outlined;
    }
    return Icons.person_add_alt_1_outlined;
  }

  void _simularSincronizacionNocturna() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulando sincronización nocturna de cartera...'),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cartera actualizada con éxito desde servidor central.'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CarteraViewModel>();
    final authViewModel = context.watch<AuthOficialViewModel>();
    final oficial = authViewModel.oficial;
    final cargo = oficial?.cargo?.toUpperCase() ?? 'OPERADOR';

    // Filtrado local de clientes
    final filteredClientes = viewModel.clientes.where((cliente) {
      final matchesSearch = cliente.nombre.toLowerCase().contains(searchPattern.toLowerCase()) ||
          cliente.idCliente.contains(searchPattern);
      final matchesEstado = filterEstado == 'Todos' || cliente.estado == filterEstado;
      final matchesGestion = filterGestion == 'Todos' || cliente.tipoGestion == filterGestion;
      return matchesSearch && matchesEstado && matchesGestion;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.bcpBlue,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_bcp.png',
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text('Fuerza de Ventas'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _simularSincronizacionNocturna,
            icon: const Icon(Icons.sync_outlined),
            tooltip: 'Sincronizar Cartera',
          ),
          IconButton(
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: AppTheme.darkBackground,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.bcpBlue, AppTheme.cardDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.bcpOrange, width: 2.5),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: AppTheme.cardDark,
                    child: Icon(Icons.person_outline, color: Colors.white, size: 36),
                  ),
                ),
                accountName: Text(
                  oficial?.nombreCompleto ?? 'Asesor BCP',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                ),
                accountEmail: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.bcpOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cargo,
                    style: const TextStyle(color: AppTheme.bcpOrange, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.group_outlined,
                      title: 'Cartera Diaria',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      icon: Icons.directions_outlined,
                      title: 'Optimización de Ruta GPS',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.optimizacionRuta);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.person_add_alt_outlined,
                      title: 'Módulo de Prospección',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.prospeccion);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.request_page_outlined,
                      title: 'Estados de Solicitudes',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.estadosSolicitudes);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.payments_outlined,
                      title: 'Módulo de Cobranza',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.cobranza);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.cloud_upload_outlined,
                      title: 'Transmisión y Sincronización',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.transmision);
                      },
                    ),

                    // Módulo de Supervisión
                    if (cargo == 'SUPERVISOR' || cargo == 'ADMINISTRADOR' || cargo == 'SUPER OPERADOR') ...[
                      const Divider(color: Colors.white12, height: 24),
                      _buildDrawerItem(
                        icon: Icons.analytics_outlined,
                        title: 'Consola de Supervisión',
                        textColor: Colors.greenAccent,
                        iconColor: Colors.greenAccent,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.supervision);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Fuerza de Ventas v1.4 Offline-First',
                  style: TextStyle(color: Colors.white30, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            if (oficial != null) {
              await context.read<CarteraViewModel>().cargarCartera(oficial);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: viewModel.loading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.error != null
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          const Icon(
                            Icons.error_outline_sharp,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            viewModel.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Hola, ${viewModel.nombreOficial}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gestión de Microfinanzas en Campo BCP',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 20),

                          // Tarjetas de Resumen
                          Row(
                            children: [
                              Expanded(
                                child: _ResumenCard(
                                  titulo: 'Total',
                                  valor: viewModel.totalVisitas.toString(),
                                  icono: Icons.groups_outlined,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ResumenCard(
                                  titulo: 'Pendientes',
                                  valor: viewModel.pendientes.toString(),
                                  icono: Icons.schedule_outlined,
                                  highlightColor: AppTheme.bcpOrange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ResumenCard(
                                  titulo: 'Visitados',
                                  valor: viewModel.visitados.toString(),
                                  icono: Icons.check_circle_outline,
                                  highlightColor: Colors.greenAccent,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Barra de Búsqueda
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Buscar por nombre o DNI...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.search_outlined, color: AppTheme.bcpOrange),
                            ),
                            onChanged: (val) {
                              setState(() {
                                searchPattern = val;
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          // Filtros rápidos
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('Todos', isEstado: true),
                                const SizedBox(width: 6),
                                _buildFilterChip('Pendiente', isEstado: true),
                                const SizedBox(width: 6),
                                _buildFilterChip('Visitado', isEstado: true),
                                const SizedBox(width: 12),
                                Container(width: 1.5, height: 22, color: Colors.white24),
                                const SizedBox(width: 12),
                                _buildFilterChip('Todos', isEstado: false),
                                const SizedBox(width: 6),
                                _buildFilterChip('Cobranza', isEstado: false),
                                const SizedBox(width: 6),
                                _buildFilterChip('Renovación', isEstado: false),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Lista de Clientes
                          Expanded(
                            child: filteredClientes.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No se encontraron clientes para hoy.',
                                      style: TextStyle(color: Colors.white38),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filteredClientes.length,
                                    padding: const EdgeInsets.only(bottom: 16),
                                    itemBuilder: (context, index) {
                                      final cliente = filteredClientes[index];

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.cardDark.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.05),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.15),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.detalleCliente,
                                              arguments: cliente,
                                            );
                                          },
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                          leading: CircleAvatar(
                                            backgroundColor: AppTheme.bcpBlue.withOpacity(0.4),
                                            radius: 22,
                                            child: Icon(
                                              gestionIcono(cliente.tipoGestion),
                                              color: AppTheme.bcpCyan,
                                              size: 24,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  cliente.nombre,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: prioridadColor(cliente.prioridad).withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: prioridadColor(cliente.prioridad).withOpacity(0.4),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  prioridadTexto(cliente.prioridad),
                                                  style: TextStyle(
                                                    color: prioridadColor(cliente.prioridad),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 9,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              '${cliente.tipoGestion} • DNI ${cliente.idCliente.length > 8 ? cliente.idCliente.substring(0, 8) : cliente.idCliente}',
                                              style: const TextStyle(color: Colors.white60, fontSize: 13),
                                            ),
                                          ),
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: estadoColor(cliente.estado).withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: estadoColor(cliente.estado).withOpacity(0.4),
                                                width: 1.2,
                                              ),
                                            ),
                                            child: Text(
                                              cliente.estado,
                                              style: TextStyle(
                                                color: estadoColor(cliente.estado),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.bcpCyan, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildFilterChip(String label, {required bool isEstado}) {
    final active = isEstado ? (filterEstado == label) : (filterGestion == label);

    return FilterChip(
      selected: active,
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      selectedColor: AppTheme.bcpOrange,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: active ? Colors.white : Colors.white70),
      backgroundColor: AppTheme.cardDark.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: BorderSide(
        color: active ? AppTheme.bcpOrange : Colors.white10,
        width: 1.2,
      ),
      onSelected: (selected) {
        setState(() {
          if (isEstado) {
            filterEstado = label;
          } else {
            filterGestion = label;
          }
        });
      },
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color? highlightColor;

  const _ResumenCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(
              icono,
              color: highlightColor ?? AppTheme.bcpCyan,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}