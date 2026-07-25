import 'package:flutter/material.dart';

import '../modelos/deporte.dart';
import '../utilidades/iconos_deporte.dart';

class TarjetaDeporte extends StatelessWidget {
  const TarjetaDeporte({
    super.key,
    required this.deporte,
    required this.alPresionar,
    this.seleccionado = false,
  });

  final Deporte deporte;
  final VoidCallback alPresionar;
  final bool seleccionado;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: seleccionado,
      label: 'Seleccionar ${deporte.nombre}',
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: seleccionado
                ? colores.primaryContainer
                : colores.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: seleccionado ? colores.primary : colores.outlineVariant,
              width: seleccionado ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconoParaDeporte(deporte.claveIcono),
                size: 38,
                color: seleccionado ? colores.primary : colores.onSurfaceVariant,
              ),
              const SizedBox(height: 10),
              Text(
                deporte.nombre,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: seleccionado
                      ? colores.onPrimaryContainer
                      : colores.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
