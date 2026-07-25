import 'package:flutter/material.dart';

import '../estado/alcance_app.dart';
import '../modelos/accion_bingo.dart';
import '../modelos/deporte.dart';
import '../widgets/boton_principal.dart';
import '../widgets/selector_tamano.dart';
import '../widgets/tarjeta_deporte.dart';
import 'pantalla_juego.dart';
import 'pantalla_sala_online.dart';

class PantallaCrearPartida extends StatefulWidget {
  const PantallaCrearPartida({super.key, this.deporteInicialId});

  final String? deporteInicialId;

  @override
  State<PantallaCrearPartida> createState() => _PantallaCrearPartidaState();
}

class _PantallaCrearPartidaState extends State<PantallaCrearPartida> {
  String? _deporteId;
  int _tamano = 3;
  bool _esOnline = false;
  bool _creando = false;
  final Set<String> _accionesSeleccionadas = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_deporteId != null) return;
    final deportes = AlcanceApp.de(context, escuchar: false).deportes;
    final inicialExiste = deportes.any((item) => item.id == widget.deporteInicialId);
    _deporteId = inicialExiste ? widget.deporteInicialId : deportes.first.id;
    _seleccionarTodas(_deporteActual(deportes));
  }

  Deporte _deporteActual(List<Deporte> deportes) {
    return deportes.firstWhere((item) => item.id == _deporteId);
  }

  void _seleccionarTodas(Deporte deporte) {
    _accionesSeleccionadas
      ..clear()
      ..addAll(deporte.acciones.map((accion) => accion.id));
  }

  Future<void> _agregarAccion(Deporte deporte) async {
    final texto = TextEditingController();
    final resultado = await showDialog<String>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Nueva acción'),
        content: TextField(
          controller: texto,
          autofocus: true,
          maxLength: 70,
          decoration: const InputDecoration(
            labelText: 'Ejemplo: Gol desde fuera del área',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contextoDialogo, texto.text),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => texto.dispose());
    if (resultado == null || resultado.trim().isEmpty || !mounted) return;
    final controlador = AlcanceApp.de(context, escuchar: false);
    controlador.agregarAccionAlDeporte(deporte, resultado);
    final actualizado = controlador.deportes.firstWhere((item) => item.id == deporte.id);
    setState(() {
      _accionesSeleccionadas.add(actualizado.acciones.last.id);
    });
  }

  Future<void> _crearPartida() async {
    final controlador = AlcanceApp.de(context, escuchar: false);
    final deporte = _deporteActual(controlador.deportes);
    final acciones = deporte.acciones
        .where((accion) => _accionesSeleccionadas.contains(accion.id))
        .toList();
    final error = controlador.prepararPartida(
      deporte: deporte,
      tamano: _tamano,
      accionesSeleccionadas: acciones,
      esOnline: _esOnline,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    if (_esOnline) {
      setState(() => _creando = true);
      final exito = await controlador.crearSalaOnline();
      if (!mounted) return;
      setState(() => _creando = false);
      if (!exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controlador.mensajeError ?? 'No se pudo crear la sala.')),
        );
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const PantallaSalaOnline()),
      );
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const PantallaJuego()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlador = AlcanceApp.de(context);
    final deportes = controlador.deportes;
    final deporte = _deporteActual(deportes);
    final cantidadNecesaria = _tamano * _tamano;
    final seleccionadas = deporte.acciones
        .where((accion) => _accionesSeleccionadas.contains(accion.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear partida')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Text(
            '1. Elige el deporte',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: deportes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, indice) {
                final item = deportes[indice];
                return SizedBox(
                  width: 140,
                  child: TarjetaDeporte(
                    deporte: item,
                    seleccionado: item.id == _deporteId,
                    alPresionar: () {
                      setState(() {
                        _deporteId = item.id;
                        _seleccionarTodas(item);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '2. Tamaño del cartón',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          SelectorTamano(
            valor: _tamano,
            alCambiar: (valor) => setState(() => _tamano = valor),
          ),
          const SizedBox(height: 28),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '3. Acciones del bingo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _agregarAccion(deporte),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Personalizada'),
              ),
            ],
          ),
          Text(
            '${seleccionadas.length} seleccionadas · necesitas $cantidadNecesaria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: seleccionadas.length >= cantidadNecesaria
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          if (deporte.acciones.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Este deporte es nuevo. Agrega acciones personalizadas para llenar el cartón.',
                textAlign: TextAlign.center,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: deporte.acciones.map((AccionBingo accion) {
                final seleccionada = _accionesSeleccionadas.contains(accion.id);
                return FilterChip(
                  selected: seleccionada,
                  label: Text(accion.texto),
                  avatar: accion.esPersonalizada
                      ? const Icon(Icons.edit_rounded, size: 17)
                      : null,
                  onSelected: (valor) {
                    setState(() {
                      if (valor) {
                        _accionesSeleccionadas.add(accion.id);
                      } else {
                        _accionesSeleccionadas.remove(accion.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 26),
          SwitchListTile.adaptive(
            value: _esOnline,
            onChanged: (valor) => setState(() => _esOnline = valor),
            title: const Text('Jugar con amigos online'),
            subtitle: Text(
              controlador.firebaseActiva
                  ? 'La sala se compartirá mediante QR y Supabase.'
                  : 'Modo local de demostración.',
            ),
            secondary: const Icon(Icons.groups_rounded),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 18),
          BotonPrincipal(
            texto: _esOnline ? 'Crear sala online' : 'Comenzar partida',
            icono: _esOnline ? Icons.qr_code_2_rounded : Icons.play_arrow_rounded,
            cargando: _creando || controlador.cargandoSala,
            alPresionar: _crearPartida,
          ),
        ],
      ),
    );
  }
}
