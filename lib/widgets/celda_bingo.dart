import 'package:flutter/material.dart';

class CeldaBingo extends StatelessWidget {
  const CeldaBingo({
    super.key,
    required this.texto,
    required this.marcada,
    required this.alPresionar,
    required this.tamanoCarton,
  });

  final String texto;
  final bool marcada;
  final VoidCallback alPresionar;
  final int tamanoCarton;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final tamanoTexto = switch (tamanoCarton) {
      3 => 14.0,
      4 => 11.5,
      _ => 9.5,
    };

    return Semantics(
      button: true,
      checked: marcada,
      label: texto,
      child: GestureDetector(
        onTap: alPresionar,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: marcada ? 0.96 : 1,
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(tamanoCarton == 5 ? 5 : 8),
            decoration: BoxDecoration(
              color: marcada ? colores.primary : Colors.white,
              borderRadius: BorderRadius.circular(tamanoCarton == 5 ? 12 : 16),
              border: Border.all(
                color: marcada ? colores.primary : colores.outlineVariant,
              ),
              boxShadow: marcada
                  ? <BoxShadow>[
                      BoxShadow(
                        color: colores.primary.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Center(
                  child: Text(
                    texto,
                    textAlign: TextAlign.center,
                    maxLines: tamanoCarton == 5 ? 4 : 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: tamanoTexto,
                      height: 1.12,
                      color: marcada ? colores.onPrimary : colores.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    opacity: marcada ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: tamanoCarton == 5 ? 15 : 19,
                      color: colores.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
