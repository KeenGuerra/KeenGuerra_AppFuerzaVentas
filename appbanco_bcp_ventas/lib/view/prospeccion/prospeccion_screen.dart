import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class ProspeccionScreen extends StatefulWidget {
  const ProspeccionScreen({super.key});

  @override
  State<ProspeccionScreen> createState() => _ProspeccionScreenState();
}

class _ProspeccionScreenState extends State<ProspeccionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _negocioController = TextEditingController();
  final TextEditingController _ingresosController = TextEditingController();
  final TextEditingController _egresosController = TextEditingController();

  String preEvalResult = '';
  Color preEvalColor = Colors.transparent;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _negocioController.dispose();
    _ingresosController.dispose();
    _egresosController.dispose();
    super.dispose();
  }

  void _evaluarProspecto() {
    if (_formKey.currentState!.validate()) {
      final double ingresos = double.tryParse(_ingresosController.text) ?? 0;
      final double egresos = double.tryParse(_egresosController.text) ?? 0;

      final saldoNeto = ingresos - egresos;

      setState(() {
        if (saldoNeto <= 0) {
          preEvalResult = 'RECHAZADO: Margen financiero insuficiente (saldo neto negativo o cero).';
          preEvalColor = Colors.redAccent;
        } else if (saldoNeto < 1000) {
          preEvalResult = 'PRE-APROBADO CONDICIONADO: Margen ajustado. Capacidad máx. sugerida: S/ 5,000';
          preEvalColor = Colors.amberAccent;
        } else {
          preEvalResult = 'APROBADO PARA CONTINUAR: Excelente capacidad de pago. Capacidad máx. sugerida: S/ 15,000';
          preEvalColor = Colors.greenAccent;
        }
      });
    }
  }

  void _guardarProspecto() {
    if (_formKey.currentState!.validate()) {
      _evaluarProspecto();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prospecto ${_nombresController.text} registrado y pre-evaluado con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
      _nombresController.clear();
      _apellidosController.clear();
      _dniController.clear();
      _telefonoController.clear();
      _direccionController.clear();
      _negocioController.clear();
      _ingresosController.clear();
      _egresosController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Módulo de Prospección'),
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
              // Sección Campañas Comerciales Activas
              const Text(
                'Campañas Comerciales Activas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CampanaCard(
                      titulo: 'Reactivación Mype BCP',
                      desc: 'Tasa preferencial de 14.5% TEA. Montos hasta S/ 20,000.',
                      vence: 'Vence 30/06/2026',
                      color: const Color(0xFF003F8A),
                    ),
                    const SizedBox(width: 12),
                    _CampanaCard(
                      titulo: 'Agro-Préstamo BCP',
                      desc: 'Período de gracia de hasta 3 meses para sector agrícola.',
                      vence: 'Vence 15/07/2026',
                      color: const Color(0xFF0D5E5C),
                    ),
                    const SizedBox(width: 12),
                    _CampanaCard(
                      titulo: 'Mujer Emprendedora',
                      desc: 'Sin garantía real para microempresarias con historial positivo.',
                      vence: 'Vence 31/07/2026',
                      color: const Color(0xFF8C1D59),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Formulario de Registro
              const Text(
                'Registrar Nuevo Prospecto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nombresController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Nombres',
                            prefixIcon: Icon(Icons.person_outline, color: AppTheme.bcpOrange),
                          ),
                          validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _apellidosController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Apellidos',
                            prefixIcon: Icon(Icons.person_pin_outlined, color: AppTheme.bcpOrange),
                          ),
                          validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dniController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'DNI',
                                  prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.bcpOrange),
                                ),
                                validator: (v) => v!.length != 8 ? 'Debe tener 8 dígitos' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _telefonoController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Teléfono',
                                  prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.bcpOrange),
                                ),
                                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _direccionController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Dirección de Domicilio',
                            prefixIcon: Icon(Icons.home_outlined, color: AppTheme.bcpOrange),
                          ),
                          validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _negocioController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Nombre/Giro del Negocio',
                            prefixIcon: Icon(Icons.storefront_outlined, color: AppTheme.bcpOrange),
                          ),
                          validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 18),

                        const Divider(color: Colors.white12),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Evaluación Financiera Rápida',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ingresosController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Ingreso Mensual (S/)',
                                  prefixIcon: Icon(Icons.arrow_upward, color: Colors.greenAccent),
                                ),
                                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _egresosController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Egreso Mensual (S/)',
                                  prefixIcon: Icon(Icons.arrow_downward, color: Colors.redAccent),
                                ),
                                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                              ),
                            ),
                          ],
                        ),

                        if (preEvalResult.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: preEvalColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: preEvalColor, width: 1.2),
                            ),
                            child: Text(
                              preEvalResult,
                              style: TextStyle(
                                color: preEvalColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _evaluarProspecto,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.bcpOrange, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Pre-evaluar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _guardarProspecto,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Registrar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampanaCard extends StatelessWidget {
  final String titulo;
  final String desc;
  final String vence;
  final Color color;

  const _CampanaCard({
    required this.titulo,
    required this.desc,
    required this.vence,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            vence,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white38,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
