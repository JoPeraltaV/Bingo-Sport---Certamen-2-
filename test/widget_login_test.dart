import 'package:bingo_sport/estado/controlador_app.dart';
import 'package:bingo_sport/main.dart';
import 'package:bingo_sport/servicios/repositorio_partidas_memoria.dart';
import 'package:bingo_sport/servicios/servicio_autenticacion_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el login valida correo y contraseña', (tester) async {
    final controlador = ControladorApp(
      autenticacion: ServicioAutenticacionLocal(),
      repositorioPartidas: RepositorioPartidasMemoria(),
      firebaseActiva: false,
    );
    addTearDown(controlador.dispose);

    await tester.pumpWidget(BingoSportApp(controlador: controlador));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingresa un correo válido.'), findsOneWidget);
    expect(find.text('Usa al menos 6 caracteres.'), findsOneWidget);
  });

  testWidgets('permite cambiar al formulario de registro', (tester) async {
    final controlador = ControladorApp(
      autenticacion: ServicioAutenticacionLocal(),
      repositorioPartidas: RepositorioPartidasMemoria(),
      firebaseActiva: false,
    );
    addTearDown(controlador.dispose);

    await tester.pumpWidget(BingoSportApp(controlador: controlador));
    await tester.tap(find.text('Crear una cuenta nueva'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Nombre'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });
}
