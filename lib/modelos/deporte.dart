import 'accion_bingo.dart';

class Deporte {
  const Deporte({
    required this.id,
    required this.nombre,
    required this.claveIcono,
    required this.acciones,
    this.esPersonalizado = false,
  });

  final String id;
  final String nombre;
  final String claveIcono;
  final List<AccionBingo> acciones;
  final bool esPersonalizado;

  Deporte copiarCon({List<AccionBingo>? acciones}) {
    return Deporte(
      id: id,
      nombre: nombre,
      claveIcono: claveIcono,
      acciones: acciones ?? this.acciones,
      esPersonalizado: esPersonalizado,
    );
  }

  Map<String, dynamic> aJson() => <String, dynamic>{
        'id': id,
        'nombre': nombre,
        'claveIcono': claveIcono,
        'acciones': acciones.map((accion) => accion.aJson()).toList(),
        'esPersonalizado': esPersonalizado,
      };

  factory Deporte.desdeJson(Map<Object?, Object?> json) {
    final accionesCrudas = json['acciones'];
    return Deporte(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      claveIcono: json['claveIcono']?.toString() ?? 'deporte',
      acciones: accionesCrudas is List
          ? accionesCrudas
              .whereType<Map>()
              .map((valor) => AccionBingo.desdeJson(Map<Object?, Object?>.from(valor)))
              .toList()
          : <AccionBingo>[],
      esPersonalizado: json['esPersonalizado'] == true,
    );
  }
}
