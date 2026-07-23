import 'dart:math' as math;

import 'package:flutter/material.dart';

class CelebracionVictoria extends StatefulWidget {
  const CelebracionVictoria({super.key});

  @override
  State<CelebracionVictoria> createState() => _CelebracionVictoriaState();
}

class _CelebracionVictoriaState extends State<CelebracionVictoria>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controlador,
        builder: (context, child) {
          return Stack(
            children: List<Widget>.generate(16, (indice) {
              final angulo = (math.pi * 2 / 16) * indice;
              final radio = 55 + 45 * _controlador.value;
              return Align(
                alignment: Alignment(
                  math.cos(angulo) * radio / 170,
                  math.sin(angulo) * radio / 280,
                ),
                child: Transform.rotate(
                  angle: angulo + _controlador.value,
                  child: Icon(
                    indice.isEven ? Icons.star_rounded : Icons.circle,
                    size: indice.isEven ? 22 : 10,
                    color: Theme.of(context)
                        .colorScheme
                        .tertiary
                        .withValues(alpha: 0.85),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
