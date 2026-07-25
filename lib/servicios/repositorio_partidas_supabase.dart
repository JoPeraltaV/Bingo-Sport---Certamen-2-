import 'package:supabase_flutter/supabase_flutter.dart';

import '../modelos/configuracion_partida.dart';
import '../modelos/sala_online.dart';
import '../modelos/usuario.dart';
import 'repositorio_partidas.dart';

class RepositorioPartidasSupabase implements RepositorioPartidas {
  RepositorioPartidasSupabase({SupabaseClient? cliente})
      : _cliente = cliente ?? Supabase.instance.client;

  final SupabaseClient _cliente;

  static const _tabla = 'salas';

  // DB column (snake_case) → Dart model key (camelCase)
  SalaOnline _desdeFila(Map<String, dynamic> fila) {
    final mapped = Map<String, dynamic>.from(fila);
    mapped['anfitrionId'] = mapped.remove('anfitrion_id');
    return SalaOnline.desdeJson(Map<Object?, Object?>.from(mapped));
  }

  // Dart model keys (camelCase) → DB columns (snake_case)
  Map<String, dynamic> _paraDb(SalaOnline sala) {
    final json = sala.aJson();
    return <String, dynamic>{
      'codigo': json['codigo'],
      'anfitrion_id': json['anfitrionId'],
      'configuracion': json['configuracion'],
      'jugadores': json['jugadores'],
      'estado': json['estado'],
    };
  }

  // ─── RepositorioPartidas ─────────────────────────────────────────────────

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

    await _cliente.from(_tabla).insert(_paraDb(sala));
    return sala;
  }

  @override
  Future<SalaOnline?> obtenerSala(String codigo) async {
    final filas = await _cliente
        .from(_tabla)
        .select()
        .eq('codigo', codigo.toUpperCase());

    if (filas.isEmpty) return null;
    return _desdeFila(filas.first);
  }

  @override
  Future<SalaOnline> unirSala({
    required String codigo,
    required Usuario jugador,
  }) async {
    final sala = await obtenerSala(codigo);
    if (sala == null) throw StateError('No se encontró la sala.');

    final nuevosJugadores = <String, dynamic>{
      for (final entry in sala.jugadores.entries) entry.key: entry.value.aJson()
    };
    nuevosJugadores[jugador.id] = JugadorOnline(
      id: jugador.id,
      nombre: jugador.nombre,
      puntos: 0,
      cartonCompleto: false,
    ).aJson();

    await _cliente
        .from(_tabla)
        .update(<String, dynamic>{'jugadores': nuevosJugadores})
        .eq('codigo', codigo.toUpperCase());

    return (await obtenerSala(codigo))!;
  }

  @override
  Stream<SalaOnline> observarSala(String codigo) {
    return _cliente
        .from(_tabla)
        .stream(primaryKey: ['codigo'])
        .eq('codigo', codigo.toUpperCase())
        .map((filas) {
          if (filas.isEmpty) throw StateError('Sala no encontrada.');
          return _desdeFila(filas.first);
        });
  }

  @override
  Future<void> iniciarSala(String codigo) async {
    await _cliente
        .from(_tabla)
        .update(<String, dynamic>{'estado': EstadoSalaOnline.jugando.name})
        .eq('codigo', codigo.toUpperCase());
  }

  @override
  Future<void> actualizarPuntaje({
    required String codigo,
    required Usuario jugador,
    required int puntos,
    required bool cartonCompleto,
  }) async {
    final sala = await obtenerSala(codigo);
    if (sala == null) throw StateError('Sala no encontrada.');

    final nuevosJugadores = <String, dynamic>{
      for (final entry in sala.jugadores.entries) entry.key: entry.value.aJson()
    };
    nuevosJugadores[jugador.id] = <String, dynamic>{
      'id': jugador.id,
      'nombre': jugador.nombre,
      'puntos': puntos,
      'cartonCompleto': cartonCompleto,
    };

    final actualizacion = <String, dynamic>{'jugadores': nuevosJugadores};
    if (cartonCompleto) {
      actualizacion['estado'] = EstadoSalaOnline.terminada.name;
    }

    await _cliente
        .from(_tabla)
        .update(actualizacion)
        .eq('codigo', codigo.toUpperCase());
  }
}
