import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../modelos/usuario.dart';
import 'servicio_autenticacion.dart';

class ServicioAutenticacionFirebase implements ServicioAutenticacion {
  ServicioAutenticacionFirebase({firebase.FirebaseAuth? autenticacion})
      : _autenticacion = autenticacion ?? firebase.FirebaseAuth.instance;

  final firebase.FirebaseAuth _autenticacion;

  @override
  Usuario? get usuarioActual {
    final usuario = _autenticacion.currentUser;
    if (usuario == null) return null;
    return _convertir(usuario);
  }

  @override
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    final credencial = await _autenticacion.signInWithEmailAndPassword(
      email: correo.trim(),
      password: contrasena,
    );
    return _convertir(credencial.user!);
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    final credencial = await _autenticacion.createUserWithEmailAndPassword(
      email: correo.trim(),
      password: contrasena,
    );
    await credencial.user?.updateDisplayName(nombre.trim());
    await credencial.user?.reload();
    return _convertir(_autenticacion.currentUser!);
  }

  @override
  Future<void> cerrarSesion() => _autenticacion.signOut();

  Usuario _convertir(firebase.User usuario) {
    return Usuario(
      id: usuario.uid,
      nombre: usuario.displayName?.trim().isNotEmpty == true
          ? usuario.displayName!.trim()
          : (usuario.email?.split('@').first ?? 'Jugador'),
      correo: usuario.email ?? '',
    );
  }
}
