import 'configuracion_partida.dart';

class JugadorOnline {
  const JugadorOnline({
    required this.id,
    required this.nombre,
    required this.puntos,
    required this.cartonCompleto,
  });

  final String id;
  final String nombre;
  final int puntos;
  final bool cartonCompleto;

  Map<String, dynamic> aJson() => <String, dynamic>{
        'id': id,
        'nombre': nombre,
        'puntos': puntos,
        'cartonCompleto': cartonCompleto,
      };

  factory JugadorOnline.desdeJson(Map<Object?, Object?> json) {
    return JugadorOnline(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? 'Jugador',
      puntos: int.tryParse(json['puntos']?.toString() ?? '') ?? 0,
      cartonCompleto: json['cartonCompleto'] == true,
    );
  }
}

enum EstadoSalaOnline { esperando, jugando, terminada }

class SalaOnline {
  const SalaOnline({
    required this.codigo,
    required this.anfitrionId,
    required this.configuracion,
    required this.jugadores,
    required this.estado,
  });

  final String codigo;
  final String anfitrionId;
  final ConfiguracionPartida configuracion;
  final Map<String, JugadorOnline> jugadores;
  final EstadoSalaOnline estado;

  String get contenidoQr => 'bingo-sport://sala/$codigo';

  SalaOnline copiarCon({
    Map<String, JugadorOnline>? jugadores,
    EstadoSalaOnline? estado,
  }) {
    return SalaOnline(
      codigo: codigo,
      anfitrionId: anfitrionId,
      configuracion: configuracion,
      jugadores: jugadores ?? this.jugadores,
      estado: estado ?? this.estado,
    );
  }

  Map<String, dynamic> aJson() => <String, dynamic>{
        'codigo': codigo,
        'anfitrionId': anfitrionId,
        'configuracion': configuracion.aJson(),
        'jugadores': jugadores.map(
          (clave, jugador) => MapEntry(clave, jugador.aJson()),
        ),
        'estado': estado.name,
      };

  factory SalaOnline.desdeJson(Map<Object?, Object?> json) {
    final jugadoresCrudos = json['jugadores'];
    final jugadores = <String, JugadorOnline>{};
    if (jugadoresCrudos is Map) {
      for (final entrada in jugadoresCrudos.entries) {
        final valor = entrada.value;
        if (valor is Map) {
          jugadores[entrada.key.toString()] = JugadorOnline.desdeJson(
            Map<Object?, Object?>.from(valor),
          );
        }
      }
    }

    return SalaOnline(
      codigo: json['codigo']?.toString() ?? '',
      anfitrionId: json['anfitrionId']?.toString() ?? '',
      configuracion: ConfiguracionPartida.desdeJson(
        json['configuracion'] is Map
            ? Map<Object?, Object?>.from(json['configuracion']! as Map)
            : <Object?, Object?>{},
      ),
      jugadores: jugadores,
      estado: EstadoSalaOnline.values.firstWhere(
        (estado) => estado.name == json['estado']?.toString(),
        orElse: () => EstadoSalaOnline.esperando,
      ),
    );
  }
}
