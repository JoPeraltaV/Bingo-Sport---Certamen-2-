import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../datos/catalogo_predeterminado.dart';
import '../modelos/accion_bingo.dart';
import '../modelos/configuracion_partida.dart';
import '../modelos/deporte.dart';
import '../modelos/estado_partida.dart';
import '../modelos/sala_online.dart';
import '../modelos/usuario.dart';
import '../servicios/repositorio_partidas.dart';
import '../servicios/servicio_autenticacion.dart';

class ControladorApp extends ChangeNotifier {
  ControladorApp({
    required ServicioAutenticacion autenticacion,
    required RepositorioPartidas repositorioPartidas,
    required bool firebaseActiva,
  })  : _autenticacion = autenticacion,
        _repositorioPartidas = repositorioPartidas,
        firebaseActiva = firebaseActiva,
        deportes = crearCatalogoPredeterminado(),
        usuario = autenticacion.usuarioActual;

  final ServicioAutenticacion _autenticacion;
  final RepositorioPartidas _repositorioPartidas;
  final Random _aleatorio = Random();
  StreamSubscription<SalaOnline>? _suscripcionSala;

  final bool firebaseActiva;
  final List<Deporte> deportes;

  bool modoOscuro = false;
  void alternarModoOscuro() {
    modoOscuro = !modoOscuro;
    notifyListeners();
  }

  Usuario? usuario;
  ConfiguracionPartida? configuracionActual;
  EstadoPartida? partidaActual;
  SalaOnline? salaActual;
  bool cargandoAutenticacion = false;
  bool cargandoSala = false;
  String? mensajeError;

