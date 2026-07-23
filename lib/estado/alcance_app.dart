import 'package:flutter/widgets.dart';

import 'controlador_app.dart';

class AlcanceApp extends InheritedNotifier<ControladorApp> {
  const AlcanceApp({
    super.key,
    required ControladorApp controlador,
    required super.child,
  }) : super(notifier: controlador);

  static ControladorApp de(BuildContext context, {bool escuchar = true}) {
    if (escuchar) {
      final alcance = context.dependOnInheritedWidgetOfExactType<AlcanceApp>();
      assert(alcance != null, 'No se encontró AlcanceApp en el árbol.');
      return alcance!.notifier!;
    }

    final elemento = context.getElementForInheritedWidgetOfExactType<AlcanceApp>();
    final alcance = elemento?.widget as AlcanceApp?;
    assert(alcance != null, 'No se encontró AlcanceApp en el árbol.');
    return alcance!.notifier!;
  }
}
