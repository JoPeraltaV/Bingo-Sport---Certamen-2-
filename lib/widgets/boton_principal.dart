import 'package:flutter/material.dart';

class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.alPresionar,
    this.icono,
    this.cargando = false,
    this.expandido = true,
  });

  final String texto;
  final VoidCallback? alPresionar;
  final IconData? icono;
  final bool cargando;
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final contenido = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: cargando
          ? const SizedBox(
              key: ValueKey('cargando'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Row(
              key: const ValueKey('contenido'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icono != null) ...<Widget>[
                  Icon(icono),
                  const SizedBox(width: 10),
                ],
                Text(texto),
              ],
            ),
    );

    final boton = FilledButton(
      onPressed: cargando ? null : alPresionar,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      child: contenido,
    );

    return expandido ? SizedBox(width: double.infinity, child: boton) : boton;
  }
}
