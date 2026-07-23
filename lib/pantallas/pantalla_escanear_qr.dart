import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PantallaEscanearQr extends StatefulWidget {
  const PantallaEscanearQr({super.key});

  @override
  State<PantallaEscanearQr> createState() => _PantallaEscanearQrState();
}

class _PantallaEscanearQrState extends State<PantallaEscanearQr> {
  final MobileScannerController _controlador = MobileScannerController();
  bool _procesado = false;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _detectar(BarcodeCapture captura) {
    if (_procesado || captura.barcodes.isEmpty) return;
    final contenido = captura.barcodes.first.rawValue;
    if (contenido == null || contenido.isEmpty) return;
    _procesado = true;
    _controlador.stop();
    Navigator.of(context).pop(contenido);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Escanear sala'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Linterna',
            onPressed: _controlador.toggleTorch,
            icon: const Icon(Icons.flashlight_on_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MobileScanner(controller: _controlador, onDetect: _detectar),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: EdgeInsets.all(24),
              child: Text(
                'Apunta la cámara al QR de Bingo Sport',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
