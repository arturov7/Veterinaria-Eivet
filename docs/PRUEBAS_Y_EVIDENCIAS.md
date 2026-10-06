# Pruebas y evidencias de EIVET

Fecha de ejecución: 03/10/2026 (America/La_Paz). Entorno: web publicada en Netlify y función `salud` publicada en Supabase. No se usaron datos personales reales.

| ID | Escenario | Resultado esperado | Resultado observado | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- |
| CP-01 | Abrir el panel web público | La URL responde y carga el panel | Se observó la página «Veterinaria EIVET · Panel Clínico» en `https://eivetveterinaria.netlify.app/` | Aprobado para disponibilidad de la página; flujos internos pendientes | URL pública; captura fechada pendiente |
| CP-02 | Consultar `GET /functions/v1/salud` | HTTP 200 y `{"status":"online"}` | HTTP 200 y `{"status":"online"}` | Aprobado | Salida de `scripts/verify_salud.ps1`, 03/10/2026; captura fechada pendiente |
| CP-03 | Consultar `HEAD /functions/v1/salud` | HTTP 200 sin cuerpo | HTTP 200 sin cuerpo | Aprobado | Salida de `scripts/verify_salud.ps1`, 03/10/2026 |
| CP-04 | Enviar `POST /functions/v1/salud` | HTTP 405 | HTTP 200 y `{"status":"online"}` | Fallido: la función publicada no coincide con el contrato del código local | Salida de `scripts/verify_salud.ps1`, 03/10/2026 |
| CP-05 | Acceso cruzado entre dos propietarios | Cada cuenta ve solo sus mascotas y citas; no modifica las ajenas | No hay resultado observado de dos cuentas en producción | Pendiente | Ejecutar `supabase/14_VERIFICAR_RLS_DOS_CUENTAS.sql` con cuentas ficticias y registrar resultado |
| CP-06 | Registro, consulta, edición y eliminación de mascotas por personal | Administrador y veterinario pueden operar; propietario solo consulta | No hay ejecución integral documentada en producción | Pendiente | Probar con usuarios ficticios de cada rol y conservar capturas |
| CP-07 | Prueba automatizada del repositorio demo | Las conversiones y operaciones demo satisfacen sus aserciones | Pendiente de registrar la salida final de `flutter test test/demo_repository_test.dart` | Pendiente | Esta prueba no acredita RLS ni operaciones de producción |

## Prueba automatizada de la ruta de salud

Desde la raíz del repositorio, en Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify_salud.ps1
```

El script evalúa GET, HEAD y POST contra la URL real. Devuelve código de salida `1` si falla un caso. En la ejecución del 03/10/2026 produjo:

```text
APROBADO GET: HTTP 200, esperado 200, respuesta {"status":"online"}
APROBADO HEAD: HTTP 200, esperado 200, respuesta
FALLIDO POST: HTTP 200, esperado 405, respuesta {"status":"online"}
```

Para cerrar CP-04, desplegar `supabase/functions/salud/index.ts` en el proyecto correcto y repetir el script. Una respuesta `online` demuestra que la RPC de comprobación respondió; no demuestra por sí sola que todos los módulos, permisos o flujos clínicos funcionen.

## Capturas de producción pendientes

Adjuntar capturas con fecha visible de la página web, de la respuesta GET de la ruta de salud y de los casos de roles/RLS una vez ejecutados. Ocultar nombres, correos, teléfonos, direcciones, tokens y datos clínicos reales. Ninguna captura se declara adjunta mientras no exista el archivo verificable.
