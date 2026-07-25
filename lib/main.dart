import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'estado/alcance_app.dart';
import 'estado/controlador_app.dart';
import 'pantallas/pantalla_inicio.dart';
import 'pantallas/pantalla_login.dart';
import 'servicios/repositorio_partidas.dart';
import 'servicios/repositorio_partidas_supabase.dart';
import 'servicios/servicio_autenticacion.dart';
import 'servicios/servicio_autenticacion_supabase.dart';
import 'tema/tema_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jyaajaycffysghpqcxir.supabase.co',
    publishableKey: 'sb_publishable_8nnY6KjnAUHoSDRFlQD8ow_xD-cemEF',
  );

  final ServicioAutenticacion autenticacion = ServicioAutenticacionSupabase();
  final RepositorioPartidas repositorio = RepositorioPartidasSupabase();

  runApp(
    BingoSportApp(
      controlador: ControladorApp(
        autenticacion: autenticacion,
        repositorioPartidas: repositorio,
        firebaseActiva: true,
      ),
    ),
  );
}

class BingoSportApp extends StatelessWidget {
  const BingoSportApp({super.key, required this.controlador});

  final ControladorApp controlador;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controlador,
      builder: (context, _) {
        return AlcanceApp(
          controlador: controlador,
          child: MaterialApp(
            title: 'Bingo Sport',
            debugShowCheckedModeBanner: false,
            theme: crearTemaBingoSport(),
            darkTheme: crearTemaBingoSport(brightness: Brightness.dark),
            themeMode: controlador.modoOscuro ? ThemeMode.dark : ThemeMode.light,
            home: const _EnrutadorSesion(),
          ),
        );
      },
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