  bool get sesionIniciada => usuario != null;
  bool get soyAnfitrion =>
      salaActual != null && usuario != null && salaActual!.anfitrionId == usuario!.id;

  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    return _ejecutarAutenticacion(
      () => _autenticacion.iniciarSesion(
        correo: correo,
        contrasena: contrasena,
      ),
    );
  }

  Future<bool> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    return _ejecutarAutenticacion(
      () => _autenticacion.registrar(
        nombre: nombre,
        correo: correo,
        contrasena: contrasena,
      ),
    );
  }

  Future<bool> _ejecutarAutenticacion(
    Future<Usuario> Function() operacion,
  ) async {
    cargandoAutenticacion = true;
    mensajeError = null;
    notifyListeners();
    try {
      usuario = await operacion();
      return true;
    } catch (error) {
      mensajeError = _mensajeAutenticacion(error);
      return false;
    } finally {
      cargandoAutenticacion = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    await _suscripcionSala?.cancel();
    _suscripcionSala = null;
    await _autenticacion.cerrarSesion();
    usuario = null;
    configuracionActual = null;
    partidaActual = null;
    salaActual = null;
    mensajeError = null;
    notifyListeners();
  }

  void agregarDeporte({
    required String nombre,
    required String claveIcono,
  }) {
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.isEmpty) return;
    final id = 'personalizado_${DateTime.now().microsecondsSinceEpoch}';
    deportes.add(
      Deporte(
        id: id,
        nombre: nombreLimpio,
        claveIcono: claveIcono,
        acciones: const <AccionBingo>[],
        esPersonalizado: true,
      ),
    );
    notifyListeners();
  }

  void agregarAccionAlDeporte(Deporte deporte, String texto) {
    final textoLimpio = texto.trim();
    if (textoLimpio.isEmpty) return;
    final indice = deportes.indexWhere((item) => item.id == deporte.id);
    if (indice == -1) return;
    final accion = AccionBingo(
      id: 'accion_${DateTime.now().microsecondsSinceEpoch}',
      texto: textoLimpio,
      esPersonalizada: true,
    );
    deportes[indice] = deportes[indice].copiarCon(
      acciones: <AccionBingo>[...deportes[indice].acciones, accion],
    );
    notifyListeners();
  }

  String? prepararPartida({
    required Deporte deporte,
    required int tamano,
    required List<AccionBingo> accionesSeleccionadas,
    required bool esOnline,
  }) {
    final cantidadNecesaria = tamano * tamano;
    final unicas = <String, AccionBingo>{
      for (final accion in accionesSeleccionadas) accion.id: accion,
    }.values.toList();

    if (unicas.length < cantidadNecesaria) {
      return 'Necesitas al menos $cantidadNecesaria acciones diferentes.';
    }

    unicas.shuffle(_aleatorio);
    final accionesCarton = unicas.take(cantidadNecesaria).toList(growable: false);
    configuracionActual = ConfiguracionPartida(
      deporte: deporte,
      tamano: tamano,
      acciones: unicas,
      esOnline: esOnline,
    );
    partidaActual = EstadoPartida(
      acciones: accionesCarton,
      marcadas: List<bool>.filled(cantidadNecesaria, false),
    );
    salaActual = esOnline ? salaActual : null;
    mensajeError = null;
    notifyListeners();
    return null;
  }

  int marcarAccion(int indice) {
    final partida = partidaActual;
    final configuracion = configuracionActual;
    if (partida == null || configuracion == null) return 0;
    if (indice < 0 || indice >= partida.marcadas.length) return 0;

    partida.marcadas[indice] = !partida.marcadas[indice];
    final lineasCompletas = _lineasCompletas(
      partida.marcadas,
      configuracion.tamano,
    );
    final nuevas = lineasCompletas.difference(partida.lineasPremiadas);
    partida.lineasPremiadas.addAll(nuevas);
    partida.puntos += nuevas.length;
    notifyListeners();

    if (salaActual != null && usuario != null) {
      unawaited(
        _repositorioPartidas.actualizarPuntaje(
          codigo: salaActual!.codigo,
          jugador: usuario!,
          puntos: partida.puntos,
          cartonCompleto: partida.cartonCompleto,
        ),
      );
    }
    return nuevas.length;
  }

  Set<String> _lineasCompletas(List<bool> marcadas, int tamano) {
    final completas = <String>{};
    for (var fila = 0; fila < tamano; fila++) {
      final completa = List<bool>.generate(
        tamano,
        (columna) => marcadas[fila * tamano + columna],
      ).every((valor) => valor);
      if (completa) completas.add('fila_$fila');
    }

    for (var columna = 0; columna < tamano; columna++) {
      final completa = List<bool>.generate(
        tamano,
        (fila) => marcadas[fila * tamano + columna],
      ).every((valor) => valor);
      if (completa) completas.add('columna_$columna');
    }

    final diagonalPrincipal = List<bool>.generate(
      tamano,
      (indice) => marcadas[indice * tamano + indice],
    ).every((valor) => valor);
    if (diagonalPrincipal) completas.add('diagonal_principal');

    final diagonalSecundaria = List<bool>.generate(
      tamano,
      (indice) => marcadas[indice * tamano + (tamano - 1 - indice)],
    ).every((valor) => valor);
    if (diagonalSecundaria) completas.add('diagonal_secundaria');

    return completas;
  }

  Future<bool> crearSalaOnline() async {
    final usuarioActual = usuario;
    final configuracion = configuracionActual;
    if (usuarioActual == null || configuracion == null) return false;

    cargandoSala = true;
    mensajeError = null;
    notifyListeners();
    try {
      final codigo = await _crearCodigoDisponible();
      salaActual = await _repositorioPartidas.crearSala(
        codigo: codigo,
        anfitrion: usuarioActual,
        configuracion: configuracion,
      );
      _escucharSala(codigo);
      return true;
    } catch (error) {
      mensajeError = 'No se pudo crear la sala: $error';
      return false;
    } finally {
      cargandoSala = false;
      notifyListeners();
    }
  }

  Future<bool> unirSalaDesdeContenido(String contenido) async {
    final codigo = extraerCodigoSala(contenido);
    if (codigo == null) {
      mensajeError = 'El código QR no pertenece a Bingo Sport.';
      notifyListeners();
      return false;
    }
    return unirSalaConCodigo(codigo);
  }

  Future<bool> unirSalaConCodigo(String codigo) async {
    final usuarioActual = usuario;
    if (usuarioActual == null) return false;
    cargandoSala = true;
    mensajeError = null;
    notifyListeners();
    try {
      final sala = await _repositorioPartidas.unirSala(
        codigo: codigo.trim().toUpperCase(),
        jugador: usuarioActual,
      );
      salaActual = sala;
      configuracionActual = sala.configuracion;
      _crearCartonDesdeConfiguracion(sala.configuracion);
      _escucharSala(sala.codigo);
      return true;
    } catch (error) {
      mensajeError = 'No se pudo entrar a la sala. Revisa el código.';
      return false;
    } finally {
      cargandoSala = false;
      notifyListeners();
    }
  }

  Future<void> iniciarSalaOnline() async {
    final sala = salaActual;
    if (sala == null || !soyAnfitrion) return;
    await _repositorioPartidas.iniciarSala(sala.codigo);
  }

  void prepararCartonDeSala() {
    final sala = salaActual;
    if (sala == null) return;
    configuracionActual = sala.configuracion;
    final cantidadEsperada = sala.configuracion.tamano * sala.configuracion.tamano;
    if (partidaActual == null || partidaActual!.acciones.length != cantidadEsperada) {
      _crearCartonDesdeConfiguracion(sala.configuracion);
    }
    notifyListeners();
  }

  void _crearCartonDesdeConfiguracion(ConfiguracionPartida configuracion) {
    final acciones = List<AccionBingo>.from(configuracion.acciones)..shuffle(_aleatorio);
    final cantidad = configuracion.tamano * configuracion.tamano;
    partidaActual = EstadoPartida(
      acciones: acciones.take(cantidad).toList(growable: false),
      marcadas: List<bool>.filled(cantidad, false),
    );
  }

  void abandonarSala() {
    unawaited(_suscripcionSala?.cancel());
    _suscripcionSala = null;
    salaActual = null;
    if (configuracionActual?.esOnline == true) {
      configuracionActual = null;
      partidaActual = null;
    }
    notifyListeners();
  }

  String? extraerCodigoSala(String contenido) {
    final limpio = contenido.trim();
    final uri = Uri.tryParse(limpio);
    if (uri != null && uri.scheme == 'bingo-sport' && uri.host == 'sala') {
      final segmentos = uri.pathSegments;
      if (segmentos.isNotEmpty) return segmentos.last.toUpperCase();
    }
    final codigoPlano = limpio.toUpperCase();
    if (RegExp(r'^[A-Z0-9]{6}$').hasMatch(codigoPlano)) return codigoPlano;
    return null;
  }

  Future<String> _crearCodigoDisponible() async {
    const caracteres = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    for (var intento = 0; intento < 20; intento++) {
      final codigo = List<String>.generate(
        6,
        (_) => caracteres[_aleatorio.nextInt(caracteres.length)],
      ).join();
      if (await _repositorioPartidas.obtenerSala(codigo) == null) return codigo;
    }
    throw StateError('No fue posible generar un código de sala.');
  }

  void _escucharSala(String codigo) {
    unawaited(_suscripcionSala?.cancel());
    _suscripcionSala = _repositorioPartidas.observarSala(codigo).listen(
      (sala) {
        salaActual = sala;
        notifyListeners();
      },
      onError: (Object error) {
        mensajeError = 'Se perdió la conexión con la sala.';
        notifyListeners();
      },
    );
  }

  String _mensajeAutenticacion(Object error) {
    final texto = error.toString().toLowerCase();
    if (texto.contains('wrong-password') || texto.contains('invalid-credential')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (texto.contains('email-already-in-use')) {
      return 'Ya existe una cuenta con ese correo.';
    }
    if (texto.contains('network')) {
      return 'No hay conexión. Intenta nuevamente.';
    }
    return 'No fue posible completar la autenticación.';
  }

  @override
  void dispose() {
    _suscripcionSala?.cancel();
    super.dispose();
  }
}
