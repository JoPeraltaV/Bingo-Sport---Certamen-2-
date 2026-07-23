import 'dart:async';

import '../modelos/configuracion_partida.dart';
import '../modelos/sala_online.dart';
import '../modelos/usuario.dart';
import 'repositorio_partidas.dart';

class RepositorioPartidasMemoria implements RepositorioPartidas {
  static final Map<String, SalaOnline> _salas = <String, SalaOnline>{};
  static final Map<String, StreamController<SalaOnline>> _controladores =
      <String, StreamController<SalaOnline>>{};

  StreamController<SalaOnline> _controlador(String codigo) {
    return _controladores.putIfAbsent(
      codigo,
      () => StreamController<SalaOnline>.broadcast(),
    );
  }

  void _emitir(SalaOnline sala) {
    _salas[sala.codigo] = sala;
    _controlador(sala.codigo).add(sala);
  }

  @override
  Future<SalaOnline> crearSala({
    required String codigo,
    required Usuario anfitrion,
    required ConfiguracionPartida configuracion,
  }) async {
    final sala = SalaOnline(
      codigo: codigo,
      anfitrionId: anfitrion.id,
      configuracion: configuracion,
      jugadores: <String, JugadorOnline>{
        anfitrion.id: JugadorOnline(
          id: anfitrion.id,
          nombre: anfitrion.nombre,
          puntos: 0,
          cartonCompleto: false,
        ),
      },
      estado: EstadoSalaOnline.esperando,
    );
    _emitir(sala);
    return sala;
  }

  @override
  Future<SalaOnline?> obtenerSala(String codigo) async {
    return _salas[codigo.toUpperCase()];
  }

  @override
  Future<SalaOnline> unirSala({
    required String codigo,
    required Usuario jugador,
  }) async {
    final codigoNormalizado = codigo.toUpperCase();
    final sala = _salas[codigoNormalizado];
    if (sala == null) throw StateError('No se encontró la sala.');
    final jugadores = Map<String, JugadorOnline>.from(sala.jugadores)
      ..[jugador.id] = JugadorOnline(
        id: jugador.id,
        nombre: jugador.nombre,
        puntos: 0,
        cartonCompleto: false,
      );
    final actualizada = sala.copiarCon(jugadores: jugadores);
    _emitir(actualizada);
    return actualizada;
  }

  @override
  Stream<SalaOnline> observarSala(String codigo) async* {
    final codigoNormalizado = codigo.toUpperCase();
    final actual = _salas[codigoNormalizado];
    if (actual != null) yield actual;
    yield* _controlador(codigoNormalizado).stream;
  }

  @override
  Future<void> iniciarSala(String codigo) async {
    final sala = _salas[codigo.toUpperCase()];
    if (sala == null) throw StateError('No se encontró la sala.');
    _emitir(sala.copiarCon(estado: EstadoSalaOnline.jugando));
  }

  @override
  Future<void> actualizarPuntaje({
    required String codigo,
    required Usuario jugador,
    required int puntos,
    required bool cartonCompleto,
  }) async {
    final sala = _salas[codigo.toUpperCase()];
    if (sala == null) return;
    final jugadores = Map<String, JugadorOnline>.from(sala.jugadores)
      ..[jugador.id] = JugadorOnline(
        id: jugador.id,
        nombre: jugador.nombre,
        puntos: puntos,
        cartonCompleto: cartonCompleto,
      );
    final estado = jugadores.values.any((item) => item.cartonCompleto)
        ? EstadoSalaOnline.terminada
        : sala.estado;
    _emitir(sala.copiarCon(jugadores: jugadores, estado: estado));
  }
}
