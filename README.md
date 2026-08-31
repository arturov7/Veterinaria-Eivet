# VETERINARIA EIVET - PROYECTO FINAL 360

Aplicación móvil académica para clientes de la Veterinaria EIVET. Conserva
los componentes solicitados: consulta de fichas de mascotas,
preferencias locales, API REST meteorológica, GPS, mapa, estados de carga,
error con reintento y dato de respaldo offline.

## Hilo conductor

Sesión 1:
pantallas + navegación + preferencias + consulta local.

Sesión 2:
Future + async/await + loading + API REST + JSON + modelo + error/reintento + GPS + mapa + contexto + persistencia local.

NO es otro proyecto. Es el mismo sistema creciendo.

## Windows

1. Extrae en una ruta corta, por ejemplo:
   `C:\flutter_aula\PROYECTO_FINAL_360_SESION2_FINAL`
2. Ejecuta:
   `scripts\00_PREPARAR_WINDOWS.bat`
3. Luego:
   `scripts\01_MENU_WINDOWS.bat`
4. Inicia la aplicación en un dispositivo o emulador Android.

Windows Desktop NO es requisito para esta clase.

## MX Linux / Linux

1. Extrae dentro de tu HOME.
2. Ejecuta:
   `chmod +x scripts/*.sh`
3. Luego:
   `./scripts/00_PREPARAR_LINUX.sh`
4. Después:
   `./scripts/01_MENU_LINUX.sh`

Si aparece Ninja:
`./scripts/98_REPARAR_NINJA_LINUX.sh`

## Modo local de demostración

- Fichas de mascotas disponibles para consulta.
- API real al pulsar el botón.
- Mapa real con Internet.
- GPS solo cuando el cliente lo solicita.
- Error controlado, reintento y dato de respaldo offline.
- Funciona completamente en el dispositivo, sin servicios remotos de cuentas ni base de datos.

## Modo API NestJS

La app está preparada para un backend NestJS REST, sin modificar las pantallas. El contrato completo está en `docs/07_CONTRATO_API_NESTJS.md`.

1. Copia `config/api.example.json` como `config/api.json`.
2. Define `API_BASE_URL` (en emulador Android suele ser `http://10.0.2.2:3000/api/`).
3. Implementa las rutas y los campos definidos en el contrato API.
4. Selecciona **API NestJS - Android** en el menú.

Sin `config/api.json`, utiliza siempre **DEMO local** para la defensa.

## Regla de estabilidad

Durante la clase:
`flutter pub get` SI
`flutter pub upgrade` NO
