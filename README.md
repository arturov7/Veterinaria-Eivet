# Veterinaria EIVET

Aplicación Flutter para móvil y web de gestión veterinaria, con Supabase como backend y base de datos.

## Módulos

- App móvil para clientes: autenticación, registro y gestión de mascotas, solicitudes de citas, consulta de cuidados clínicos, preferencias, ubicación, clima y mapa.
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

La carpeta `stitch_*` contiene diseños de interfaz de referencia y se conserva como parte del proyecto.

## Despliegue web en Netlify

Configura `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY` como variables de entorno disponibles durante el build. El archivo `.env` local no se sube al repositorio.

El archivo `netlify.toml` define el comando y el directorio de publicación. `scripts/build_netlify.sh` instala Flutter 3.44.8 (la versión del entorno local), descarga las dependencias y compila usando las variables de Netlify. No requiere instalar una integración de Flutter. Si Netlify solicita un comando de compilación, usa:

```bash
bash scripts/build_netlify.sh
```

Directorio de publicación: `build/web`. Guarda `netlify.toml` y el script en el repositorio. Su configuración tiene prioridad sobre el comando y directorio definidos en el panel de Netlify. Los cambios enviados a la rama de producción conectada se publican automáticamente. Para actualizar el SDK, cambia `FLUTTER_VERSION` en `netlify.toml`.

La publishable key de Supabase es pública y forma parte de la aplicación compilada. `.env` evita guardar sus valores en el código fuente y en Git; no los convierte en secretos del navegador. Las claves `service_role` y `sb_secret_` deben mantenerse exclusivamente en el servidor. La función `crear-propietario` obtiene su clave de servicio del entorno de Supabase.
