// Implementación en memoria para pruebas (no usa red ni base de datos).
import 'dart:async';
import '../modelos/configuracion_partida.dart';
import '../modelos/sala_online.dart';
import '../modelos/usuario.dart';
import 'repositorio_partidas.dart';

class RepositorioPartidasMemoria implements RepositorioPartidas {
  final Map<String, SalaOnline> _salas = {};
  final Map<String, StreamController<SalaOnline>> _controladores = {};

  @override
  Future<SalaOnline> crearSala({
    required String codigo,
    required Usuario anfitrion,
    required ConfiguracionPartida configuracion,
  }) async {
    final sala = SalaOnline(
      codigo: codigo.toUpperCase(),
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
    _guardar(sala);
    return sala;
  }

  @override
  Future<SalaOnline?> obtenerSala(String codigo) async =>
      _salas[codigo.toUpperCase()];

  @override
  Future<SalaOnline> unirSala({
    required String codigo,
    required Usuario jugador,
  }) async {
    final sala = _salas[codigo.toUpperCase()];
    if (sala == null) throw StateError('No se encontró la sala.');
    final actualizada = sala.copiarCon(
      jugadores: {
        ...sala.jugadores,
        jugador.id: JugadorOnline(
          id: jugador.id,
          nombre: jugador.nombre,
          puntos: 0,
          cartonCompleto: false,
        ),
      },
    );
    _guardar(actualizada);
    return actualizada;
  }

  @override
  Stream<SalaOnline> observarSala(String codigo) {
    final clave = codigo.toUpperCase();
    _controladores.putIfAbsent(clave, StreamController<SalaOnline>.broadcast);
    if (_salas.containsKey(clave)) {
      Future.microtask(() => _controladores[clave]!.add(_salas[clave]!));
    }
    return _controladores[clave]!.stream;
  }

  @override
  Future<void> iniciarSala(String codigo) async {
    final sala = _salas[codigo.toUpperCase()];
    if (sala == null) throw StateError('No se encontró la sala.');
    _guardar(sala.copiarCon(estado: EstadoSalaOnline.jugando));
  }

  @override
  Future<void> actualizarPuntaje({
    required String codigo,
    required Usuario jugador,
    required int puntos,
    required bool cartonCompleto,
  }) async {
    final sala = _salas[codigo.toUpperCase()];
    if (sala == null) throw StateError('No se encontró la sala.');
    final nuevoJugador = JugadorOnline(
      id: jugador.id,
      nombre: jugador.nombre,
      puntos: puntos,
      cartonCompleto: cartonCompleto,
    );
    final nuevasSala = sala.copiarCon(
      jugadores: {...sala.jugadores, jugador.id: nuevoJugador},
      estado:
          cartonCompleto ? EstadoSalaOnline.terminada : sala.estado,
    );
    _guardar(nuevasSala);
  }

  void _guardar(SalaOnline sala) {
    _salas[sala.codigo] = sala;
    _controladores[sala.codigo]?.add(sala);
  }
}
