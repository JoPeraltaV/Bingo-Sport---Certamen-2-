import '../modelos/configuracion_partida.dart';
import '../modelos/sala_online.dart';
import '../modelos/usuario.dart';

abstract class RepositorioPartidas {
  Future<SalaOnline> crearSala({
    required String codigo,
    required Usuario anfitrion,
    required ConfiguracionPartida configuracion,
  });

  Future<SalaOnline?> obtenerSala(String codigo);

  Future<SalaOnline> unirSala({
    required String codigo,
    required Usuario jugador,
  });

  Stream<SalaOnline> observarSala(String codigo);

  Future<void> iniciarSala(String codigo);

  Future<void> actualizarPuntaje({
    required String codigo,
    required Usuario jugador,
    required int puntos,
    required bool cartonCompleto,
  });
}
