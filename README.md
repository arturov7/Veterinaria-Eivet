# Veterinaria EIVET

Aplicación móvil Flutter para la gestión de mascotas y solicitudes de citas de clientes de la Veterinaria EIVET.

## Descripción

Veterinaria EIVET está dirigida a clientes de la veterinaria para centralizar la información de sus mascotas, consultar servicios, solicitar atención y revisar contexto de ubicación y clima. La aplicación puede ejecutarse en modo demostración con datos locales o conectarse a Supabase para autenticación y persistencia de mascotas y citas.

## Problema que resuelve

La aplicación reduce la dispersión de la información de los clientes al ofrecer un único canal móvil para registrar mascotas, administrar sus datos y gestionar solicitudes de citas veterinarias.

## Funcionalidades

- Registro, edición, consulta y eliminación de mascotas, con nombre, especie, raza, sexo, fecha de nacimiento y URL de fotografía.
- Visualización de información y servicios veterinarios destacados.
- Creación, edición y cancelación de solicitudes de citas asociadas a una mascota.
- Autenticación con Supabase: inicio de sesión, registro de cuenta, recuperación y cierre de sesión.
- Persistencia de mascotas y citas en Supabase cuando se habilita el modo remoto.
- Modo demostración local para usar la aplicación sin credenciales de Supabase.
- Preferencias locales de nombre y tema claro/oscuro mediante `SharedPreferences`.
- Consulta de ubicación mediante GPS, clima actual mediante Open-Meteo y visualización en un mapa de OpenStreetMap.
- Manejo de errores de red, reintentos y dato de respaldo sin conexión para el módulo de contexto.

## Tecnologías

- Flutter y Dart.
- Material 3 para la interfaz de usuario.
- `provider` para inyección de dependencias y gestión de estado con `ChangeNotifier`.
- `supabase_flutter` para autenticación y persistencia remota.
- `shared_preferences` para preferencias locales.
- `http` para consultas HTTP a Open-Meteo.
- `geolocator` para permisos y posición del dispositivo.
- `flutter_map` y `latlong2` para mapas de OpenStreetMap.
- `flutter_secure_storage` como dependencia de almacenamiento seguro de Flutter.
- Android Gradle Plugin, Kotlin y Java 17 para la plataforma Android.

## Requisitos

- Flutter `>=3.35.0`
- Dart `>=3.9.0 <4.0.0`
- Android SDK
- Java 17
- Git
- Dispositivo Android o emulador

## Instalación

```bash
git clone https://github.com/arturov7/modulo3.git
cd PROYECTO_FINAL_360_SESION2_FINAL
flutter pub get
```

## Configuración

La aplicación se inicia en modo demostración si no se proporcionan credenciales. Para utilizar Supabase, cree un archivo local de configuración a partir de `config/local.example.json` y proporcione únicamente estas variables:

- `APP_MODE`
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

No incluya valores reales de estas variables, contraseñas, tokens, archivos `android/key.properties`, certificados `.jks` ni archivos `.keystore` en el repositorio.

Ejecute la aplicación con el archivo de configuración local:

```bash
flutter run --dart-define-from-file=config/local.json
```

Para utilizar el modo demostración:

```bash
flutter run --dart-define-from-file=config/demo.json
```

## Compilación Android

```bash
flutter build apk --release --dart-define-from-file=config/local.json
```

El APK se genera en `build/app/outputs/flutter-apk/app-release.apk`.

## Arquitectura

El proyecto se organiza por responsabilidades:

- `lib/screens`: pantallas y flujo de navegación.
- `lib/widgets`: componentes reutilizables de interfaz.
- `lib/controllers`: estado de preferencias y contexto de ubicación/clima.
- `lib/services`: autenticación, preferencias, ubicación y clima.
- `lib/repositories`: contratos y fuentes de datos demo o Supabase.
- `lib/models`: entidades y transformadores de datos.
- `lib/config`: lectura de la configuración de ejecución.
