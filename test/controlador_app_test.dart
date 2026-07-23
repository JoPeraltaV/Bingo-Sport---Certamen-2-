import 'package:bingo_sport/estado/controlador_app.dart';
import 'package:bingo_sport/modelos/configuracion_partida.dart';
import 'package:bingo_sport/servicios/repositorio_partidas_memoria.dart';
import 'package:bingo_sport/servicios/servicio_autenticacion_local.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ControladorApp controlador;

  setUp(() async {
    controlador = ControladorApp(
      autenticacion: ServicioAutenticacionLocal(),
      repositorioPartidas: RepositorioPartidasMemoria(),
      firebaseActiva: false,
    );
    await controlador.iniciarSesion(
      correo: 'jugador@ejemplo.com',
      contrasena: '123456',
    );
  });

  tearDown(() => controlador.dispose());

  test('una línea horizontal entrega un punto una sola vez', () {
    final deporte = controlador.deportes.first;
    final error = controlador.prepararPartida(
      deporte: deporte,
      tamano: 3,
      accionesSeleccionadas: deporte.acciones,
      esOnline: false,
    );
    expect(error, isNull);

    controlador.marcarAccion(0);
    controlador.marcarAccion(1);
    expect(controlador.marcarAccion(2), 1);
    expect(controlador.partidaActual!.puntos, 1);

    controlador.marcarAccion(2);
    controlador.marcarAccion(2);
    expect(controlador.partidaActual!.puntos, 1);
  });

  test('el cartón completo se detecta correctamente', () {
    final deporte = controlador.deportes.first;
    controlador.prepararPartida(
      deporte: deporte,
      tamano: 3,
      accionesSeleccionadas: deporte.acciones,
      esOnline: false,
    );

    for (var indice = 0; indice < 9; indice++) {
      controlador.marcarAccion(indice);
    }

    expect(controlador.partidaActual!.cartonCompleto, isTrue);
    expect(controlador.partidaActual!.puntos, 8);
  });

  test('extrae códigos QR y códigos planos', () {
    expect(controlador.extraerCodigoSala('bingo-sport://sala/ABC123'), 'ABC123');
    expect(controlador.extraerCodigoSala('xyz789'), 'XYZ789');
    expect(controlador.extraerCodigoSala('otro contenido'), isNull);
  });

  test('la configuración se puede serializar', () {
    final deporte = controlador.deportes.first;
    final configuracion = ConfiguracionPartida(
      deporte: deporte,
      tamano: 4,
      acciones: deporte.acciones,
      esOnline: true,
    );
    final copia = ConfiguracionPartida.desdeJson(configuracion.aJson());
    expect(copia.tamano, 4);
    expect(copia.deporte.nombre, deporte.nombre);
    expect(copia.acciones.length, deporte.acciones.length);
  });
}
