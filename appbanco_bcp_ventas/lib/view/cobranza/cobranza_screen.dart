import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class CobranzaScreen extends StatefulWidget {
  const CobranzaScreen({super.key});

  @override
  State<CobranzaScreen> createState() => _CobranzaScreenState();
}

class _CobranzaScreenState extends State<CobranzaScreen> {
  final List<Map<String, dynamic>> queueMora = [
    {
      'id': 'CLI101',
      'nombre': 'Juana Quispe Ramos',
      'moraDias': 5,
      'montoVencido': 320.50,
      'cuotasAtrasadas': 1,
      'telefono': '987654321',
      'acciones': []
    },
    {
      'id': 'CLI102',
      'nombre': 'Ricardo Mendoza Paz',
      'moraDias': 18,
      'montoVencido': 1250.00,
      'cuotasAtrasadas': 2,
      'telefono': '951753456',
      'acciones': []
    },
    {
      'id': 'CLI103',
      'nombre': 'Elena Victoria Soto',
      'moraDias': 2,
      'montoVencido': 150.00,
      'cuotasAtrasadas': 1,
      'telefono': '963852741',
      'acciones': []
    },
  ];

  Map<String, dynamic>? selectedClient;

  // Formulario de acción
  String selectedAccion = 'Llamada telefónica';
  final TextEditingController _compromisoMontoController = TextEditingController();
  final TextEditingController _observacionController = TextEditingController();
  DateTime? compromisoFecha;

  @override
  void initState() {
    super.initState();
    if (queueMora.isNotEmpty) {
      selectedClient = queueMora.first;
    }
  }

  @override
  void dispose() {
    _compromisoMontoController.dispose();
    _observacionController.dispose();
    super.dispose();
  }

  void _registrarAccion() {
    if (selectedClient == null) return;

    final nuevaAccion = {
      'tipo': selectedAccion,
      'fecha': DateTime.now().toIso8601String().substring(0, 10),
      'observacion': _observacionController.text,
      'compromiso': selectedAccion == 'Compromiso de Pago'
          ? 'Monto: S/ ${_compromisoMontoController.text} | Fecha: ${compromisoFecha?.toIso8601String().substring(0, 10)}'
          : null,
    };

    setState(() {
      selectedClient!['acciones'].insert(0, nuevaAccion);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Acción de cobranza registrada y programada con éxito.'),
        backgroundColor: Colors.green,
      ),
    );

    _compromisoMontoController.clear();
    _observacionController.clear();
    compromisoFecha = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Cobranza Móvil'),
        backgroundColor: AppTheme.bcpBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Listado de clientes en mora
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cola de Mora Diaria',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: queueMora.length,
                        itemBuilder: (context, index) {
                          final cli = queueMora[index];
                          final isSelected = selectedClient?['id'] == cli['id'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.bcpOrange.withOpacity(0.12) : AppTheme.cardDark.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? AppTheme.bcpOrange : Colors.white.withOpacity(0.04),
                                width: 1.2,
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  selectedClient = cli;
                                });
                              },
                              title: Text(
                                cli['nombre'],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                              ),
                              subtitle: Text(
                                'Mora: ${cli['moraDias']} días • S/ ${cli['montoVencido']}',
                                style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cli['moraDias'] > 15 ? Colors.red.withOpacity(0.15) : Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: cli['moraDias'] > 15 ? Colors.redAccent : Colors.amberAccent,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  cli['moraDias'] > 15 ? 'Crítico' : 'Alerta',
                                  style: TextStyle(
                                    color: cli['moraDias'] > 15 ? Colors.redAccent : Colors.amberAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
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

              const SizedBox(width: 16),

              // Registro de acciones
              Expanded(
                flex: 3,
                child: selectedClient == null
                    ? const Card(child: Center(child: Text('Seleccione un cliente.')))
                    : SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedClient!['nombre'],
                                  style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Días de mora: ${selectedClient!['moraDias']} • Cuotas vencidas: ${selectedClient!['cuotasAtrasadas']}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                const Divider(color: Colors.white12),
                                const SizedBox(height: 12),

                                const Text(
                                  'Registrar Gestión de Cobro',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.bcpOrange, fontSize: 13.5, letterSpacing: 0.3),
                                ),
                                const SizedBox(height: 12),

                                DropdownButtonFormField<String>(
                                  value: selectedAccion,
                                  dropdownColor: AppTheme.cardDark,
                                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                                  decoration: const InputDecoration(labelText: 'Tipo de Acción'),
                                  items: const [
                                    DropdownMenuItem(value: 'Llamada telefónica', child: Text('Llamada telefónica')),
                                    DropdownMenuItem(value: 'Visita de cobranza', child: Text('Visita de cobranza')),
                                    DropdownMenuItem(value: 'Compromiso de Pago', child: Text('Compromiso de Pago')),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedAccion = val!;
                                    });
                                  },
                                ),

                                if (selectedAccion == 'Compromiso de Pago') ...[
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _compromisoMontoController,
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Monto del Compromiso (S/)'),
                                  ),
                                  const SizedBox(height: 12),
                                  ListTile(
                                    title: Text(
                                      compromisoFecha == null
                                          ? 'Seleccionar Fecha Compromiso'
                                          : 'Fecha: ${compromisoFecha!.toIso8601String().substring(0, 10)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                                    ),
                                    trailing: const Icon(Icons.calendar_today_outlined, color: AppTheme.bcpOrange, size: 20),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().add(const Duration(days: 1)),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 30)),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          compromisoFecha = picked;
                                        });
                                      }
                                    },
                                  ),
                                ],

                                const SizedBox(height: 12),
                                TextField(
                                  controller: _observacionController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(labelText: 'Observación de la Gestión'),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _registrarAccion,
                                    child: const Text('Guardar Gestión'),
                                  ),
                                ),

                                const Divider(color: Colors.white12, height: 32),
                                const Text(
                                  'Historial de Gestiones Recientes',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13.5),
                                ),
                                const SizedBox(height: 10),

                                if ((selectedClient!['acciones'] as List).isEmpty)
                                  const Text('No hay gestiones previas registradas hoy.',
                                      style: TextStyle(color: Colors.white38, fontSize: 12))
                                else
                                  ...((selectedClient!['acciones'] as List).map((a) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.02),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withOpacity(0.02)),
                                      ),
                                      child: ListTile(
                                        title: Text(a['tipo'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                                        subtitle: Text('${a['observacion']}\n${a['compromiso'] ?? ""}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                        trailing: Text(a['fecha'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                      ),
                                    );
                                  })),
                              ],
                            ),
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
