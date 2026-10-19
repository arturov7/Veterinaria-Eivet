# Pruebas y evidencias de EIVET

Ejecuciones documentadas: 03/10/2026 y 06/10/2026 (America/La_Paz). Entorno: web publicada en Netlify y funciones publicadas en Supabase. No se usaron datos personales reales.

| ID | Escenario | Resultado esperado | Resultado observado | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- |
| CP-01 | Abrir el panel web público | La URL responde y carga el panel | Se observó la página «Veterinaria EIVET · Panel Clínico» en `https://eivetveterinaria.netlify.app/` | Aprobado para disponibilidad de la página; flujos internos pendientes | URL pública; captura fechada pendiente |
| CP-02 | Consultar `GET /functions/v1/salud` | HTTP 200 y `{"status":"online"}` | HTTP 200 y `{"status":"online"}` el 03 y 06/10/2026 | Aprobado | [Salida fechada del 06/10/2026](evidencias/verify_salud_2026-10-06.txt); captura pendiente |
| CP-03 | Consultar `HEAD /functions/v1/salud` | HTTP 200 sin cuerpo | HTTP 200 sin cuerpo el 03 y 06/10/2026 | Aprobado | [Salida fechada del 06/10/2026](evidencias/verify_salud_2026-10-06.txt) |
| CP-04 | Enviar `POST /functions/v1/salud` | HTTP 405 | HTTP 200 y `{"status":"online"}` el 03 y 06/10/2026 | Fallido: la función publicada no coincide con el contrato del código local | [Salida fechada del 06/10/2026](evidencias/verify_salud_2026-10-06.txt) |
| CP-05 | Acceso cruzado entre dos propietarios | Cada cuenta ve solo sus mascotas y citas; no modifica las ajenas | No hay resultado observado de dos cuentas en producción | Pendiente | Ejecutar `supabase/14_VERIFICAR_RLS_DOS_CUENTAS.sql` con cuentas ficticias y registrar resultado |
| CP-06 | Registro, consulta, edición y eliminación de mascotas por personal | Administrador y veterinario pueden operar; propietario solo consulta | No hay ejecución integral documentada en producción | Pendiente | Probar con usuarios ficticios de cada rol y conservar capturas |
| CP-07 | Suite automatizada local: repositorios y controlador demo, conversión de clima | Las aserciones terminan sin fallos | `flutter test`: 7 pruebas aprobadas, salida `0`, 06/10/2026 | Aprobado en entorno local | [Reporte completo](evidencias/flutter_test_2026-10-06.txt); no acredita RLS ni operaciones de producción |
| CP-08 | `POST /functions/v1/crear-propietario` sin token | HTTP 401; sin creación de cuenta | HTTP 401 y `{"error":"Inicia sesión."}` el 06/10/2026; no se consultó Auth/BD | Aprobado solo para la respuesta 401 sin token | [Registro de la petición](evidencias/crear_propietario_sin_token_2026-10-06.txt) |
| CP-09 | `POST /functions/v1/crear-propietario` con token de veterinario ficticio | HTTP 403; sin creación de cuenta | No ejecutado | Pendiente | Requiere cuenta ficticia y comprobar Auth/BD antes y después |
| CP-10 | `POST /functions/v1/crear-propietario` con token de administrador ficticio | HTTP 201 y una cuenta ficticia creada | No ejecutado | Pendiente | Requiere cuenta de administrador y datos de prueba; verificar Auth y `clientes` |
| CP-11 | RF-01: login web con credenciales ficticias inválidas | Rechazo sin acceder al panel; mensaje de error | El 06/10/2026 permaneció en Iniciar Sesión y mostró «Correo o contraseña incorrectos. Verifica los datos e inténtalo de nuevo.» | Aprobado solo para este camino de error de RF-01 | [Captura](evidencias/rf01_login_invalido_2026-10-06.jpg) y [registro fechado](evidencias/rf01_login_invalido_2026-10-06.txt) |

## Estado de los cuatro Must en producción

