import '../modelos/usuario.dart';

abstract class ServicioAutenticacion {
  Usuario? get usuarioActual;

  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  });

  Future<void> cerrarSesion();
}
