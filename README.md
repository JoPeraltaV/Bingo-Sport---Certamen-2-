# Bingo Sport

Bingo Sport es una aplicación desarrollada en Flutter que convierte un partido deportivo en un juego de bingo interactivo. Los jugadores pueden crear cartones personalizados utilizando acciones deportivas, marcar las jugadas a medida que ocurren durante un partido y competir por completar líneas o el cartón completo.

La aplicación fue desarrollada siguiendo una arquitectura organizada y reutilizable, separando la interfaz y los servicios para facilitar el mantenimiento y futuras mejoras.

---

# Objetivos del proyecto

- Desarrollar una aplicación móvil utilizando Flutter.
- Implementar autenticación de usuarios.
- Utilizar manejo de estado.
- Aplicar reutilización de componentes.
- Incorporar animaciones.
- Implementar un modo multijugador mediante Firebase y códigos QR.
- Mantener una arquitectura limpia y organizada.

---

# Características principales

- Inicio de sesión con validación.
- Registro de usuarios.
- Deportes predeterminados.
- Creación de deportes personalizados.
- Acciones predeterminadas.
- Acciones creadas por el usuario.

Cartones de:

- 3x3
- 4x4
- 5x5

- Sistema de puntuación por líneas.
- Victoria al completar todo el cartón.
- Animaciones de interfaz.
- Creación de salas online.
- Unión mediante código o código QR.

Preparado para Firebase Authentication y Firebase Realtime Database.

---

# Tecnologías utilizadas

- Flutter
- Dart
- Supabase Authentication
- Supabase Database (PostgreSQL)
- Supabase Realtime      
- QR Flutter
- Mobile Scanner
- Git
- GitHub

---

# Arquitectura del proyecto

El proyecto está dividido en distintas capas para separar responsabilidades.

```
lib/
│
├── modelos/
├── pantallas/
├── widgets/
├── servicios/
├── estado/
├── datos/
├── tema/
└── main.dart
```

La estructura general funciona de la siguiente manera:

```
Pantallas
      │
      ▼
Controlador (ChangeNotifier)
      │
      ▼
Servicios
      │
      ▼
Supabase

```

Cada parte cumple una función específica.

### Pantallas

Contienen únicamente la interfaz gráfica que ve el usuario.

Ejemplos:

- Login
- Inicio
- Crear partida
- Juego
- Sala Online

---

### Modelos

Representan la información de la aplicación.

Por ejemplo:

- Usuario
- Deporte
- Acción
- Sala
- Configuración de partida

Los modelos solamente almacenan datos.

---

### Servicios

Los servicios realizan operaciones específicas como:

- iniciar sesión
- registrarse
- crear salas
- conectarse a Firebase

Gracias a esto la lógica queda separada de la interfaz.

---

### Estado

El estado global de la aplicación se controla mediante **ChangeNotifier**.

Cuando cambia algún dato importante, como el puntaje o el usuario, el controlador ejecuta:

```dart
notifyListeners();
```

Esto actualiza automáticamente todos los widgets que están utilizando esa información.

---

# Manejo del estado

Se utilizó **ChangeNotifier** porque diferentes pantallas necesitan compartir la misma información.

Por ejemplo:

- usuario autenticado
- deporte seleccionado
- cartón actual
- puntaje
- sala online

En lugar de enviar estos datos entre todas las pantallas, el controlador mantiene un único estado global.

---

# Widgets reutilizados

Uno de los objetivos fue reutilizar componentes para evitar duplicar código.

Los principales widgets reutilizables son:

### BotonPrincipal

Se utiliza para:

- iniciar sesión
- registrarse
- crear partida
- guardar cambios
- crear deportes

Modificar este widget cambia todos los botones de la aplicación.

---

### CampoTexto

Se reutiliza para:

- correo
- contraseña
- nombre del deporte
- acciones personalizadas

---

### CeldaBingo

Representa cada casilla del cartón.

El mismo widget se utiliza para todas las posiciones del bingo.

---

### TarjetaDeporte

Muestra la información de cada deporte disponible.

---

### SelectorTamano

Permite elegir entre:

- 3x3
- 4x4
- 5x5

---

# Funcionamiento de la aplicación

## 1. Login

El usuario inicia sesión utilizando correo y contraseña.

Los datos son validados antes de ingresar.

---

## 2. Selección del deporte

Puede escoger un deporte existente o crear uno nuevo.

