# Veterinaria EIVET

Aplicación Flutter para móvil y web de gestión veterinaria, con Supabase como backend y base de datos.

## Enlaces del proyecto

- [Repositorio de código](https://github.com/arturov7/Veterinaria-Eivet)
- [Tablero Kanban en GitHub Projects](https://github.com/users/arturov7/projects/2/views/1?layout=board) (el acceso depende de los permisos del proyecto).
- [Panel web publicado en Netlify](https://eivetveterinaria.netlify.app/)
- [Ruta de salud de Supabase](https://xbvjhrfgznljtwxghvka.supabase.co/functions/v1/salud)

La ruta de salud respondió `200` con `{"status":"online"}` en las comprobaciones del 03/10/2026 y 06/10/2026. La prueba automatizada `scripts/verify_salud.ps1` detectó una diferencia pendiente: la versión publicada acepta `POST` con `200`, aunque el código del repositorio exige `405`. Los resultados y límites de las demás pruebas constan en [docs/PRUEBAS_Y_EVIDENCIAS.md](docs/PRUEBAS_Y_EVIDENCIAS.md).

## Módulos

- App móvil para propietarios: autenticación, consulta de sus mascotas y datos clínicos, solicitudes de citas, preferencias, ubicación, clima y mapa. El registro, la edición y la eliminación de mascotas corresponden al administrador y al veterinario.
- Panel administrativo web: gestión de propietarios, mascotas, citas, consultas, tratamientos y vacunas.
- Interfaces de referencia en `stitch_eivet_panel_administrativo_web/` y `stitch_veterinary_app_interface_design/`.

## Supabase

Configura `.env` usando `.env.example` como guía. El archivo local no debe subirse al repositorio. Define `APP_MODE`, `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`.

En un clon nuevo, copia `.env.example` a `.env` y completa sus valores. Flutter los recibe al ejecutar o compilar con `--dart-define-from-file=.env`; el archivo no se registra como un asset de la aplicación.

Ejecuta los SQL en el orden explicado en [docs/SUPABASE_EIVET.md](docs/SUPABASE_EIVET.md). Los archivos describen el esquema esperado; confirma en el panel Supabase que se aplicaron correctamente.

## Desarrollo

```bash
flutter pub get
flutter run --dart-define-from-file=.env
```

### Ejecutar desde Visual Studio Code

Abre **Run and Debug** (`Ctrl+Shift+D`) y elige una de estas configuraciones:

- **EIVET · Móvil Android · Supabase**: inicia la app en el dispositivo o emulador Android seleccionado.
- **EIVET · Web · Supabase**: abre el panel administrativo en Chrome.

Ambas usan `.env`, que debe existir localmente y contener la URL y publishable key de Supabase. Para Android, conecta o inicia un emulador antes de ejecutar.

En Windows también puedes ejecutar `scripts/03_EJECUTAR_SUPABASE_WINDOWS.bat`.

## Plataformas

El proyecto contiene configuración Flutter para Android y Web. Para compilar Android:

```bash
flutter build apk --release --dart-define-from-file=.env
```

Para generar un APK solo para dispositivos ARM64:

```bash
flutter build apk --release --target-platform android-arm64 --dart-define-from-file=.env
```

El APK local existente no acredita una compilación de la revisión final ni una instalación en un dispositivo. Registra la revisión Git, la versión, la huella del archivo y la evidencia de instalación antes de distribuirlo.

La carpeta `stitch_*` contiene diseños de interfaz de referencia y se conserva como parte del proyecto.

La medición de la ruta pública de salud y su alcance están en [docs/RENDIMIENTO_PRODUCCION.md](docs/RENDIMIENTO_PRODUCCION.md). La versión de trabajo de la monografía E4 está en [Vedia_Salazar_Monografia_E4_adaptada.docx](Vedia_Salazar_Monografia_E4_adaptada.docx).

## Pruebas locales

```bash
flutter test
```

La suite local terminó con código de salida `0` el 06/10/2026: siete pruebas aprobadas. Consulta el [reporte completo](docs/evidencias/flutter_test_2026-10-06.txt). Estas pruebas cubren lógica demo y conversión de datos; no verifican RLS ni los flujos de producción. Los casos ejecutados y pendientes se distinguen en [docs/PRUEBAS_Y_EVIDENCIAS.md](docs/PRUEBAS_Y_EVIDENCIAS.md).

## Despliegue web en Netlify

Configura `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY` como variables de entorno disponibles durante el build. El archivo `.env` local no se sube al repositorio.

El archivo `netlify.toml` define el comando y el directorio de publicación. `scripts/build_netlify.sh` instala Flutter 3.44.8 (la versión del entorno local), descarga las dependencias y compila usando las variables de Netlify. No requiere instalar una integración de Flutter. Si Netlify solicita un comando de compilación, usa:

```bash
bash scripts/build_netlify.sh
```

Directorio de publicación: `build/web`. Guarda `netlify.toml` y el script en el repositorio. Su configuración tiene prioridad sobre el comando y directorio definidos en el panel de Netlify. Los cambios enviados a la rama de producción conectada se publican automáticamente. Para actualizar el SDK, cambia `FLUTTER_VERSION` en `netlify.toml`.

La publishable key de Supabase es pública y forma parte de la aplicación compilada. `.env` evita guardar sus valores en el código fuente y en Git; no los convierte en secretos del navegador. Las claves `service_role` y `sb_secret_` deben mantenerse exclusivamente en el servidor. La función `crear-propietario` obtiene su clave de servicio del entorno de Supabase.
