import 'package:flutter/material.dart';

class SelectorTamano extends StatelessWidget {
  const SelectorTamano({
    super.key,
    required this.valor,
    required this.alCambiar,
  });

  final int valor;
  final ValueChanged<int> alCambiar;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(value: 3, label: Text('3 × 3')),
        ButtonSegment<int>(value: 4, label: Text('4 × 4')),
        ButtonSegment<int>(value: 5, label: Text('5 × 5')),
      ],
      selected: <int>{valor},
      onSelectionChanged: (seleccion) => alCambiar(seleccion.first),
      showSelectedIcon: false,
    );
  }
}
