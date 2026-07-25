import 'package:supabase_flutter/supabase_flutter.dart';

import '../modelos/usuario.dart';
import 'servicio_autenticacion.dart';

class ServicioAutenticacionSupabase implements ServicioAutenticacion {
  ServicioAutenticacionSupabase({SupabaseClient? cliente})
      : _cliente = cliente ?? Supabase.instance.client;

  final SupabaseClient _cliente;

  @override
  Usuario? get usuarioActual {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) return null;
    return _convertir(usuario);
  }

  @override
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    final respuesta = await _cliente.auth.signInWithPassword(
      email: correo.trim(),
      password: contrasena,
    );
    if (respuesta.user == null) {
      throw StateError('No se pudo iniciar sesión.');
    }
    return _convertir(respuesta.user!);
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    final respuesta = await _cliente.auth.signUp(
      email: correo.trim(),
      password: contrasena,
      data: <String, dynamic>{'nombre': nombre.trim()},
    );
    if (respuesta.user == null) {
      throw StateError('No se pudo registrar el usuario.');
    }
    return _convertir(respuesta.user!);
  }

  @override
  Future<void> cerrarSesion() => _cliente.auth.signOut();

  Usuario _convertir(User usuario) {
    final metaNombre = usuario.userMetadata?['nombre']?.toString();
    final correo = usuario.email ?? '';
    return Usuario(
      id: usuario.id,
      nombre: metaNombre?.isNotEmpty == true
          ? metaNombre!
          : correo.split('@').first,
      correo: correo,
    );
  }
}
