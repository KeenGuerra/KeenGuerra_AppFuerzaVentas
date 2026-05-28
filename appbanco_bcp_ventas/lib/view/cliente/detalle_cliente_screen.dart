import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/cliente_cartera_model.dart';
import '../../ui/theme/app_theme.dart';
import '../../viewmodel/cliente_viewmodel.dart';
import '../../viewmodel/cartera_viewmodel.dart';

class DetalleClienteScreen extends StatefulWidget {
  const DetalleClienteScreen({super.key});

  @override
  State<DetalleClienteScreen> createState() => _DetalleClienteScreenState();
}

class _DetalleClienteScreenState extends State<DetalleClienteScreen> {
  ClienteCarteraModel? clienteCartera;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is ClienteCarteraModel && clienteCartera == null) {
      clienteCartera = args;

      Future.microtask(() {
        context
            .read<ClienteViewModel>()
            .cargarFichaCliente(args.idCliente);
      });
    }
  }

  Future<void> marcarComoVisitado() async {
    if (clienteCartera == null) return;

    await context.read<CarteraViewModel>().actualizarEstadoGestion(
          idCartera: clienteCartera!.idCartera,
          nuevoEstado: 'Visitado',
          observacion: 'Cliente visitado desde la ficha del cliente.',
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gestión actualizada como visitada.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClienteViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Ficha del cliente'),
      ),
      body: viewModel.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : viewModel.error != null
              ? Center(
                  child: Text(
                    viewModel.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : viewModel.cliente == null
                  ? const Center(
                      child: Text(
                        'No se encontró información del cliente.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CabeceraCliente(
                            nombre: viewModel.cliente!.nombreCompleto,
                            dni: viewModel.cliente!.dni,
                            estado: viewModel.cliente!.estado,
                          ),

                          const SizedBox(height: 18),

                          _SeccionCard(
                            titulo: 'Información general',
                            icono: Icons.person,
                            children: [
                              _DatoItem(
                                titulo: 'Teléfono',
                                valor: viewModel.cliente!.telefono ??
                                    'No registrado',
                              ),
                              _DatoItem(
                                titulo: 'Dirección',
                                valor: viewModel.cliente!.direccion ??
                                    'No registrada',
                              ),
                              _DatoItem(
                                titulo: 'Negocio',
                                valor: viewModel.cliente!.negocio ??
                                    'No registrado',
                              ),
                              _DatoItem(
                                titulo: 'Actividad económica',
                                valor: viewModel.cliente!.actividadEconomica ??
                                    'No registrada',
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          _SeccionCard(
                            titulo: 'Gestión de cartera',
                            icono: Icons.assignment,
                            children: [
                              _DatoItem(
                                titulo: 'Tipo de gestión',
                                valor:
                                    clienteCartera?.tipoGestion ?? 'Sin dato',
                              ),
                              _DatoItem(
                                titulo: 'Estado actual',
                                valor: clienteCartera?.estado ?? 'Sin dato',
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: marcarComoVisitado,
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Marcar como visitado'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          _SeccionCard(
                            titulo: 'Productos activos',
                            icono: Icons.credit_card,
                            children: viewModel.productosActivos.isEmpty
                                ? const [
                                    Text(
                                      'No hay productos activos registrados.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ]
                                : viewModel.productosActivos.map((producto) {
                                    return _DatoItem(
                                      titulo:
                                          producto['producto']?.toString() ??
                                              'Producto',
                                      valor:
                                          'Saldo: S/ ${producto['saldo'] ?? '0.00'}',
                                    );
                                  }).toList(),
                          ),

                          const SizedBox(height: 14),

                          _SeccionCard(
                            titulo: 'Historial crediticio',
                            icono: Icons.history,
                            children: viewModel.historialCrediticio.isEmpty
                                ? const [
                                    Text(
                                      'No hay historial crediticio registrado.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ]
                                : viewModel.historialCrediticio.map((item) {
                                    return _DatoItem(
                                      titulo:
                                          item['producto']?.toString() ??
                                              'Crédito',
                                      valor:
                                          'Monto: S/ ${item['monto']} | Estado: ${item['estado']}',
                                    );
                                  }).toList(),
                          ),

                          const SizedBox(height: 18),

                          _AccionesCliente(
                            clienteId: viewModel.cliente!.id,
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class _CabeceraCliente extends StatelessWidget {
  final String nombre;
  final String dni;
  final String estado;

  const _CabeceraCliente({
    required this.nombre,
    required this.dni,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.bcpOrange,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DNI: $dni',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      estado,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> children;

  const _SeccionCard({
    required this.titulo,
    required this.icono,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: AppTheme.bcpOrange),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DatoItem extends StatelessWidget {
  final String titulo;
  final String valor;

  const _DatoItem({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccionesCliente extends StatelessWidget {
  final String clienteId;

  const _AccionesCliente({
    required this.clienteId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccionButton(
          icono: Icons.request_page,
          texto: 'Nueva solicitud de crédito',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pantalla de solicitud pendiente de conectar.'),
              ),
            );
          },
        ),
        _AccionButton(
          icono: Icons.folder,
          texto: 'Capturar documentos',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pantalla de documentos pendiente de conectar.'),
              ),
            );
          },
        ),
        _AccionButton(
          icono: Icons.search,
          texto: 'Consultar buró',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Consulta de buró pendiente de conectar.'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AccionButton extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _AccionButton({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icono,
          color: AppTheme.bcpOrange,
        ),
        title: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
      ),
    );
  }
}