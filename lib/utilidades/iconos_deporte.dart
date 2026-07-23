import 'package:flutter/material.dart';

IconData iconoParaDeporte(String clave) {
  switch (clave) {
    case 'futbol':
      return Icons.sports_soccer_rounded;
    case 'basquetbol':
      return Icons.sports_basketball_rounded;
    case 'tenis':
      return Icons.sports_tennis_rounded;
    case 'running':
      return Icons.directions_run_rounded;
    case 'ciclismo':
      return Icons.directions_bike_rounded;
    case 'natacion':
      return Icons.pool_rounded;
    default:
      return Icons.emoji_events_rounded;
  }
}
