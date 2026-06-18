import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ui/theme/app_theme.dart';

class ClientPortalScreen extends StatefulWidget {
  const ClientPortalScreen({super.key});

  @override
  State<ClientPortalScreen> createState() => _ClientPortalScreenState();
}

class _ClientPortalScreenState extends State<ClientPortalScreen> {
  final supabase = Supabase.instance.client;

  // Login controllers
  final _dniLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();
  bool _isLoggedIn = false;
  bool _loading = false;
  String? _loginError;

  // Client session data
  Map<String, dynamic>? _clientData;
  List<dynamic> _myApplications = [];

  // Application form controllers
  final _montoController = TextEditingController(text: '1000');
  final _plazoController = TextEditingController(text: '12');
  final _destinoController = TextEditingController(text: 'Capital de trabajo: compra de mercadería');
  String _garantiaSelected = 'sin garantia';
  bool _seguroDesgravamen = false;

  // French Amortization values
  double cuotaMensual = 0.0;
  double totalAPagar = 0.0;
  double costoFinanciero = 0.0;
  double teaAplicada = 43.92; // Default sin seguro

  @override
  void initState() {
    super.initState();
    _calcularAmortizacion();
  }

  @override
  void dispose() {
    _dniLoginController.dispose();
    _passwordLoginController.dispose();
    _montoController.dispose();
    _plazoController.dispose();
    _destinoController.dispose();
    super.dispose();
  }

  void _calcularAmortizacion() {
    final double P = double.tryParse(_montoController.text) ?? 0;
    final int n = int.tryParse(_plazoController.text) ?? 0;

    // TEA 40.92 % (con seguro de desgravamen) o 43.92 % (sin seguro de desgravamen)
    teaAplicada = _seguroDesgravamen ? 40.92 : 43.92;

    if (P <= 0 || n <= 0) {
      setState(() {
        cuotaMensual = 0.0;
        totalAPagar = 0.0;
        costoFinanciero = 0.0;
      });
      return;
    }

    final double TEM = pow(1 + (teaAplicada / 100), 1 / 12) - 1;
    final double factor = pow(1 + TEM, n).toDouble();
    
    setState(() {
      cuotaMensual = P * (TEM * factor) / (factor - 1);
      totalAPagar = cuotaMensual * n;
      costoFinanciero = totalAPagar - P;
    });
  }