| Requisito | Camino feliz | Camino de error | Alcance observado |
| --- | --- | --- | --- |
| RF-01 Inicio de sesión | Pendiente: acceso válido con cuenta ficticia autorizada | CP-11 observado: credenciales inválidas rechazadas | Solo panel web; no se midió el HTTP de Auth |
| RF-02 Propietario y mascota | Pendiente: administrador crea cuenta y personal registra mascota de titular único | Pendiente: propietario no crea mascota y titular inválido se rechaza | CP-05 y CP-06 sin ejecución integral |
| RF-03 Consulta | Pendiente: registrar consulta para mascota ficticia | Pendiente: rechazar consulta sin mascota válida | Sin ejecución documentada |
| RF-04 Historial | Pendiente: mostrar consultas anteriores de mascota ficticia | Pendiente: estado vacío de mascota sin consultas | Sin ejecución documentada |

## Procedimiento pendiente para permisos en producción

1. Confirmar primero RLS y políticas efectivas con `supabase/VERIFICAR_ESTADO_RLS_12_13.sql`. No interpretar la existencia de archivos SQL como una migración aplicada.
2. Preparar dos propietarios ficticios A y B con una mascota ficticia cada uno. Con sesiones reales, probar lectura propia y ajena en ambos sentidos. Una lectura ajena filtrada por RLS puede responder HTTP 200 con lista vacía.
3. Con cada propietario, intentar actualizar la mascota ajena y crear una nueva. Registrar código HTTP, cuerpo depurado y conteo de filas antes y después. Una actualización bloqueada puede afectar cero filas sin devolver 403; el criterio es que ningún dato ajeno cambie.
4. Invocar `crear-propietario` sin token (CP-08), con veterinario ficticio (CP-09) y con administrador ficticio (CP-10). Comprobar en Authentication y `clientes` que el 403 no creó cuenta y que el caso autorizado creó una sola cuenta ficticia.
5. Guardar fecha, URL, rol ficticio, resultado esperado, resultado observado y capturas sin contraseñas, tokens ni datos personales o clínicos reales. No marcar CP-05, CP-06, CP-09 o CP-10 como aprobados hasta ejecutar y verificar sus efectos.

## Suite Flutter local

Desde la raíz del repositorio:

```bash
flutter test
```

El 06/10/2026 se retiró `test/widget_test.dart`, prueba de ejemplo del contador que hacía referencia a `MyApp`, clase inexistente en EIVET. La nueva ejecución terminó con siete pruebas aprobadas y código `0`; el [reporte fechado](evidencias/flutter_test_2026-10-06.txt) conserva la salida. No prueba autenticación, políticas RLS ni los cuatro requisitos Must en producción.

## Prueba automatizada de la ruta de salud

Desde la raíz del repositorio, en Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify_salud.ps1
```

El script evalúa GET, HEAD y POST contra la URL real. Devuelve código de salida `1` si falla un caso. El 06/10/2026 volvió a producir el mismo resultado que el 03/10/2026:

```text
APROBADO GET: HTTP 200, esperado 200, respuesta {"status":"online"}
APROBADO HEAD: HTTP 200, esperado 200, respuesta
FALLIDO POST: HTTP 200, esperado 405, respuesta {"status":"online"}
```

Para cerrar CP-04, desplegar `supabase/functions/salud/index.ts` en el proyecto correcto y repetir el script. En esta sesión no había CLI de Supabase ni sesión de despliegue disponible, por lo que no se sincronizó la función. Una respuesta `online` demuestra que la RPC de comprobación respondió; no demuestra por sí sola que todos los módulos, permisos o flujos clínicos funcionen.

## Capturas de producción pendientes

Adjuntar capturas con fecha visible de la página web, de la respuesta GET de la ruta de salud y de los casos de roles/RLS una vez ejecutados. Ocultar nombres, correos, teléfonos, direcciones, tokens y datos clínicos reales. Ninguna captura se declara adjunta mientras no exista el archivo verificable.
