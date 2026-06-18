import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class CapturaDocumentosScreen extends StatefulWidget {
  const CapturaDocumentosScreen({super.key});

  @override
  State<CapturaDocumentosScreen> createState() => _CapturaDocumentosScreenState();
}

class _CapturaDocumentosScreenState extends State<CapturaDocumentosScreen> {
  String selectedDocType = '';
  bool isCameraView = false;
  bool isCapturing = false;
  String? capturedImagePath;

  // Estados de carga de archivos capturados
  final Map<String, String> capturedPhotos = {};

  final List<Map<String, String>> docTypes = [
    {'key': 'dni_front', 'label': 'DNI Anverso'},
    {'key': 'dni_back', 'label': 'DNI Reverso'},
    {'key': 'business', 'label': 'Foto de Negocio'},
    {'key': 'client', 'label': 'Foto del Cliente'},
  ];

  void _startCapture(String key) {
    setState(() {
      selectedDocType = key;
      isCameraView = true;
      capturedImagePath = null;
    });
  }

  void _simulateCapture() async {
    setState(() {
      isCapturing = true;
    });

    // Simular nitidez y compresión
    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      isCapturing = false;
      capturedImagePath = 'mock_photo_$selectedDocType.jpg';
    });
  }

  void _savePhoto() {
    setState(() {
      capturedPhotos[selectedDocType] = 'Sincronizado';
      isCameraView = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Documento guardado y comprimido a 180 KB.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCameraView) {
      return _buildCameraView();
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Captura Documental'),
        backgroundColor: AppTheme.cardDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documentos requeridos para expediente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: ListView.builder(
                itemCount: docTypes.length,
                itemBuilder: (context, index) {
                  final item = docTypes[index];
                  final key = item['key']!;
                  final label = item['label']!;
                  final isCaptured = capturedPhotos.containsKey(key);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: AppTheme.cardDark,
                    child: ListTile(
                      leading: Icon(
                        isCaptured ? Icons.check_circle : Icons.camera_alt,
                        color: isCaptured ? Colors.green : AppTheme.bcpOrange,
                        size: 28,
                      ),
                      title: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        isCaptured ? 'Estado: Capturado / Comprimido' : 'Pendiente de capturar',
                        style: TextStyle(
                          color: isCaptured ? Colors.greenAccent : Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _startCapture(key),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(isCaptured ? 'Volver a tomar' : 'Capturar'),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (capturedPhotos.length == docTypes.length)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Expediente completo compilado y enviado a Supabase Storage.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cloud_done),
                  label: const Text('Subir Expediente'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    final label = docTypes.firstWhere((t) => t['key'] == selectedDocType)['label'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Capturando: $label'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              isCameraView = false;
            });
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (capturedImagePath == null) ...[
                  // Visor simulado
                  Container(color: Colors.grey.shade900),

                  if (isCapturing)
                    Container(
                      color: Colors.black87,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppTheme.bcpOrange),
                            SizedBox(height: 16),
                            Text(
                              'Validando nitidez...',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Compresión automática en progreso...',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Guías de encuadre
                    Container(
                      margin: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const Positioned(
                      top: 60,
                      child: Text(
                        'Alinee el documento dentro del marco',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ] else ...[
                  // Vista previa con zoom
                  InteractiveViewer(
                    maxScale: 4.0,
                    child: Container(
                      color: Colors.blueGrey.shade900,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.description, size: 80, color: Colors.white54),
                            const SizedBox(height: 12),
                            Text(
                              'Pre-visualización de $label',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Optimizado a 180 KB | Nitidez: 98% (Alta)',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Barra inferior de controles
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (capturedImagePath == null) ...[
                  IconButton(
                    icon: const Icon(Icons.flash_off, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  GestureDetector(
                    onTap: isCapturing ? null : _simulateCapture,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: AppTheme.bcpOrange, width: 4),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 30),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cached, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        capturedImagePath = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Re-tomar', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _savePhoto,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    child: const Text('Guardar Foto'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
