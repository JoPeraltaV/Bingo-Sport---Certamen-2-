// Implementación local para pruebas (no usa red ni base de datos).
import '../modelos/usuario.dart';
import 'servicio_autenticacion.dart';

class ServicioAutenticacionLocal implements ServicioAutenticacion {
  Usuario? _usuarioActual;

  @override
  Usuario? get usuarioActual => _usuarioActual;

  @override
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    _usuarioActual = Usuario(
      id: 'local-${correo.hashCode}',
      nombre: correo.split('@').first,
      correo: correo.trim(),
    );
    return _usuarioActual!;
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    _usuarioActual = Usuario(
      id: 'local-${correo.hashCode}',
      nombre: nombre.trim(),
      correo: correo.trim(),
    );
    return _usuarioActual!;
  }

  @override
  Future<void> cerrarSesion() async => _usuarioActual = null;
}
