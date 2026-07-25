import 'package:flutter/material.dart';

import '../estado/alcance_app.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _claveFormulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _modoRegistro = false;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    if (_claveFormulario.currentState?.validate() != true) return;
    final controlador = AlcanceApp.de(context, escuchar: false);
    final exito = _modoRegistro
        ? await controlador.registrar(
            nombre: _nombre.text,
            correo: _correo.text,
            contrasena: _contrasena.text,
          )
        : await controlador.iniciarSesion(
            correo: _correo.text,
            contrasena: _contrasena.text,
          );
    if (!mounted || exito) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(controlador.mensajeError ?? 'Ocurrió un error.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlador = AlcanceApp.de(context);
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _claveFormulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutBack,
                      builder: (context, valor, child) => Transform.scale(
                        scale: valor,
                        child: Opacity(opacity: valor.clamp(0, 1).toDouble(), child: child),
                      ),
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[colores.primary, colores.tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 54,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bingo Sport',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _modoRegistro
                          ? 'Crea tu cuenta para empezar a jugar.'
                          : 'Convierte cada partido en un desafío.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colores.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: _modoRegistro
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: CampoTexto(
                                controlador: _nombre,
                                etiqueta: 'Nombre',
                                icono: Icons.person_outline_rounded,
                                accionTeclado: TextInputAction.next,
                                validador: (valor) {
                                  if ((valor ?? '').trim().length < 2) {
                                    return 'Escribe un nombre válido.';
                                  }
                                  return null;
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    CampoTexto(
                      controlador: _correo,
                      etiqueta: 'Correo electrónico',
                      icono: Icons.alternate_email_rounded,
                      tipoTeclado: TextInputType.emailAddress,
                      accionTeclado: TextInputAction.next,
                      validador: (valor) {
                        final correo = (valor ?? '').trim();
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correo)) {
                          return 'Ingresa un correo válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      controlador: _contrasena,
                      etiqueta: 'Contraseña',
                      icono: Icons.lock_outline_rounded,
                      esContrasena: true,
                      accionTeclado: TextInputAction.done,
                      alEnviar: (_) => _enviar(),
                      validador: (valor) {
                        if ((valor ?? '').length < 6) {
                          return 'Usa al menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    BotonPrincipal(
                      texto: _modoRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                      icono: _modoRegistro
                          ? Icons.person_add_alt_1_rounded
                          : Icons.login_rounded,
                      cargando: controlador.cargandoAutenticacion,
                      alPresionar: _enviar,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: controlador.cargandoAutenticacion
                          ? null
                          : () => setState(() => _modoRegistro = !_modoRegistro),
                      child: Text(
                        _modoRegistro
                            ? 'Ya tengo cuenta'
                            : 'Crear una cuenta nueva',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colores.secondaryContainer.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        controlador.firebaseActiva
                            ? 'Modo online: Supabase está conectado.'
                            : 'Modo demostración: acepta cualquier correo válido y contraseña de 6 caracteres.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
