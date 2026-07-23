import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'estado/alcance_app.dart';
import 'estado/controlador_app.dart';
import 'pantallas/pantalla_inicio.dart';
import 'pantallas/pantalla_login.dart';
import 'servicios/repositorio_partidas.dart';
import 'servicios/repositorio_partidas_firebase.dart';
import 'servicios/repositorio_partidas_memoria.dart';
import 'servicios/servicio_autenticacion.dart';
import 'servicios/servicio_autenticacion_firebase.dart';
import 'servicios/servicio_autenticacion_local.dart';
import 'tema/tema_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const solicitarFirebase = bool.fromEnvironment(
    'USAR_FIREBASE',
    defaultValue: false,
  );
  var firebaseActiva = false;
  if (solicitarFirebase) {
    try {
      await Firebase.initializeApp();
      firebaseActiva = true;
    } catch (error) {
      debugPrint('Firebase no pudo inicializarse; se usará el modo local: $error');
    }
  }

  final ServicioAutenticacion autenticacion = firebaseActiva
      ? ServicioAutenticacionFirebase()
      : ServicioAutenticacionLocal();
  final RepositorioPartidas repositorio = firebaseActiva
      ? RepositorioPartidasFirebase()
      : RepositorioPartidasMemoria();

  runApp(
    BingoSportApp(
      controlador: ControladorApp(
        autenticacion: autenticacion,
        repositorioPartidas: repositorio,
        firebaseActiva: firebaseActiva,
      ),
    ),
  );
}

class BingoSportApp extends StatelessWidget {
  const BingoSportApp({super.key, required this.controlador});

  final ControladorApp controlador;

  @override
  Widget build(BuildContext context) {
    return AlcanceApp(
      controlador: controlador,
      child: MaterialApp(
        title: 'Bingo Sport',
        debugShowCheckedModeBanner: false,
        theme: crearTemaBingoSport(),
        home: const _EnrutadorSesion(),
      ),
    );
  }
}

class _EnrutadorSesion extends StatelessWidget {
  const _EnrutadorSesion();

  @override
  Widget build(BuildContext context) {
    final controlador = AlcanceApp.de(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animacion) => FadeTransition(
        opacity: animacion,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(animacion),
          child: child,
        ),
      ),
      child: controlador.sesionIniciada
          ? const PantallaInicio(key: ValueKey('inicio'))
          : const PantallaLogin(key: ValueKey('login')),
    );
  }
}
