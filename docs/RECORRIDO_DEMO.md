# Recorrido DEMO para la defensa

Este es el orden recomendado para una demostración estable de 7 a 10 minutos. Ejecutar la aplicación con datos DEMO y tener el teléfono o emulador cargado antes de comenzar.

## Preparación antes de exponer

1. Abrir el proyecto en Visual Studio Code.
2. Confirmar que `config/demo.json` contiene `APP_MODE: demo`.
3. Ejecutar la aplicación en Android y esperar la pantalla **Veterinaria EIVET**.
4. Tener conexión a Internet si se demostrará el mapa; si no, usar el dato de respaldo.
5. No borrar datos de la aplicación durante la exposición, porque así se conserva la preferencia de bienvenida.

## Comprobación previa de compilación

Antes de conectar el dispositivo, verificar que el proyecto compile:

```powershell
flutter build apk --debug
```

Si termina con `Built build\\app\\outputs\\flutter-apk\\app-debug.apk`, la aplicación está compilada y lista para instalar o ejecutar en Android. Esta comprobación no sustituye `flutter run`; solo valida que el APK puede generarse.

## Modo DEMO estable

La defensa debe ejecutarse con `config/demo.json`:

```powershell
flutter run --dart-define-from-file=config/demo.json
```

Este modo usa repositorios en memoria, no necesita Supabase, Firebase ni NestJS, y permite crear, consultar, reprogramar y cancelar solicitudes de citas. No cambiar a `config/api.example.json` durante la exposición. Si una consulta externa falla, continuar con los datos DEMO y el dato de respaldo.

## Diseño EIVET

La interfaz se basa en la referencia visual de `stitch_veterinary_app_interface_design`: bienvenida con identidad veterinaria, inicio con tarjetas de servicios, navegación inferior, fichas de mascotas y formularios de citas. Se aplicaron la paleta verde de EIVET, superficies claras, bordes redondeados, iconografía de mascotas y jerarquía visual para lectura rápida.

Los diseños HTML y PNG se usaron únicamente como referencia. Las pantallas finales son widgets Flutter nativos, adaptables a Android y conectados al estado real de la aplicación; los HTML no se ejecutan dentro del proyecto.

## Autenticación

En la defensa se utiliza el acceso DEMO mediante **Comenzar** en la bienvenida. No se introducen credenciales reales, no se almacenan contraseñas y no se habilita registro público. `SharedPreferences` solo conserva que la bienvenida ya fue mostrada.

Si el docente pregunta por la autenticación real, responder: “La validación de usuario, contraseña y token depende del contrato de NestJS. El proyecto dejó separada la configuración DEMO/API para incorporar ese endpoint sin cambiar las pantallas ni usar Supabase o Firebase.”

## Navegación

Después de pulsar **Comenzar**, usar exclusivamente la barra inferior para desplazarse: **Inicio → Mis mascotas → Citas → Perfil**. Desde Inicio abrir **Clima y ubicación** solo cuando se vaya a demostrar GPS y mapa. Para volver, utilizar la flecha de la barra superior o la opción inferior correspondiente; evitar cerrar la aplicación o usar el botón Atrás repetidamente.

## Mascotas

1. Pulsar **Mis mascotas** en la barra inferior.
2. Esperar a que desaparezca el indicador de carga.
3. Mostrar la tarjeta de la mascota DEMO y abrir sus detalles si se solicita.
4. Explicar que los datos provienen del repositorio en memoria y que la pantalla es de solo lectura.
5. No buscar botones de registro, edición o eliminación: esas acciones no están habilitadas para el cliente.

## CRUD de citas

1. Pulsar **Citas** y esperar la carga inicial.
2. Pulsar el botón de nueva solicitud.
3. Seleccionar la mascota DEMO, elegir una fecha futura y una hora disponible.
4. Escribir el motivo **Consulta general** y guardar.
5. Mostrar la solicitud creada en la lista.
6. Abrir sus acciones, modificar fecha u hora y pulsar **Solicitar reprogramación**.
7. Volver a abrir la solicitud, elegir **Cancelar solicitud** y confirmar.
8. Explicar que las cuatro operaciones son asíncronas y funcionan en el repositorio DEMO en memoria; el repositorio API usa los endpoints documentados para NestJS.

