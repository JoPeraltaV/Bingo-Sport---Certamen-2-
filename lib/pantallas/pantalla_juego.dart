import 'package:flutter/material.dart';

import '../estado/alcance_app.dart';
import '../modelos/sala_online.dart';
import '../widgets/celda_bingo.dart';
import '../widgets/celebracion_victoria.dart';

class PantallaJuego extends StatefulWidget {
  const PantallaJuego({super.key});

  @override
  State<PantallaJuego> createState() => _PantallaJuegoState();
}

class _PantallaJuegoState extends State<PantallaJuego> {
  bool _victoriaMostrada = false;

  Future<void> _marcar(int indice) async {
    final controlador = AlcanceApp.de(context, escuchar: false);
    final nuevasLineas = controlador.marcarAccion(indice);
    final partida = controlador.partidaActual;
    if (!mounted || partida == null) return;

    if (nuevasLineas > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nuevasLineas == 1
                ? '¡Línea completada! +1 punto'
                : '¡$nuevasLineas líneas completadas! +$nuevasLineas puntos',
          ),
          duration: const Duration(milliseconds: 1300),
        ),
      );
    }

    if (partida.cartonCompleto && !_victoriaMostrada) {
      _victoriaMostrada = true;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (contextoDialogo) => Dialog(
          child: SizedBox(
            height: 360,
            child: Stack(
              children: <Widget>[
                const Positioned.fill(child: CelebracionVictoria()),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.emoji_events_rounded, size: 72),
                        const SizedBox(height: 14),
                        Text(
                          '¡Bingo Sport!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completaste el cartón con ${partida.puntos} puntos.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          onPressed: () => Navigator.pop(contextoDialogo),
                          icon: const Icon(Icons.visibility_rounded),
                          label: const Text('Ver cartón'),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final controlador = AlcanceApp.de(context);
    final configuracion = controlador.configuracionActual;
    final partida = controlador.partidaActual;
    if (configuracion == null || partida == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Partida')),
        body: const Center(child: Text('No hay una partida preparada.')),
      );
    }

    final sala = controlador.salaActual;
    final colores = Theme.of(context).colorScheme;
    final jugadores = sala?.jugadores.values.toList()
      ?..sort((a, b) => b.puntos.compareTo(a.puntos));

    return Scaffold(
      appBar: AppBar(
        title: Text(configuracion.deporte.nombre),
        actions: <Widget>[
          if (sala != null)
            IconButton(
              tooltip: 'Código ${sala.codigo}',
              onPressed: () => _mostrarMarcador(context, jugadores ?? <JugadorOnline>[]),
              icon: const Icon(Icons.leaderboard_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[colores.primaryContainer, colores.tertiaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.stars_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${partida.puntos} ${partida.puntos == 1 ? 'punto' : 'puntos'}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    Text('${configuracion.tamano} × ${configuracion.tamano}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: partida.acciones.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: configuracion.tamano,
                    crossAxisSpacing: configuracion.tamano == 5 ? 6 : 9,
                    mainAxisSpacing: configuracion.tamano == 5 ? 6 : 9,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, indice) {
                    return CeldaBingo(
                      texto: partida.acciones[indice].texto,
                      marcada: partida.marcadas[indice],
                      tamanoCarton: configuracion.tamano,
                      alPresionar: () => _marcar(indice),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Completa líneas horizontales, verticales o diagonales. Cada línea nueva vale 1 punto.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarMarcador(BuildContext context, List<JugadorOnline> jugadores) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Marcador online',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              ...jugadores.asMap().entries.map(
                    (entrada) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text('${entrada.key + 1}')),
                      title: Text(entrada.value.nombre),
                      trailing: Text(
                        '${entrada.value.puntos} pts',
                        style: const TextStyle(fontWeight: FontWeight.w900),
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