Cada deporte contiene su propio conjunto de acciones.

---

## 3. Configuración de la partida

El usuario selecciona:

- deporte
- tamaño del cartón
- acciones
- modo local u online

---

## 4. Generación del cartón

El sistema mezcla las acciones disponibles de forma aleatoria y genera el cartón.

Según el tamaño elegido:

3x3 → 9 casillas

4x4 → 16 casillas

5x5 → 25 casillas

---

## 5. Desarrollo del juego

Durante el partido el usuario marca las acciones cuando ocurren.

Cada vez que marca una casilla:

- cambia su apariencia
- reproduce una animación
- verifica si existe una nueva línea completa

---

# Sistema de puntuación

Se obtiene **1 punto** cada vez que se completa:

- una fila
- una columna
- una diagonal

Cada línea solamente puede entregar puntos una vez.

Para evitar sumar varias veces la misma línea se utiliza un **Set**, donde se almacenan las líneas ya premiadas.

Puntaje máximo:

| Cartón | Líneas posibles |
|---------|-----------------|
| 3x3 | 8 |
| 4x4 | 10 |
| 5x5 | 12 |

Cuando todas las casillas están marcadas el jugador gana la partida.

---

# Animaciones

La aplicación utiliza animaciones para mejorar la experiencia del usuario.

Entre ellas:

- transición entre pantallas
- selección de casillas
- aparición de formularios
- celebración al completar el cartón

Estas animaciones fueron implementadas utilizando widgets animados propios de Flutter.

---

# Modo Online

El modo online funciona mediante salas.

El jugador que crea la sala obtiene:

- código
- código QR

Los demás jugadores pueden ingresar:

- escribiendo el código
- escaneando el QR

Cuando Firebase está habilitado, todos los cambios se sincronizan automáticamente.

---

# Supabase

La aplicación utiliza **Supabase** como plataforma Backend as a Service (BaaS), permitiendo centralizar la autenticación de usuarios, el almacenamiento de la información y la sincronización de las partidas en tiempo real.

El proyecto utiliza los siguientes servicios de Supabase:

- **Authentication:** gestión de usuarios e inicio de sesión.
- **PostgreSQL Database:** almacenamiento de deportes, acciones, salas y datos de las partidas.
- **Realtime:** sincronización en tiempo real entre los jugadores conectados a una misma sala.

Gracias a Supabase, la aplicación puede:

- Registrar e iniciar sesión de usuarios.
- Almacenar información de los deportes y acciones.
- Crear y administrar salas de juego.
- Sincronizar el estado de las partidas en tiempo real.
- Actualizar automáticamente el puntaje y el progreso de los jugadores.

---

# Scripts incluidos

## preparar_proyecto.ps1

Script para Windows.

Automatiza:

- creación de plataformas Flutter
- restauración del proyecto
- permisos de cámara
- flutter pub get

---

## preparar_proyecto.sh

Versión equivalente para Linux y macOS.

---

# Instalación

Clonar el repositorio

```bash
git clone https://github.com/USUARIO/Bingo-Sport.git
```

Entrar al proyecto

```bash
cd bingo_sport
```

Instalar dependencias

```bash
flutter pub get
```

Ejecutar

```bash
flutter run
```

Para utilizar Firebase

```bash
flutter run --dart-define=USAR_FIREBASE=true
```

---

# Git y GitHub

Durante el desarrollo se utilizó Git para mantener un historial de cambios y GitHub para almacenar el proyecto de forma remota.

Comandos utilizados:

```bash
git add .
git commit -m "Descripción del cambio"
git push
```

Cuando el repositorio remoto ya contenía archivos fue necesario sincronizar ambos historiales utilizando:

```bash
git pull origin main --allow-unrelated-histories
```

---

# Decisiones de diseño

Durante el desarrollo se tomaron las siguientes decisiones:

- separar la lógica de negocio de la interfaz
- reutilizar widgets
- utilizar modelos para representar la información
- utilizar servicios independientes para autenticación y partidas
- implementar manejo de estado mediante ChangeNotifier
- preparar el proyecto para funcionar tanto localmente como con Firebase

Estas decisiones permiten que el proyecto sea más fácil de mantener y ampliar.

---

# Posibles mejoras

- perfil de usuario
- historial de partidas
- ranking global
- más deportes
- estadísticas
- notificaciones
- modo oscuro
- almacenamiento local permanente