## Vacunas

1. Regresar a **Inicio** mediante la barra inferior.
2. Ubicar la tarjeta o servicio **Vacunas**.
3. Pulsar **Consultar** para mostrar el aviso del calendario de vacunación de EIVET.
4. Explicar que este aviso orienta al cliente para coordinar la atención.
5. Aclarar que el historial clínico y el detalle de vacunas se mostrarán cuando EIVET defina los datos autorizados; el cliente no puede editarlos.

## Historial clínico

El historial clínico detallado no se demuestra como un módulo editable en esta versión. Al mostrar la ficha de la mascota, explicar que las notas disponibles son únicamente datos de consulta registrados por EIVET y que el expediente completo debe protegerse bajo control del personal veterinario.

Respuesta sugerida si el docente pregunta: “La estructura está preparada para ampliar el modelo y el endpoint API, pero no se inventaron diagnósticos ni tratamientos. La función queda pendiente hasta contar con el contrato NestJS, datos reales autorizados y reglas de privacidad.”

## Notificaciones

1. Crear o cancelar una solicitud de cita.
2. Mostrar que la lista se actualiza y que aparece el resultado de la operación en español.
3. Si ocurre un problema, mostrar el mensaje de error y el botón **Reintentar**.
4. Explicar que son avisos internos de la aplicación, sin permisos de notificaciones push.
5. Aclarar que los recordatorios y confirmaciones push quedan para la integración futura con NestJS.

## Perfil

1. Pulsar **Perfil** en la barra inferior.
2. Mostrar el nombre del cliente y pulsar **Guardar cambios** para comprobar el mensaje de confirmación.
3. Activar o desactivar **Tema oscuro** y explicar que la preferencia queda guardada localmente.
4. Mostrar **Fuente de datos: DEMO local** para confirmar que la defensa no depende del backend.
5. Abrir **Sobre la aplicación** únicamente si el docente solicita detalles técnicos; contiene la explicación de la adaptación.

## Contacto, GPS y mapa

1. Desde **Inicio**, explicar que los avisos de servicios indican coordinar la atención directamente con EIVET.
2. Abrir **Clima y ubicación** desde el servicio destacado.
3. Pulsar **Consultar clima en Tarija** para mostrar inmediatamente el mapa y el marcador de referencia.
4. Si hay permiso y señal GPS, pulsar **Usar mi ubicación** y aceptar el permiso Android.
5. Mostrar las coordenadas, el clima y el marcador de OpenStreetMap.
6. Si el docente solicita teléfono, dirección u horario, indicar que deben reemplazarse por los datos oficiales de EIVET antes de la presentación institucional; no inventar información.

## Modo API

El modo API se explica como integración posterior con NestJS y no se activa durante la defensa DEMO. Para probarlo con un backend disponible:

```powershell
flutter run --dart-define-from-file=config/api.example.json
```

La configuración de ejemplo apunta al emulador Android mediante `http://10.0.2.2:3000/api/`. El contrato documentado contempla únicamente `GET /mascotas` y el CRUD de `solicitudes-citas` (`GET`, `POST`, `PATCH` y `DELETE`). Si NestJS no está disponible, la aplicación debe volver a ejecutarse con `config/demo.json`.

## Secuencia exacta