  Future<void> _loginCliente() async {
    final dni = _dniLoginController.text.trim();
    if (dni.isEmpty) {
      setState(() {
        _loginError = 'Ingrese su número de documento.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _loginError = null;
    });

    try {
      // Intentar buscar el cliente en la tabla
      final data = await supabase
          .from('clientes')
          .select()
          .eq('dni', dni)
          .maybeSingle();

      if (data == null) {
        setState(() {
          _loginError = 'Documento no registrado como cliente de práctica.';
        });
      } else {
        setState(() {
          _clientData = data;
          _isLoggedIn = true;
        });
        await _cargarSolicitudes();
      }
    } catch (e) {
      setState(() {
        _loginError = 'Error de conexión: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _cargarSolicitudes() async {
    if (_clientData == null) return;
    try {
      final list = await supabase
          .from('solicitudes_credito')
          .select()
          .eq('cliente_id', _clientData!['id'])
          .order('created_at', ascending: false);

      setState(() {
        _myApplications = list;
      });
    } catch (e) {
      debugPrint('Error al cargar solicitudes: $e');
    }
  }

  // Determinar la prioridad según DNI del caso
  int _obtenerPrioridadPorDni(String dni) {
    final normalDnis = ['40118120', '40110010', '40115011'];
    final altaDnis = [
      '43440349', '40556071', '43773379', '40886086', '41990091', '43003039',
      '41669166', '40119019', '41226126', '43339033', '40556056', '43889089',
      '41003001', '42220022', '43337037', '43334034'
    ];

    if (normalDnis.contains(dni)) return 1; // Normal
    if (altaDnis.contains(dni)) return 3; // Alta
    return 2; // Media
  }

  Future<void> _enviarSolicitud() async {
    if (_clientData == null) return;

    final P = double.tryParse(_montoController.text) ?? 0;
    final n = int.tryParse(_plazoController.text) ?? 0;

    if (P <= 0 || n <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese monto y plazo válidos.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final expId = 'EXP${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
      
      // 1. Insertar solicitud de crédito en estado "enviado"
      await supabase.from('solicitudes_credito').insert({
        'id': expId,
        'oficial_id': _clientData!['oficial_id'],
        'cliente_id': _clientData!['id'],
        'monto_solicitado': P,
        'plazo_meses': n,
        'destino_credito': _destinoController.text.trim(),
        'garantia': _garantiaSelected,
        'seguro_desgravamen': _seguroDesgravamen,
        'tea': teaAplicada,
        'estado': 'enviado',
        'sync_status': 'SINCRONIZADO',
      });

      // 2. Crear o actualizar entrada en cartera_diaria para el Oficial
      final priority = _obtenerPrioridadPorDni(_clientData!['dni']);
      final idCartera = 'cart_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
      
      await supabase.from('cartera_diaria').insert({
        'id': idCartera,
        'oficial_id': _clientData!['oficial_id'],
        'cliente_id': _clientData!['id'],
        'tipo_gestion': 'NUEVA_SOLICITUD',
        'estado': 'Pendiente',
        'prioridad': priority,
        'observacion': 'Solicitud registrada por el cliente desde App Clientes. Monto: S/ $P.',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud enviada con éxito. Expediente: $expId'),
          backgroundColor: AppTheme.neonGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _destinoController.text = 'Capital de trabajo: compra de mercadería';
      _montoController.text = '1000';
      _plazoController.text = '12';
      _seguroDesgravamen = false;
      _calcularAmortizacion();

      await _cargarSolicitudes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar: ${e.toString()}'),
          backgroundColor: AppTheme.neonRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phonelink_ring_rounded, color: AppTheme.bcpOrange),
            const SizedBox(width: 8),
            Text(_isLoggedIn ? 'App Clientes Banco Andino' : 'Simulador App Clientes'),
          ],
        ),
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bcpGradient,
        ),
        child: _isLoggedIn ? _buildDashboard() : _buildLogin(),
      ),
    );
  }

  Widget _buildLogin() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: AppTheme.bcpOrange.withOpacity(0.2), blurRadius: 16),
                ],
              ),
              child: const Icon(Icons.person_pin_rounded, color: AppTheme.bcpBlue, size: 54),
            ),
            const SizedBox(height: 20),
            const Text(
              'Portal Autoservicio Clientes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ingresa con tu DNI de caso práctico para registrar tu solicitud',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white60),
            ),
            const SizedBox(height: 28),

            // Card Glassmorphic de Login
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.glassDecoration(
                color: AppTheme.cardDark,
                opacity: 0.85,
                borderRadius: 28,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _dniLoginController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Documento Nacional de Identidad (DNI)',
                      prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.bcpOrange),
                      hintText: 'Ej. 40118120',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordLoginController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Clave de Acceso Internet',
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.bcpOrange),
                    ),
                  ),
                  if (_loginError != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _loginError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.neonRed, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.bcpOrangeGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.neonGlowShadow(color: AppTheme.bcpOrange, opacity: 0.3),
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _loginCliente,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('INGRESAR A MI PORTAL', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDashboard() {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección Izquierda: Formulario de Solicitud
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera Bienvenida
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.glassDecoration(
                      color: AppTheme.cardDark,
                      opacity: 0.85,
                      borderRadius: 22,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.bcpBlue.withOpacity(0.3),
                          child: const Icon(Icons.account_circle, color: AppTheme.neonCyan),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, ${_clientData!['nombres']}!',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                'Negocio: ${_clientData!['negocio'] ?? 'Microempresa'}',
                                style: const TextStyle(fontSize: 12, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isLoggedIn = false;
                              _clientData = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: AppTheme.neonRed),
                          ),
                          child: const Text('Salir', style: TextStyle(color: AppTheme.neonRed, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Formulario de Solicitud de Préstamo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassDecoration(
                      color: AppTheme.cardDark,
                      opacity: 0.85,
                      borderRadius: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Simulador Crédito Microempresa',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15.5),
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _montoController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Monto Solicitado (S/)',
                                ),
                                onChanged: (_) => _calcularAmortizacion(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _plazoController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Plazo (Meses)',
                                ),
                                onChanged: (_) => _calcularAmortizacion(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Switch de Seguro de Desgravamen
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.04)),
                          ),
                          child: SwitchListTile(
                            title: const Text(
                              'Seguro de Desgravamen BCP',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              _seguroDesgravamen ? 'TEA Aplicada: 40.92% (Con seguro)' : 'TEA Aplicada: 43.92% (Sin seguro)',
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                            value: _seguroDesgravamen,
                            activeColor: AppTheme.bcpOrange,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              setState(() {
                                _seguroDesgravamen = val;
                              });
                              _calcularAmortizacion();
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextField(
                          controller: _destinoController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Destino del Crédito',
                          ),
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          value: _garantiaSelected,
                          dropdownColor: AppTheme.cardDark,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Garantía Presentada'),
                          items: const [
                            DropdownMenuItem(value: 'sin garantia', child: Text('Sin Garantía')),
                            DropdownMenuItem(value: 'hipotecaria', child: Text('Garantía Hipotecaria')),
                            DropdownMenuItem(value: 'vehicular', child: Text('Garantía Vehicular')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _garantiaSelected = val ?? 'sin garantia';
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        // Cuota de Amortización Francesa
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bcpBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.bcpCyan.withOpacity(0.25)),
                          ),
                          child: Column(
                            children: [
                              _buildSimRow('Cuota Mensual Referencial', 'S/ ${cuotaMensual.toStringAsFixed(2)}', highlight: true),
                              const Divider(color: Colors.white10),
                              _buildSimRow('Total a Pagar', 'S/ ${totalAPagar.toStringAsFixed(2)}'),
                              _buildSimRow('Costo de Intereses', 'S/ ${costoFinanciero.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.bcpOrangeGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.neonGlowShadow(color: AppTheme.bcpOrange, opacity: 0.25),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _enviarSolicitud,
                              icon: const Icon(Icons.send_sharp),
                              label: const Text('REGISTRAR SOLICITUD', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sección Derecha: Mis solicitudes registradas
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historial de Solicitudes',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _myApplications.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(16),
                            decoration: AppTheme.glassDecoration(color: AppTheme.cardDark, opacity: 0.5, borderRadius: 20),
                            child: const Text('No tienes solicitudes enviadas.', style: TextStyle(color: Colors.white30, fontSize: 13)),
                          )
                        : ListView.builder(
                            itemCount: _myApplications.length,
                            itemBuilder: (context, index) {
                              final app = _myApplications[index];
                              
                              Color badgeColor = AppTheme.neonCyan;
                              if (app['estado'] == 'desembolsado') badgeColor = AppTheme.neonGreen;
                              if (app['estado'] == 'rechazado') badgeColor = AppTheme.neonRed;
                              if (app['estado'] == 'aprobado' || app['estado'] == 'condicionado') badgeColor = Colors.amberAccent;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: AppTheme.glassDecoration(
                                  color: AppTheme.cardDark,
                                  opacity: 0.85,
                                  borderRadius: 18,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        app['id'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.neonCyan, fontSize: 12.5),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: badgeColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: badgeColor.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          app['estado'].toString().toUpperCase(),
                                          style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Monto: S/ ${app['monto_solicitado']} | Plazo: ${app['plazo_meses']} meses',
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'TEA: ${app['tea']}% | ${app['garantia']}',
                                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                                        ),
                                      ],
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
        ],
      ),
    );
  }

  Widget _buildSimRow(String desc, String val, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(desc, style: TextStyle(color: highlight ? Colors.white : Colors.white60, fontSize: highlight ? 13 : 12)),
          Text(
            val,
            style: TextStyle(
              color: highlight ? AppTheme.neonOrange : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 15.5 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
