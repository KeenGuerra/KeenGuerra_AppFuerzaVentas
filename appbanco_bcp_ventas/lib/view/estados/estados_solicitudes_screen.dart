import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class EstadosSolicitudesScreen extends StatefulWidget {
  const EstadosSolicitudesScreen({super.key});

  @override
  State<EstadosSolicitudesScreen> createState() => _EstadosSolicitudesScreenState();
}

class _EstadosSolicitudesScreenState extends State<EstadosSolicitudesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> solicitudesSimuladas = [
    {
      'id': 'SOL001',
      'cliente': 'Jorge Luis Bazán',
      'monto': 15000,
      'estado': 'Evaluación',
      'fecha': '04/06/2026',
      'timeline': [
        {'fecha': '04/06 09:00', 'desc': 'Solicitud registrada por Asesor'},
        {'fecha': '04/06 11:30', 'desc': 'Score SBS Evaluado: 710 (Bajo Riesgo)'},
        {'fecha': '04/06 14:00', 'desc': 'Asignado a Analista de Riesgos'},
      ]
    },
    {
      'id': 'SOL002',
      'cliente': 'María Elena Flores',
      'monto': 8000,
      'estado': 'Comité',
      'fecha': '03/06/2026',
      'timeline': [
        {'fecha': '03/06 10:15', 'desc': 'Solicitud registrada'},
        {'fecha': '03/06 12:00', 'desc': 'Documentación validada al 100%'},
        {'fecha': '04/06 09:30', 'desc': 'Elevado a Comité Zonal para aprobación'},
      ]
    },
    {
      'id': 'SOL003',
      'cliente': 'Carlos Alberto Ruiz',
      'monto': 12000,
      'estado': 'Aprobada',
      'fecha': '02/06/2026',
      'timeline': [
        {'fecha': '02/06 08:30', 'desc': 'Solicitud registrada'},
        {'fecha': '02/06 15:45', 'desc': 'Aprobación automática de riesgo'},
        {'fecha': '03/06 11:00', 'desc': 'Aprobación final por Comité de Crédito'},
      ]
    },
    {
      'id': 'SOL004',
      'cliente': 'Roberto Gómez',
      'monto': 20000,
      'estado': 'Registrada',
      'fecha': '04/06/2026',
      'timeline': [
        {'fecha': '04/06 15:30', 'desc': 'Solicitud registrada en Borrador Sincronizado'},
      ]
    },
  ];

  Map<String, dynamic>? selectedSolicitud;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (solicitudesSimuladas.isNotEmpty) {
      selectedSolicitud = solicitudesSimuladas.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Estados de Solicitud'),
        backgroundColor: AppTheme.bcpBlue,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.bcpOrange,
          labelColor: AppTheme.bcpOrange,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Tablero Kanban'),
            Tab(icon: Icon(Icons.timeline_outlined), text: 'Timeline Historial'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildKanbanTab(),
            _buildTimelineTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanTab() {
    final estados = ['Registrada', 'Evaluación', 'Comité', 'Aprobada'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: estados.map((estado) {
          final filtrados = solicitudesSimuladas.where((s) => s['estado'] == estado).toList();

          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withOpacity(0.9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabecera columna
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      estado,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.bcpOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filtrados.length}',
                        style: const TextStyle(color: AppTheme.bcpOrange, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),

                // Lista de tarjetas
                ...filtrados.map((s) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s['id'],
                                style: const TextStyle(
                                  color: AppTheme.bcpCyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                s['fecha'],
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s['cliente'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Monto: S/ ${s['monto']}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                if (filtrados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'Sin solicitudes',
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector izquierdo de Solicitud
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: solicitudesSimuladas.length,
              itemBuilder: (context, index) {
                final s = solicitudesSimuladas[index];
                final isSelected = selectedSolicitud?['id'] == s['id'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.bcpOrange.withOpacity(0.12) : AppTheme.cardDark.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.bcpOrange : Colors.white.withOpacity(0.04),
                      width: 1.2,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        selectedSolicitud = s;
                      });
                    },
                    title: Text(
                      s['cliente'],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      '${s['id']} • S/ ${s['monto']}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11.5),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),

          // Línea de tiempo derecha
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardDark.withOpacity(0.9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: selectedSolicitud == null
                    ? const Center(child: Text('Seleccione una solicitud', style: TextStyle(color: Colors.white38)))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historial de ${selectedSolicitud!['cliente']}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Código: ${selectedSolicitud!['id']} • Estado: ${selectedSolicitud!['estado']}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const Divider(color: Colors.white12, height: 24),

                          Expanded(
                            child: ListView.builder(
                              itemCount: (selectedSolicitud!['timeline'] as List).length,
                              itemBuilder: (context, tIndex) {
                                final node = selectedSolicitud!['timeline'][tIndex];

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        const Icon(Icons.lens, size: 12, color: AppTheme.bcpOrange),
                                        if (tIndex < (selectedSolicitud!['timeline'] as List).length - 1)
                                          Container(
                                            width: 1.5,
                                            height: 54,
                                            color: Colors.white24,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            node['fecha'],
                                            style: const TextStyle(
                                              color: AppTheme.bcpCyan,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            node['desc'],
                                            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
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