1. **Bienvenida y acceso DEMO (30 s).** Mostrar el nombre EIVET y pulsar **Comenzar** una sola vez.
2. **Inicio (45 s).** Mostrar el saludo, los servicios y el acceso inferior. Explicar que es una aplicación exclusiva para clientes.
3. **Mis mascotas (60 s).** Entrar desde la navegación inferior. Esperar la carga y mostrar la mascota DEMO. Explicar que es consulta solamente: no existen botones para crear, editar o eliminar mascotas.
4. **Crear cita (60 s).** Entrar en **Citas**, pulsar el botón de nueva solicitud, seleccionar la mascota, elegir una fecha y hora futuras, escribir “Consulta general” y guardar.
5. **Consultar y reprogramar (60 s).** Mostrar la solicitud creada, abrir sus acciones, cambiar fecha u hora y confirmar **Solicitar reprogramación**. Comprobar que la lista refleja el cambio.
6. **Cancelar cita (30 s).** Elegir **Cancelar solicitud**, leer la confirmación y aceptar. Explicar que este es el CRUD académico.
7. **GPS y mapa (75 s).** Abrir **Clima y ubicación** desde el servicio correspondiente. Para evitar depender del permiso, pulsar primero **Consultar clima en Tarija** y mostrar el marcador. Si el dispositivo permite GPS, pulsar **Usar mi ubicación** y aceptar el permiso.
8. **Error y recuperación (45 s).** Pulsar **Simular error de conexión**, mostrar el mensaje y pulsar **Reintentar** o **Usar dato de respaldo**. Explicar los estados loading, ready y error.
9. **Preferencias (30 s).** Abrir **Perfil** y mostrar el ajuste de tema o la información de la aplicación. Explicar que `SharedPreferences` conserva preferencias locales.
10. **Cierre técnico (45 s).** Indicar que Provider conecta las pantallas con repositorios DEMO/API, que el contrato NestJS está documentado y que no se utiliza Supabase ni Firebase.

## Si algo falla durante la exposición

- Si aparece un error de red, pulsar **Reintentar** y luego **Usar dato de respaldo**.
- Si el GPS no tiene permiso, volver a **Consultar clima en Tarija**; la demostración no depende del GPS real.
- Si no aparece la mascota, volver a **Mis mascotas** y esperar el indicador de carga antes de pulsar otra opción.
- Si se cancela una cita por error, crear otra solicitud DEMO y continuar con ella.
- No cambiar a modo API durante la defensa; ese modo se explica como integración futura con NestJS.

## Frase final sugerida

“La aplicación demuestra un flujo completo para clientes de EIVET: consulta de mascotas, CRUD de solicitudes, preferencias, consumo REST preparado, GPS, mapa y recuperación ante errores. El modo DEMO garantiza que todas las funciones se puedan defender aunque el backend no esté disponible.”

## Guion breve de emergencia

Si solo hay unos minutos, decir y mostrar lo siguiente:

“Esta es la aplicación móvil de clientes de la Veterinaria EIVET. Desde Inicio puedo consultar las mascotas registradas, sin modificarlas. En Citas creo una solicitud seleccionando mascota, fecha, hora y motivo; luego puedo consultarla, pedir reprogramación o cancelarla. Provider controla el estado y el repositorio DEMO permite trabajar sin backend. Finalmente muestro Clima y ubicación, donde el GPS y el mapa funcionan con permiso del usuario y existe un dato de respaldo si falla la conexión.”

Mostrar, en este orden, Inicio → Mis mascotas → crear cita → cancelar cita → dato de respaldo del mapa. Cerrar indicando que el contrato REST para NestJS está documentado.

## Prioridades si falta tiempo o aparece un bloqueo

1. Mostrar la pantalla Inicio y explicar el objetivo de EIVET.
2. Mostrar **Mis mascotas** y aclarar que es consulta de registros veterinarios.
3. Ejecutar el CRUD mínimo de citas: crear y consultar una solicitud.
4. Completar el CRUD con reprogramar y cancelar si el tiempo lo permite.
5. Mostrar Provider, modo DEMO y persistencia local durante la explicación técnica.
6. Mostrar GPS y mapa usando **Consultar clima en Tarija**; si falla Internet, usar **Dato de respaldo**.
7. Mostrar la simulación de error y el botón **Reintentar** solo si la aplicación está estable.
8. Omitir funcionalidades pendientes y notificaciones push; explicarlas verbalmente como trabajo futuro.
