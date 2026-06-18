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
      return AppTheme.neonGreen;
    }
    if (estado == 'Reprogramado') {
      return AppTheme.neonCyan;
    }
    return AppTheme.neonOrange;
  }

  Color prioridadColor(int prioridad) {
    if (prioridad >= 3) return AppTheme.neonRed;
    if (prioridad == 2) return AppTheme.neonOrange;
    return AppTheme.neonGreen;
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
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cartera sincronizada con el servidor central BCP.'),
          backgroundColor: AppTheme.neonGreen,
          behavior: SnackBarBehavior.floating,
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
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_bcp.png',
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            const Text(
              'Fuerza de Ventas BCP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _simularSincronizacionNocturna,
            icon: const Icon(Icons.sync_outlined, color: AppTheme.bcpCyan),
            tooltip: 'Sincronizar Cartera',
          ),
          IconButton(
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout_outlined, color: AppTheme.neonRed),
            tooltip: 'Cerrar sesión',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        elevation: 16,
        child: Container(
          color: AppTheme.darkBackground,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.bcpBlue, AppTheme.darkBackground],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.neonGlowShadow(color: AppTheme.bcpCyan, opacity: 0.25, blurRadius: 10),
                    border: Border.all(color: AppTheme.bcpCyan, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: AppTheme.cardDark,
                    child: Icon(Icons.person_pin_rounded, color: Colors.white, size: 42),
                  ),
                ),
                accountName: Text(
                  oficial?.nombreCompleto ?? 'Asesor de Negocios',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                ),
                accountEmail: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.bcpOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.bcpOrange.withOpacity(0.3)),
                    ),
                    child: Text(
                      cargo,
                      style: const TextStyle(
                        color: AppTheme.neonOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.group_outlined,
                        title: 'Cartera Diaria',
                        active: true,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 4),
                      _buildDrawerItem(
                        icon: Icons.directions_outlined,
                        title: 'Optimización de Ruta GPS',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.optimizacionRuta);
                        },
                      ),
                      const SizedBox(height: 4),
                      _buildDrawerItem(
                        icon: Icons.person_add_alt_outlined,
                        title: 'Módulo de Prospección',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.prospeccion);
                        },
                      ),
                      const SizedBox(height: 4),
                      _buildDrawerItem(
                        icon: Icons.request_page_outlined,
                        title: 'Estados de Solicitudes',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.estadosSolicitudes);
                        },
                      ),
                      const SizedBox(height: 4),
                      _buildDrawerItem(
                        icon: Icons.payments_outlined,
                        title: 'Módulo de Cobranza',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.cobranza);
                        },
                      ),
                      const SizedBox(height: 4),
                      _buildDrawerItem(
                        icon: Icons.cloud_upload_outlined,
                        title: 'Transmisión y Sincronización',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.transmision);
                        },
                      ),
                      if (cargo == 'SUPERVISOR' || cargo == 'ADMINISTRADOR' || cargo == 'SUPER OPERADOR') ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Colors.white10, height: 1),
                        ),
                        _buildDrawerItem(
                          icon: Icons.analytics_outlined,
                          title: 'Consola de Supervisión',
                          textColor: AppTheme.neonGreen,
                          iconColor: AppTheme.neonGreen,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.supervision);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Fuerza de Ventas BCP v1.4\nSistema de Campo Cifrado',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 10, height: 1.4),
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
          color: AppTheme.bcpOrange,
          backgroundColor: AppTheme.cardDark,
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
                          const SizedBox(height: 100),
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppTheme.neonRed,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hola, ${viewModel.nombreOficial}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Gestión de Microfinanzas en Campo',
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.neonGreen,
                                  boxShadow: [
                                    BoxShadow(color: AppTheme.neonGreen, blurRadius: 6),
                                  ],
                                ),
                              ),
                            ],
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
                                  color: AppTheme.bcpBlue,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0F2B5C), Color(0xFF07193B)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ResumenCard(
                                  titulo: 'Pendientes',
                                  valor: viewModel.pendientes.toString(),
                                  icono: Icons.schedule_outlined,
                                  color: AppTheme.bcpOrange,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF5C2C0F), Color(0xFF3B1907)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  highlightColor: AppTheme.neonOrange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ResumenCard(
                                  titulo: 'Visitados',
                                  valor: viewModel.visitados.toString(),
                                  icono: Icons.check_circle_outline,
                                  color: AppTheme.neonGreen,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0F5C2C), Color(0xFF073B19)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  highlightColor: AppTheme.neonGreen,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Barra de Búsqueda
                          Container(
                            decoration: AppTheme.glassDecoration(
                              color: AppTheme.cardDark,
                              opacity: 0.4,
                              borderRadius: 20,
                              borderColor: Colors.white,
                              borderOpacity: 0.05,
                            ),
                            child: TextField(
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Buscar cliente o DNI...',
                                hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                prefixIcon: const Icon(Icons.search_outlined, color: AppTheme.bcpCyan),
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: AppTheme.bcpCyan, width: 1.5),
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  searchPattern = val;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Filtros rápidos horizontales
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
                                Container(width: 1.5, height: 20, color: Colors.white12),
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
                                      'No hay clientes registrados con esos filtros.',
                                      style: TextStyle(color: Colors.white30, fontSize: 14),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filteredClientes.length,
                                    padding: const EdgeInsets.only(bottom: 16),
                                    itemBuilder: (context, index) {
                                      final cliente = filteredClientes[index];

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: AppTheme.glassDecoration(
                                          color: AppTheme.cardDark,
                                          opacity: 0.85,
                                          borderRadius: 22,
                                          borderColor: prioridadColor(cliente.prioridad),
                                          borderOpacity: 0.12,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(22),
                                          child: Stack(
                                            children: [
                                              // Barra lateral de prioridad
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                bottom: 0,
                                                width: 5,
                                                child: Container(
                                                  color: prioridadColor(cliente.prioridad),
                                                ),
                                              ),
                                              ListTile(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    AppRoutes.detalleCliente,
                                                    arguments: cliente,
                                                  );
                                                },
                                                contentPadding: const EdgeInsets.only(left: 20, right: 16, top: 10, bottom: 10),
                                                leading: Container(
                                                  width: 44,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.bcpBlue.withOpacity(0.12),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: AppTheme.bcpCyan.withOpacity(0.2), width: 1.5),
                                                  ),
                                                  child: Icon(
                                                    gestionIcono(cliente.tipoGestion),
                                                    color: AppTheme.bcpCyan,
                                                    size: 20,
                                                  ),
                                                ),
                                                title: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        cliente.nombre,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
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
                                                        color: prioridadColor(cliente.prioridad).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(
                                                          color: prioridadColor(cliente.prioridad).withOpacity(0.3),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        prioridadTexto(cliente.prioridad),
                                                        style: TextStyle(
                                                          color: prioridadColor(cliente.prioridad),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 9,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                subtitle: Padding(
                                                  padding: const EdgeInsets.only(top: 6.0),
                                                  child: Text(
                                                    '${cliente.tipoGestion} • DNI ${cliente.idCliente}',
                                                    style: const TextStyle(color: Colors.white54, fontSize: 12.5),
                                                  ),
                                                ),
                                                trailing: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: estadoColor(cliente.estado).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                                                      color: estadoColor(cliente.estado).withOpacity(0.3),
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
                                            ],
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
    bool active = false,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: active ? AppTheme.bcpBlue.withOpacity(0.25) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: active ? Border.all(color: AppTheme.bcpCyan.withOpacity(0.2), width: 1.2) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon, 
          color: active ? AppTheme.bcpCyan : (iconColor ?? Colors.white60), 
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : (textColor ?? Colors.white70),
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isEstado}) {
    final active = isEstado ? (filterEstado == label) : (filterGestion == label);

    return FilterChip(
      selected: active,
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      selectedColor: AppTheme.bcpOrange,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: active ? Colors.white : Colors.white60),
      backgroundColor: AppTheme.cardDark.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
  final Color color;
  final Gradient gradient;
  final Color? highlightColor;

  const _ResumenCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    required this.gradient,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (highlightColor ?? AppTheme.bcpCyan).withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: highlightColor ?? AppTheme.bcpCyan,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}