# Bingo Sport

MVP en Flutter para crear bingos deportivos locales u online. Incluye:

- Login y registro con validación mediante `Form` y `TextFormField`.
- Estado global con `ChangeNotifier` + `InheritedNotifier`, sin dependencia extra.
- Deportes predeterminados y deportes creados por el usuario.
- Acciones predeterminadas y personalizadas.
- Cartones 3×3, 4×4 y 5×5.
- Un punto por cada línea horizontal, vertical o diagonal completada por primera vez.
- Victoria al completar todo el cartón.
- Animaciones de entrada, selección, celdas, carga y celebración.
- Salas mediante código/QR.
- Modo local listo para ejecutar y adaptador para Firebase Realtime Database.
- Widgets, clases, archivos y métodos nombrados en español.

## Estructura

```text
lib/
├── datos/          Catálogo deportivo inicial
├── estado/         Controlador global y alcance de estado
├── modelos/        Entidades del dominio
├── pantallas/      Login, inicio, configuración, sala, QR y juego
├── servicios/      Autenticación y repositorios local/Firebase
├── tema/           Tema visual
├── utilidades/     Mapeo de iconos
└── widgets/        Componentes reutilizables
```

## Requisitos

- Flutter 3.44 o superior.
- Dart 3.8 o superior.
- Android compileSdk 34 o superior para el escáner QR.

## Preparar el proyecto

Este paquete contiene todo el código de la aplicación. Como el entorno donde fue generado no tenía instalado el SDK de Flutter, ejecuta el script incluido para generar de forma segura los archivos nativos estándar y aplicar los permisos de cámara:

### Windows PowerShell

Desde la carpeta `bingo_sport`, ejecuta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\preparar_proyecto.ps1
```

No uses `chmod` en PowerShell: ese comando pertenece a sistemas Unix/Bash.

### macOS, Linux o Git Bash

```bash
chmod +x preparar_proyecto.sh
./preparar_proyecto.sh
```

También puedes ejecutar `flutter create --platforms=android,web .` manualmente en Windows, pero debes conservar los archivos `lib/`, `test/`, `pubspec.yaml` y `analysis_options.yaml` incluidos.

### Permisos para QR

Android: agrega el contenido de `configuracion_plataformas/android_manifest_snippet.xml` en `android/app/src/main/AndroidManifest.xml`.

iOS: agrega el contenido de `configuracion_plataformas/ios_info_plist_snippet.xml` en `ios/Runner/Info.plist`.

## Ejecutar en modo local

```bash
flutter run
```

El modo local acepta cualquier correo con formato válido y cualquier contraseña de al menos 6 caracteres. Las salas locales sirven para demostrar el flujo en una misma instancia de la app.

## Activar Firebase para partidas reales entre dispositivos

1. Crea un proyecto en Firebase.
2. Activa **Authentication > Email/Password**.
3. Activa **Realtime Database**.
4. Configura Android/iOS con FlutterFire o agrega los archivos nativos de Firebase.
5. Publica las reglas de `firebase/database.rules.json` y revísalas antes de producción.
6. Ejecuta:

```bash
flutter run --dart-define=USAR_FIREBASE=true
```

La aplicación intenta inicializar Firebase. Si la configuración no está disponible, vuelve automáticamente al modo local.

Para web, genera `firebase_options.dart` con FlutterFire CLI y pasa `DefaultFirebaseOptions.currentPlatform` a `Firebase.initializeApp`.

## Comandos de calidad

```bash
flutter analyze
flutter test
```

## Decisiones de negocio

- Una línea recibe puntaje una sola vez, aunque se desmarque y vuelva a marcar.
- Un cartón de 3×3 puede obtener hasta 8 puntos: 3 filas, 3 columnas y 2 diagonales.
- Los jugadores de una sala reciben cartones con las mismas acciones disponibles, pero mezcladas de forma independiente.
- La sala muestra el marcador en tiempo real cuando Firebase está activo.

## Siguiente nivel de producción

Antes de publicar conviene agregar persistencia local de deportes personalizados, recuperación de contraseña, reglas Firebase más estrictas, eliminación de salas antiguas, pruebas de integración y notificaciones de reconexión.
