import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class ConsultaBuroScreen extends StatefulWidget {
  const ConsultaBuroScreen({super.key});

  @override
  State<ConsultaBuroScreen> createState() => _ConsultaBuroScreenState();
}

class _ConsultaBuroScreenState extends State<ConsultaBuroScreen> {
  bool autorizacionFirmada = false;
  bool cargando = false;
  bool consultaRealizada = false;

  int score = 720;
  String dictamen = 'APROBABLE';
  String riesgo = 'BAJO';

  void _iniciarConsulta() async {
    if (!autorizacionFirmada) return;

    setState(() {
      cargando = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      cargando = false;
      consultaRealizada = true;
    });
  }

  Color getRiesgoColor() {
    if (riesgo == 'ALTO') return Colors.redAccent;
    if (riesgo == 'MEDIO') return Colors.amberAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Consulta de Buró SBS'),
        backgroundColor: AppTheme.bcpBlue,
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
              // Panel de consentimiento
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consentimiento Firmado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Para realizar la consulta SBS y Equifax se requiere la aprobación explícita y firma digital del cliente en la solicitud.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      CheckboxListTile(
                        value: autorizacionFirmada,
                        onChanged: (val) {
                          setState(() {
                            autorizacionFirmada = val ?? false;
                          });
                        },
                        title: const Text(
                          'El cliente autoriza y firmó el consentimiento de consulta',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (autorizacionFirmada && !cargando) ? _iniciarConsulta : null,
                  icon: const Icon(Icons.search_sharp),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: const Text('Consultar Buró en Tiempo Real'),
                ),
              ),

              const SizedBox(height: 20),

              if (cargando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppTheme.bcpOrange),
                        const SizedBox(height: 16),
                        Text(
                          'Conectando con SBS y Equifax...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

              if (consultaRealizada && !cargando) ...[
                // Tarjeta de Resultados & Semáforo de Riesgo
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Dictamen de Buró Evaluador',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Semáforo visual interactivo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SemaphoreNode(color: Colors.redAccent, active: riesgo == 'ALTO'),
                            const SizedBox(width: 12),
                            _SemaphoreNode(color: Colors.amberAccent, active: riesgo == 'MEDIO'),
                            const SizedBox(width: 12),
                            _SemaphoreNode(color: Colors.greenAccent, active: riesgo == 'BAJO'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Score
                        Text(
                          '$score Puntos',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: getRiesgoColor(),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(
                          'Score crediticio (Escala 0 - 850)',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),

                        const Divider(color: Colors.white12, height: 28),

                        _buildInfoRow('Clasificación SBS', '100% Normal (CPP 0%)'),
                        _buildInfoRow('Dictamen BCP', dictamen, textValColor: getRiesgoColor()),
                        _buildInfoRow('Nivel de Riesgo', riesgo, textValColor: getRiesgoColor()),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Detección de Fraude y Listas Negras
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Validaciones de Seguridad',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSecurityCheck('Listas Negras Internas BCP', 'Limpio', true),
                        _buildSecurityCheck('Detección de Fraude de Identidad', 'Aprobado', true),
                        _buildSecurityCheck('Búsqueda OFAC / Lavado Activos', 'Sin Coincidencias', true),
                      ],
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
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
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
            status ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: status ? Colors.greenAccent : Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            state,
            style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold),
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
      width: 46,
      height: 46,
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
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Icon(
        active ? Icons.lens : Icons.radio_button_off,
        color: active ? Colors.white.withOpacity(0.9) : color.withOpacity(0.3),
        size: 16,
      ),
    );
  }
}
