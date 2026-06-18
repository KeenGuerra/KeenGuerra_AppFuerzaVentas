import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ui/theme/app_theme.dart';
import '../../viewmodel/auth_oficial_viewmodel.dart';
import '../../viewmodel/solicitud_viewmodel.dart';
import '../../model/solicitud_credito_model.dart';

class EstadosSolicitudesScreen extends StatefulWidget {
  const EstadosSolicitudesScreen({super.key});

  @override
  State<EstadosSolicitudesScreen> createState() => _EstadosSolicitudesScreenState();
}

class _EstadosSolicitudesScreenState extends State<EstadosSolicitudesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SolicitudCreditoModel? _selectedSolicitud;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final oficialId = context.read<AuthOficialViewModel>().oficial?.id ?? 'ofi_local';
      Future.microtask(() async {
        await context.read<SolicitudViewModel>().cargarSolicitudes(oficialId);
        final list = context.read<SolicitudViewModel>().solicitudes;
        if (list.isNotEmpty) {
          setState(() {
            _selectedSolicitud = list.first;
          });
        }
      });
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _generarTimeline(SolicitudCreditoModel s) {
    List<Map<String, dynamic>> timeline = [];

    // Paso 1: Registro
    timeline.add({
      'fecha': 'Registro Inicial',
      'desc': 'Solicitud registrada por el cliente en App Clientes. Canal: Móvil.',
    });

    final est = s.estado.toLowerCase();

    if (est == 'recibido_comite' || est == 'en_evaluacion' || est == 'aprobado' || est == 'condicionado' || est == 'desembolsado' || est == 'rechazado') {
      timeline.add({
        'fecha': 'Comité de Crédito',
        'desc': 'Expediente promovido y recibido por el Comité de Riesgos Zonal.',
      });
    }

    if (est == 'en_evaluacion' || est == 'aprobado' || est == 'condicionado' || est == 'desembolsado' || est == 'rechazado') {
      timeline.add({
        'fecha': 'En Evaluación',
        'desc': 'Analista de Riesgos evaluando capacidad de pago y reporte de buró SBS.',
      });
    }

    if (est == 'aprobado') {
      timeline.add({
        'fecha': 'Aprobado',
        'desc': 'Solicitud APROBADA al 100% sobre el monto solicitado de S/ ${s.montoSolicitado}.',
      });
    } else if (est == 'condicionado') {
      timeline.add({
        'fecha': 'Condicionado',
        'desc': 'Aprobación condicionada por el comité. Se autoriza monto reducido para seguimiento.',
      });
    } else if (est == 'rechazado') {
      timeline.add({
        'fecha': 'Rechazado',
        'desc': 'Expediente rechazado por políticas de riesgo. Motivo: ${s.motivoRechazo ?? 'No especificado'}',
      });
    } else if (est == 'desembolsado') {
      timeline.add({
        'fecha': 'Desembolsado',
        'desc': 'Fondos desembolsados y liquidados. Cronograma de cuotas francesas generado con éxito.',
      });
    }

    return timeline.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final solicitudViewModel = context.watch<SolicitudViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Tablero de Solicitudes'),
        backgroundColor: AppTheme.darkBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.bcpOrange,
          labelColor: AppTheme.bcpOrange,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Tablero Kanban'),
            Tab(icon: Icon(Icons.history_edu_rounded), text: 'Historial / Timeline'),
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
            _buildKanbanTab(solicitudViewModel.solicitudes),
            _buildTimelineTab(solicitudViewModel.solicitudes),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanTab(List<SolicitudCreditoModel> solicitudes) {
    // Columnas Kanban
    final columnas = [
      {'nombre': 'Enviados', 'estados': ['enviado', 'recibido_comite']},
      {'nombre': 'En Evaluación', 'estados': ['en_evaluacion']},
      {'nombre': 'Decisión Zonal', 'estados': ['aprobado', 'condicionado']},
      {'nombre': 'Finalizados', 'estados': ['desembolsado', 'rechazado']},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnas.map((col) {
          final nombreCol = col['nombre'] as String;
          final estadosFiltro = col['estados'] as List<String>;
          
          final filtrados = solicitudes.where((s) => estadosFiltro.contains(s.estado.toLowerCase())).toList();

          return Container(
            width: 290,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassDecoration(
              color: AppTheme.cardDark,
              opacity: 0.85,
              borderRadius: 24,
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
                      nombreCol,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.bcpOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filtrados.length}',
                        style: const TextStyle(color: AppTheme.neonOrange, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: Colors.white10, height: 1),
                ),

                // Lista de tarjetas en scroll vertical dentro de la columna
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 450),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtrados.length,
                    itemBuilder: (context, idx) {
                      final s = filtrados[idx];
                      
                      Color tagColor = AppTheme.bcpCyan;
                      if (s.estado == 'desembolsado') tagColor = AppTheme.neonGreen;
                      if (s.estado == 'rechazado') tagColor = AppTheme.neonRed;
                      if (s.estado == 'aprobado' || s.estado == 'condicionado') tagColor = Colors.amberAccent;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(18),
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
                                    s.id ?? 'SOL_ID',
                                    style: const TextStyle(
                                      color: AppTheme.neonCyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: tagColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: tagColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      s.estado.toUpperCase(),
                                      style: TextStyle(color: tagColor, fontWeight: FontWeight.bold, fontSize: 8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Monto: S/ ${s.montoSolicitado}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Plazo: ${s.plazoMeses} meses • TEA: ${s.tea}%',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (filtrados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.0),
                    child: Center(
                      child: Text(
                        'Sin solicitudes en esta fase.',
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

  Widget _buildTimelineTab(List<SolicitudCreditoModel> solicitudes) {
    if (solicitudes.isEmpty) {
      return const Center(
        child: Text('No hay solicitudes registradas.', style: TextStyle(color: Colors.white38)),
      );
    }

    final currentSelected = _selectedSolicitud ?? solicitudes.first;
    final timelineEvents = _generarTimeline(currentSelected);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector izquierdo de Solicitud
          Expanded(
            flex: 4,
            child: ListView.builder(
              itemCount: solicitudes.length,
              itemBuilder: (context, index) {
                final s = solicitudes[index];
                final isSelected = currentSelected.id == s.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: AppTheme.glassDecoration(
                    color: isSelected ? AppTheme.bcpOrange.withOpacity(0.12) : AppTheme.cardDark.withOpacity(0.6),
                    opacity: 0.85,
                    borderRadius: 18,
                    borderColor: isSelected ? AppTheme.bcpOrange : Colors.white,
                    borderOpacity: isSelected ? 0.4 : 0.04,
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedSolicitud = s;
                      });
                    },
                    title: Text(
                      s.id ?? 'Expediente',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Monto: S/ ${s.montoSolicitado} • Estado: ${s.estado.toUpperCase()}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11.5),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),

          // Línea de tiempo derecha
          Expanded(
            flex: 6,
            child: Container(
              decoration: AppTheme.glassDecoration(
                color: AppTheme.cardDark,
                opacity: 0.85,
                borderRadius: 24,
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeline de Expediente: ${currentSelected.id}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: Colors.white10, height: 1),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: timelineEvents.length,
                        itemBuilder: (context, tIndex) {
                          final event = timelineEvents[tIndex];

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.circle, size: 10, color: AppTheme.bcpOrange),
                                  if (tIndex < timelineEvents.length - 1)
                                    Container(
                                      width: 1.5,
                                      height: 60,
                                      color: Colors.white10,
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['fecha'],
                                      style: const TextStyle(
                                        color: AppTheme.neonCyan,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      event['desc'],
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
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
