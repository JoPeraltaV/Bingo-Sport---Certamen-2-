import 'accion_bingo.dart';

class EstadoPartida {
  EstadoPartida({
    required this.acciones,
    required this.marcadas,
    this.puntos = 0,
    Set<String>? lineasPremiadas,
  }) : lineasPremiadas = lineasPremiadas ?? <String>{};

  final List<AccionBingo> acciones;
  final List<bool> marcadas;
  int puntos;
  final Set<String> lineasPremiadas;

  bool get cartonCompleto => marcadas.isNotEmpty && marcadas.every((valor) => valor);
}
