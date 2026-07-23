import 'accion_bingo.dart';
import 'deporte.dart';

class ConfiguracionPartida {
  const ConfiguracionPartida({
    required this.deporte,
    required this.tamano,
    required this.acciones,
    required this.esOnline,
  });

  final Deporte deporte;
  final int tamano;
  final List<AccionBingo> acciones;
  final bool esOnline;

  Map<String, dynamic> aJson() => <String, dynamic>{
        'deporte': deporte.aJson(),
        'tamano': tamano,
        'acciones': acciones.map((accion) => accion.aJson()).toList(),
        'esOnline': esOnline,
      };

  factory ConfiguracionPartida.desdeJson(Map<Object?, Object?> json) {
    final accionesCrudas = json['acciones'];
    return ConfiguracionPartida(
      deporte: Deporte.desdeJson(
        json['deporte'] is Map
            ? Map<Object?, Object?>.from(json['deporte']! as Map)
            : <Object?, Object?>{},
      ),
      tamano: int.tryParse(json['tamano']?.toString() ?? '') ?? 3,
      acciones: accionesCrudas is List
          ? accionesCrudas
              .whereType<Map>()
              .map((valor) => AccionBingo.desdeJson(Map<Object?, Object?>.from(valor)))
              .toList()
          : <AccionBingo>[],
      esOnline: json['esOnline'] == true,
    );
  }
}
