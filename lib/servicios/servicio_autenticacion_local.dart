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
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final nombreBase = correo.split('@').first.replaceAll('.', ' ').trim();
    _usuarioActual = Usuario(
      id: correo.toLowerCase().hashCode.toString(),
      nombre: nombreBase.isEmpty ? 'Jugador' : _capitalizar(nombreBase),
      correo: correo.trim().toLowerCase(),
    );
    return _usuarioActual!;
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _usuarioActual = Usuario(
      id: correo.toLowerCase().hashCode.toString(),
      nombre: nombre.trim(),
      correo: correo.trim().toLowerCase(),
    );
    return _usuarioActual!;
  }

  @override
  Future<void> cerrarSesion() async {
    _usuarioActual = null;
  }

  String _capitalizar(String texto) {
    return texto
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .map((parte) => '${parte[0].toUpperCase()}${parte.substring(1)}')
        .join(' ');
  }
}
