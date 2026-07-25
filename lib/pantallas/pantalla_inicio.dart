import 'package:flutter/material.dart';

import '../estado/alcance_app.dart';
import '../widgets/boton_principal.dart';
import '../widgets/tarjeta_deporte.dart';
import 'pantalla_crear_partida.dart';
import 'pantalla_escanear_qr.dart';
import 'pantalla_sala_online.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  Future<void> _crearDeporte(BuildContext context) async {
    final controladorTexto = TextEditingController();
    var icono = 'deporte';
    final resultado = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) {
        return StatefulBuilder(
          builder: (contextoDialogo, actualizar) {
            return AlertDialog(
              title: const Text('Crear deporte'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: controladorTexto,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Nombre del deporte'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: icono,
                    decoration: const InputDecoration(labelText: 'Icono'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'deporte', child: Text('Trofeo')),
                      DropdownMenuItem(value: 'futbol', child: Text('Fútbol')),
                      DropdownMenuItem(value: 'basquetbol', child: Text('Básquetbol')),
                      DropdownMenuItem(value: 'tenis', child: Text('Tenis')),
                      DropdownMenuItem(value: 'running', child: Text('Running')),
                      DropdownMenuItem(value: 'ciclismo', child: Text('Ciclismo')),
                      DropdownMenuItem(value: 'natacion', child: Text('Natación')),
                    ],
                    onChanged: (valor) => actualizar(() => icono = valor ?? 'deporte'),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(contextoDialogo, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(contextoDialogo, true),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
    if (resultado == true && context.mounted) {
      AlcanceApp.de(context, escuchar: false).agregarDeporte(
        nombre: controladorTexto.text,
        claveIcono: icono,
      );
    }
    controladorTexto.dispose();
  }

  Future<void> _unirseConCodigo(BuildContext context) async {
    final texto = TextEditingController();
    final codigo = await showDialog<String>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Unirse a una sala'),
        content: TextField(
          controller: texto,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'Código de 6 caracteres'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contextoDialogo, texto.text),
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
    texto.dispose();
    if (codigo == null || !context.mounted) return;
    await _procesarIngreso(context, codigo);
  }

  Future<void> _escanearQr(BuildContext context) async {
    final contenido = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const PantallaEscanearQr()),
    );
    if (contenido == null || !context.mounted) return;
    await _procesarIngreso(context, contenido);
  }

  Future<void> _procesarIngreso(BuildContext context, String contenido) async {
    final controlador = AlcanceApp.de(context, escuchar: false);
    final codigo = controlador.extraerCodigoSala(contenido);
    final exito = codigo != null && await controlador.unirSalaConCodigo(codigo);
    if (!context.mounted) return;
    if (exito) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PantallaSalaOnline()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controlador.mensajeError ?? 'Código no válido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlador = AlcanceApp.de(context);
    final usuario = controlador.usuario!;
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bingo Sport'),
        actions: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: IconButton(
              key: ValueKey<bool>(controlador.modoOscuro),
              tooltip: controlador.modoOscuro ? 'Modo claro' : 'Modo oscuro',
              onPressed: controlador.alternarModoOscuro,
              icon: Icon(
                controlador.modoOscuro
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: controlador.cerrarSesion,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[colores.primary, colores.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: Text(
                    usuario.nombre.isEmpty ? 'B' : usuario.nombre[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Hola, ${usuario.nombre}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Elige un deporte y crea tu próximo cartón.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          BotonPrincipal(
            texto: 'Crear nueva partida',
            icono: Icons.grid_view_rounded,
            alPresionar: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PantallaCrearPartida()),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _unirseConCodigo(context),
                  icon: const Icon(Icons.pin_rounded),
                  label: const Text('Usar código'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _escanearQr(context),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Escanear QR'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Tus deportes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _crearDeporte(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controlador.deportes.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisExtent: 142,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, indice) {
              final deporte = controlador.deportes[indice];
              return TarjetaDeporte(
                deporte: deporte,
                alPresionar: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PantallaCrearPartida(deporteInicialId: deporte.id),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            controlador.firebaseActiva
                ? 'Las salas online se sincronizan con Supabase.'
                : 'Modo local. Activa el modo online para jugar entre dispositivos.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
