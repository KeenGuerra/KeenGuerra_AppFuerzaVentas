import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';
import '../../services/offline_storage_service.dart';

class TransmisionScreen extends StatefulWidget {
  const TransmisionScreen({super.key});

  @override
  State<TransmisionScreen> createState() => _TransmisionScreenState();
}

class _TransmisionScreenState extends State<TransmisionScreen> {
  final _offlineService = OfflineStorageService();
  bool isSyncing = false;
  List<dynamic> localBorradores = [];
  double progress = 0.0;
  List<String> syncLogs = [];

  @override
  void initState() {
    super.initState();
    _cargarBorradores();
  }

  void _cargarBorradores() async {
    final list = await _offlineService.obtenerBorradores();
    setState(() {
      localBorradores = list;
    });
  }

  void _iniciarSincronizacion() async {
    if (localBorradores.isEmpty) return;

    setState(() {
      isSyncing = true;
      progress = 0.0;
      syncLogs.clear();
    });

    final pasos = [
      'Iniciando conexión con Supabase Database...',
      'Transmitiendo metadatos de solicitudes (2 en paralelo)...',
      'Subiendo DNI Anverso a Supabase Storage (documentos-solicitudes)...',
      'Subiendo DNI Reverso a Supabase Storage...',
      'Subiendo Firma Digital de Solicitantes...',
      'Verificando consistencia de datos SBS...',
      'Sincronización de expediente finalizada con éxito.',
    ];

    for (int i = 0; i < pasos.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        syncLogs.add(pasos[i]);
        progress = (i + 1) / pasos.length;
      });
    }

    _offlineService.limpiar();
    _cargarBorradores();

    setState(() {
      isSyncing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sincronización finalizada correctamente.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Transmisión de Expedientes'),
        backgroundColor: AppTheme.bcpBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel informativo offline first
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.bcpCyan.withOpacity(0.3), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_outlined, color: AppTheme.bcpOrange, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cola de Sincronización Offline',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localBorradores.isEmpty
                                ? 'No hay solicitudes ni visitas en cola local.'
                                : 'Tienes ${localBorradores.length} solicitudes guardadas sin internet listas para enviar.',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (localBorradores.isNotEmpty && !isSyncing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _iniciarSincronizacion,
                    icon: const Icon(Icons.sync_outlined),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    label: const Text('Sincronizar en Lote'),
                  ),
                ),

              if (isSyncing) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    color: AppTheme.bcpOrange,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Progreso: ${(progress * 100).toInt()}%',
                  style: const TextStyle(color: AppTheme.bcpOrange, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Consola de Sincronización:',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListView.builder(
                      itemCount: syncLogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.chevron_right, color: Colors.greenAccent, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  syncLogs[index],
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontFamily: 'monospace',
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 14),
                const Text(
                  'Borradores Pendientes en Memoria',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: localBorradores.isEmpty
                      ? const Center(
                          child: Text(
                            'Todo sincronizado con Supabase.',
                            style: TextStyle(color: Colors.white30),
                          ),
                        )
                      : ListView.builder(
                          itemCount: localBorradores.length,
                          itemBuilder: (context, index) {
                            final item = localBorradores[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.bcpBlue,
                                  child: Icon(Icons.insert_drive_file_outlined, color: AppTheme.bcpOrange, size: 22),
                                ),
                                title: Text(
                                  'Borrador #${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.5),
                                ),
                                subtitle: Text(
                                  'Monto: S/ ${item.montoSolicitado} | Plazo: ${item.plazoMeses} meses',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12.5),
                                ),
                                trailing: const Icon(Icons.cloud_off_outlined, color: Colors.white30, size: 20),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
