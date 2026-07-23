import 'package:firebase_database/firebase_database.dart';

import '../modelos/configuracion_partida.dart';
import '../modelos/sala_online.dart';
import '../modelos/usuario.dart';
import 'repositorio_partidas.dart';

class RepositorioPartidasFirebase implements RepositorioPartidas {
  RepositorioPartidasFirebase({FirebaseDatabase? baseDeDatos})
      : _baseDeDatos = baseDeDatos ?? FirebaseDatabase.instance;

  final FirebaseDatabase _baseDeDatos;

  DatabaseReference _referencia(String codigo) =>
      _baseDeDatos.ref('salas/${codigo.toUpperCase()}');

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
    await _referencia(codigo).set(sala.aJson());
    return sala;
  }

  @override
  Future<SalaOnline?> obtenerSala(String codigo) async {
    final evento = await _referencia(codigo).once();
    final valor = evento.snapshot.value;
    if (valor is! Map) return null;
    return SalaOnline.desdeJson(Map<Object?, Object?>.from(valor));
  }

  @override
  Future<SalaOnline> unirSala({
    required String codigo,
    required Usuario jugador,
  }) async {
    final sala = await obtenerSala(codigo);
    if (sala == null) throw StateError('No se encontró la sala.');
    await _referencia(codigo).child('jugadores/${jugador.id}').set(
          JugadorOnline(
            id: jugador.id,
            nombre: jugador.nombre,
            puntos: 0,
            cartonCompleto: false,
          ).aJson(),
        );
    return (await obtenerSala(codigo))!;
  }

  @override
  Stream<SalaOnline> observarSala(String codigo) {
    return _referencia(codigo).onValue.where((evento) {
      return evento.snapshot.value is Map;
    }).map((evento) {
      return SalaOnline.desdeJson(
        Map<Object?, Object?>.from(evento.snapshot.value! as Map),
      );
    });
  }

  @override
  Future<void> iniciarSala(String codigo) async {
    await _referencia(codigo).child('estado').set(EstadoSalaOnline.jugando.name);
  }

  @override
  Future<void> actualizarPuntaje({
    required String codigo,
    required Usuario jugador,
    required int puntos,
    required bool cartonCompleto,
  }) async {
    await _referencia(codigo).child('jugadores/${jugador.id}').update(
      <String, dynamic>{
        'nombre': jugador.nombre,
        'puntos': puntos,
        'cartonCompleto': cartonCompleto,
      },
    );
    if (cartonCompleto) {
      await _referencia(codigo).child('estado').set(EstadoSalaOnline.terminada.name);
    }
  }
}
