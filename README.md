# Veterinaria EIVET

Aplicación Flutter para móvil y web de gestión veterinaria, con Supabase como backend y base de datos.

## Módulos

- App móvil para clientes: autenticación, registro y gestión de mascotas, solicitudes de citas, consulta de cuidados clínicos, preferencias, ubicación, clima y mapa.
- Panel administrativo web: gestión de propietarios, mascotas, citas, consultas, tratamientos y vacunas.
- Interfaces de referencia en `stitch_eivet_panel_administrativo_web/` y `stitch_veterinary_app_interface_design/`.

## Supabase

Configura `config/local.json` usando `config/local.example.json` como guía. El archivo local no debe subirse al repositorio. Define `APP_MODE`, `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`.

Ejecuta los SQL en el orden explicado en [docs/SUPABASE_EIVET.md](docs/SUPABASE_EIVET.md). Los archivos describen el esquema esperado; confirma en el panel Supabase que se aplicaron correctamente.

## Desarrollo

```bash
flutter pub get
flutter run --dart-define-from-file=config/local.json
```

### Ejecutar desde Visual Studio Code

Abre **Run and Debug** (`Ctrl+Shift+D`) y elige una de estas configuraciones:

- **EIVET · Móvil Android · Supabase**: inicia la app en el dispositivo o emulador Android seleccionado.
- **EIVET · Web · Supabase**: abre el panel administrativo en Chrome.

Ambas usan `config/local.json`, que debe existir localmente y contener la URL y publishable key de Supabase. Para Android, conecta o inicia un emulador antes de ejecutar.

En Windows también puedes ejecutar `scripts/03_EJECUTAR_SUPABASE_WINDOWS.bat`.

## Plataformas

El proyecto contiene configuración Flutter para Android y Web. Para compilar Android:

```bash
flutter build apk --release --dart-define-from-file=config/local.json
```

La carpeta `stitch_*` contiene diseños de interfaz de referencia y se conserva como parte del proyecto.
