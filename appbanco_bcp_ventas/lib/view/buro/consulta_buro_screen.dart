import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/cliente_cartera_model.dart';
import '../../ui/theme/app_theme.dart';
import '../../viewmodel/auth_oficial_viewmodel.dart';
import '../../viewmodel/buro_credito_viewmodel.dart';

class ConsultaBuroScreen extends StatefulWidget {
  const ConsultaBuroScreen({super.key});

  @override
  State<ConsultaBuroScreen> createState() => _ConsultaBuroScreenState();
}

class _ConsultaBuroScreenState extends State<ConsultaBuroScreen> {
  bool autorizacionFirmada = false;
  ClienteCarteraModel? cliente;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ClienteCarteraModel && cliente == null) {
      cliente = args;
      // Cargar consultas previas si existen
      Future.microtask(() {
        context.read<BuroCreditoViewModel>().cargarConsultas(args.idCliente);
      });
    }
  }

  void _iniciarConsulta() async {
    if (!autorizacionFirmada || cliente == null) return;

    final authViewModel = context.read<AuthOficialViewModel>();
    final buroViewModel = context.read<BuroCreditoViewModel>();

    final oficialId = authViewModel.oficial?.id ?? 'ofi_local';

    await buroViewModel.consultarBuro(
      clienteId: cliente!.idCliente,
      oficialId: oficialId,
      dni: cliente!.idCliente,
    );
  }

  Color getRiesgoColor(String riesgo) {
    if (riesgo == 'ALTO') return AppTheme.neonRed;
    if (riesgo == 'MEDIO') return AppTheme.neonOrange;
    return AppTheme.neonGreen;
  }

  @override
  Widget build(BuildContext context) {
    final buroViewModel = context.watch<BuroCreditoViewModel>();
    final consulta = buroViewModel.ultimaConsulta;
    final payload = consulta?.payload;

    final hasConsulted = consulta != null;
    final inhabilitado = payload != null && payload['inhabilitado'] == true;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Consulta Buró SBS'),
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cliente != null) ...[
                // Cabecera del Cliente
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassDecoration(
                    color: AppTheme.cardDark,
                    opacity: 0.85,
                    borderRadius: 22,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.bcpOrange.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_pin_rounded, color: AppTheme.neonOrange, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cliente!.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Documento (DNI): ${cliente!.idCliente}',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Panel de consentimiento
              Container(
                decoration: AppTheme.glassDecoration(
                  color: AppTheme.cardDark,
                  opacity: 0.85,
                  borderRadius: 22,
                  borderColor: AppTheme.bcpOrange,
                  borderOpacity: 0.08,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Autorización y Firma Digital',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Para realizar la consulta SBS en tiempo real se requiere la aceptación formal del cliente.',
                        style: TextStyle(color: Colors.white54, fontSize: 12.5, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      CheckboxListTile(
                        value: autorizacionFirmada,
                        onChanged: hasConsulted ? null : (val) {
                          setState(() {
                            autorizacionFirmada = val ?? false;
                          });
                        },
                        title: const Text(
                          'El cliente autoriza y firmó el consentimiento de consulta',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        activeColor: AppTheme.bcpOrange,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón de consulta
              if (!hasConsulted)
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: autorizacionFirmada ? AppTheme.bcpOrangeGradient : null,
                      color: autorizacionFirmada ? null : Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: autorizacionFirmada
                          ? AppTheme.neonGlowShadow(color: AppTheme.bcpOrange, opacity: 0.25)
                          : null,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: (autorizacionFirmada && !buroViewModel.loading) ? _iniciarConsulta : null,
                      icon: const Icon(Icons.screen_search_desktop_outlined),
                      label: const Text('CONSULTAR BURÓ EN TIEMPO REAL', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

              if (buroViewModel.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppTheme.bcpOrange),
                        SizedBox(height: 16),
                        Text(
                          'Conectando a central de riesgos SBS y Equifax...',
                          style: TextStyle(color: AppTheme.bcpCyan, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

              if (hasConsulted && !buroViewModel.loading) ...[
                // Mensaje de Bloqueo por Lista de Inhabilitados (DNI terminado en 7)
                if (inhabilitado)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.neonRed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.neonRed.withOpacity(0.5), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.block_flipped, color: AppTheme.neonRed, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SOLICITUD BLOQUEADA',
                                style: TextStyle(color: AppTheme.neonRed, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'El cliente figura en la lista de INHABILITADOS del sistema financiero. Solicitud rechazada automáticamente.',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Tarjeta de Resultados
                Container(
                  decoration: AppTheme.glassDecoration(
                    color: AppTheme.cardDark,
                    opacity: 0.85,
                    borderRadius: 24,
                    borderColor: getRiesgoColor(payload?['riesgo'] ?? 'BAJO'),
                    borderOpacity: 0.15,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Dictamen Analítico de Riesgos BCP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Semáforo visual interactivo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SemaphoreNode(color: AppTheme.neonRed, active: payload?['riesgo'] == 'ALTO'),
                            const SizedBox(width: 14),
                            _SemaphoreNode(color: AppTheme.neonOrange, active: payload?['riesgo'] == 'MEDIO'),
                            const SizedBox(width: 14),
                            _SemaphoreNode(color: AppTheme.neonGreen, active: payload?['riesgo'] == 'BAJO'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Score
                        Text(
                          '${consulta.score} Puntos',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: getRiesgoColor(payload?['riesgo'] ?? 'BAJO'),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(
                          'Score crediticio estimado (Escala 0 - 850)',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),

                        const Divider(color: Colors.white12, height: 28),

                        _buildInfoRow('Clasificación SBS', payload?['clasificacion'] ?? 'Sin clasificación'),
                        _buildInfoRow('Dictamen de Buró', consulta.resultado, textValColor: getRiesgoColor(payload?['riesgo'] ?? 'BAJO')),
                        _buildInfoRow('Nivel de Riesgo', payload?['riesgo'] ?? 'BAJO', textValColor: getRiesgoColor(payload?['riesgo'] ?? 'BAJO')),
                        _buildInfoRow('Entidades Acumuladas', '${payload?['entidades'] ?? 0} banco(s)'),
                        _buildInfoRow('Deuda Total Reportada', 'S/ ${payload?['deudas_sbs'] ?? 0.00}'),
                        _buildInfoRow('Mayor Mora Vigente', '${payload?['mayor_mora'] ?? 0} día(s)'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Validaciones de Seguridad
                Container(
                  decoration: AppTheme.glassDecoration(
                    color: AppTheme.cardDark,
                    opacity: 0.85,
                    borderRadius: 22,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Validaciones de Seguridad & Prevención',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSecurityCheck('Detección Lavado Activos (OFAC)', inhabilitado ? 'Rechazado (Lista)' : 'Limpio', !inhabilitado),
                        _buildSecurityCheck('Listas Negras Internas Banco Andino', inhabilitado ? 'Alerta Interna' : 'Sin Alertas', !inhabilitado),
                        _buildSecurityCheck('Validación Biométrica Reniec', 'Aprobado', true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (inhabilitado)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppTheme.neonRed),
                      label: const Text('CERRAR Y VOLVER', style: TextStyle(color: AppTheme.neonRed, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.neonRed),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.bcpCyanGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('VOLVER AL EXPEDIENTE', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String val, {Color? textValColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(
            val,
            style: TextStyle(
              color: textValColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCheck(String desc, String state, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
            color: status ? AppTheme.neonGreen : AppTheme.neonRed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
          ),
          Text(
            state,
            style: TextStyle(
              color: status ? Colors.white38 : AppTheme.neonRed, 
              fontSize: 12, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SemaphoreNode extends StatelessWidget {
  final Color color;
  final bool active;

  const _SemaphoreNode({
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: active ? color : color.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? Colors.white : color.withOpacity(0.3),
          width: active ? 3 : 2,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Icon(
        active ? Icons.circle : Icons.circle_outlined,
        color: active ? Colors.white.withOpacity(0.9) : color.withOpacity(0.3),
        size: 14,
      ),
    );
  }
}
