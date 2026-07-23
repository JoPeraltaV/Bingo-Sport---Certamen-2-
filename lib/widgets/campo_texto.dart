import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.icono,
    this.esContrasena = false,
    this.tipoTeclado,
    this.validador,
    this.accionTeclado,
    this.alEnviar,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final IconData? icono;
  final bool esContrasena;
  final TextInputType? tipoTeclado;
  final String? Function(String?)? validador;
  final TextInputAction? accionTeclado;
  final ValueChanged<String>? alEnviar;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: esContrasena,
      keyboardType: tipoTeclado,
      validator: validador,
      textInputAction: accionTeclado,
      onFieldSubmitted: alEnviar,
      autofillHints: esContrasena
          ? const <String>[AutofillHints.password]
          : tipoTeclado == TextInputType.emailAddress
              ? const <String>[AutofillHints.email]
              : null,
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: icono == null ? null : Icon(icono),
      ),
    );
  }
}
