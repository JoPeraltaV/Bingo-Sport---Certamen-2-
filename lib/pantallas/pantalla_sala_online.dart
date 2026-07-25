import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../estado/alcance_app.dart';
import '../modelos/sala_online.dart';
import '../widgets/boton_principal.dart';
import 'pantalla_juego.dart';

class PantallaSalaOnline extends StatelessWidget {
  const PantallaSalaOnline({super.key});

  Future<void> _salir(BuildContext context) async {
    AlcanceApp.de(context, escuchar: false).abandonarSala();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controlador = AlcanceApp.de(context);
    final sala = controlador.salaActual;
    if (sala == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sala online')),
        body: const Center(child: Text('No hay una sala activa.')),
      );
    }

    final jugadores = sala.jugadores.values.toList()
      ..sort((a, b) => b.puntos.compareTo(a.puntos));
    final colores = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _salir(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sala online'),
          leading: IconButton(
            onPressed: () => _salir(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colores.outlineVariant),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    sala.estado == EstadoSalaOnline.esperando
                        ? 'Invita a tus amigos'
                        : sala.estado == EstadoSalaOnline.jugando
                            ? 'La partida comenzó'
                            : 'Partida terminada',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedScale(
                    scale: sala.estado == EstadoSalaOnline.esperando ? 1 : 0.92,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: colores.primary.withValues(alpha: 0.12),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: sala.contenidoQr,
                        size: 210,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: colores.primary,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: colores.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Código de sala', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: sala.codigo));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código copiado.')),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        sala.codigo,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              letterSpacing: 7,
                              fontWeight: FontWeight.w900,
                              color: colores.primary,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: Icon(
                      controlador.firebaseActiva ? Icons.cloud_done_rounded : Icons.phone_android_rounded,
                      size: 18,
                    ),
                    label: Text(
                      controlador.firebaseActiva
                          ? 'Sincronización Supabase'
                          : 'Demostración en este dispositivo',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Jugadores (${jugadores.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            ...jugadores.asMap().entries.map((entrada) {
              final jugador = entrada.value;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${entrada.key + 1}'),
                  ),
                  title: Text(
                    jugador.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(jugador.cartonCompleto ? '¡Cartón completo!' : '${jugador.puntos} puntos'),
                  trailing: jugador.id == sala.anfitrionId
                      ? const Chip(label: Text('Anfitrión'))
                      : null,
                ),
              );
            }),
            const SizedBox(height: 22),
            if (sala.estado == EstadoSalaOnline.esperando && controlador.soyAnfitrion)
              BotonPrincipal(
                texto: 'Comenzar partida',
                icono: Icons.play_arrow_rounded,
                alPresionar: controlador.iniciarSalaOnline,
              )
            else if (sala.estado == EstadoSalaOnline.esperando)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colores.secondaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Esperando a que el anfitrión comience la partida…',
                  textAlign: TextAlign.center,
                ),
              )
            else
              BotonPrincipal(
                texto: sala.estado == EstadoSalaOnline.terminada
                    ? 'Ver mi cartón'
                    : 'Entrar al cartón',
                icono: Icons.grid_view_rounded,
                alPresionar: () {
                  controlador.prepararCartonDeSala();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const PantallaJuego()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
