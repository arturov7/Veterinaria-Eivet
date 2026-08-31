# Guía breve para la defensa de Veterinaria EIVET

Duración sugerida: entre 7 y 10 minutos. La aplicación se presenta en modo **DEMO**, por lo que funciona aunque NestJS no esté disponible. Al final se puede explicar que el mismo Provider permite cambiar al modo **API** sin modificar las pantallas.

## 1. Presentación del problema (45 segundos)

“El problema identificado es que el cliente de la Veterinaria EIVET no cuenta con un canal móvil sencillo para consultar la información de sus mascotas y gestionar sus solicitudes de atención. Esto puede provocar llamadas repetitivas, pérdida de información y dificultad para dar seguimiento a una cita.”

“Como respuesta, se adaptó el proyecto Flutter entregado para crear una aplicación móvil Android centrada en el cliente. La solución permite consultar mascotas registradas, crear y dar seguimiento a solicitudes de citas, solicitar reprogramaciones y cancelar solicitudes, además de ofrecer información de ubicación y clima para apoyar el cuidado animal.”

“El objetivo es disponer de una aplicación funcional, estable y fácil de demostrar, que trabaje en modo DEMO aunque el backend todavía no esté disponible y que pueda conectarse posteriormente con NestJS.”

La aplicación es exclusivamente móvil para clientes. El cliente consulta sus mascotas; no puede crear, editar ni eliminar esos registros.

## 2. Objetivo de la aplicación (45 segundos)

“El objetivo general es desarrollar una aplicación móvil Android para los clientes de la Veterinaria EIVET, que centralice la consulta de mascotas y la gestión de solicitudes de citas de forma clara y segura.”

“Como objetivos específicos, la aplicación permite consultar mascotas registradas por la veterinaria, crear solicitudes de cita, consultar su estado, solicitar reprogramaciones y cancelarlas. También incorpora preferencias locales, modo DEMO, futura conexión REST con NestJS, GPS, mapa, estados de carga y recuperación ante errores.”

## 3. Usuarios (45 segundos)

“La aplicación está dirigida exclusivamente a los clientes de la Veterinaria EIVET. El usuario cliente puede consultar las mascotas que la veterinaria ya registró, revisar sus solicitudes de citas y gestionar el estado de esas solicitudes.”

“Por seguridad y por el alcance definido, el cliente no registra, edita ni elimina mascotas. Tampoco existe un sistema web administrativo dentro de este proyecto. La gestión de los registros clínicos corresponde posteriormente al personal autorizado y al backend de la veterinaria.”

“Para la defensa se utiliza un usuario y datos de demostración precargados. Esto permite recorrer las funciones sin depender de un registro real ni de un servidor activo.”

## 4. Arquitectura (1 minuto)

“La aplicación utiliza una arquitectura por capas dentro del proyecto Flutter. La interfaz no accede directamente a una API ni mantiene los datos en los widgets.”

El flujo principal es:

`Pantalla Flutter → Provider/ChangeNotifier → Repositorio o servicio → Modelo Dart → Pantalla`

- `screens/` contiene las pantallas y la navegación.
- `widgets/` contiene componentes visuales reutilizables.
- `controllers/` coordina estados, operaciones asíncronas, carga y errores.
- `repositories/` define el acceso a datos DEMO o API.
- `services/` encapsula GPS, clima y preferencias.
- `models/` convierte y valida la información como objetos Dart.
- `config/` selecciona el modo DEMO o API.

Esta separación permite cambiar el repositorio en memoria por NestJS manteniendo la misma interfaz y facilita las pruebas unitarias.

## 5. Demostración del inicio de sesión (45 segundos)

“La aplicación está preparada para un acceso de cliente en modo DEMO. En esta entrega no se habilita el registro público de usuarios ni se utiliza Supabase o Firebase. El acceso de demostración lleva al cliente a la bienvenida y conserva localmente que ya inició la aplicación mediante `SharedPreferences`.”

Demostrar el botón **Comenzar**, cerrar y volver a abrir la aplicación para comprobar que la bienvenida no se repite. Aclarar que, en modo API, este mismo punto se conectará al endpoint de autenticación de NestJS cuando el backend defina sus credenciales y tokens; las pantallas no tendrán que cambiar.

“Se evita almacenar contraseñas en el dispositivo. La aplicación solo conserva la preferencia local de bienvenida y trabaja con datos DEMO controlados.”

## 6. Navegación (45 segundos)

“La navegación inicia en la pantalla de bienvenida. Al pulsar **Comenzar**, se registra la preferencia local y se reemplaza la bienvenida por el inicio de la aplicación.”

Desde el inicio se utiliza una navegación inferior sencilla:

- **Inicio**: resumen de servicios e información de EIVET.
- **Mis mascotas**: consulta de mascotas registradas.
- **Citas**: consulta y CRUD de solicitudes.
- **Perfil**: preferencias y datos informativos del proyecto.

Las acciones secundarias se abren mediante rutas Flutter, por ejemplo el formulario de solicitud de cita y la pantalla de clima, GPS y mapa. Al volver, Provider conserva el estado actualizado sin colocar toda la lógica en `main.dart`.

## 7. Mascotas (1 minuto)

“En **Mis mascotas** el cliente consulta las mascotas que ya fueron registradas por la Veterinaria EIVET. La pantalla carga la información de forma asíncrona mediante Provider y el repositorio seleccionado en la configuración.”

En modo DEMO se utiliza un repositorio en memoria con datos de ejemplo. En modo API se realiza únicamente una consulta `GET /mascotas`, cuyo resultado JSON se convierte al modelo Dart `Registro` mediante un mapeador. La pantalla muestra nombre, especie, raza, edad y otros datos disponibles, además de estados de carga, error y reintento.

“Esta decisión respeta el alcance del sistema: el cliente no puede registrar, editar ni eliminar mascotas. Esas operaciones corresponden a la veterinaria y al backend administrativo futuro.”

## 8. CRUD de citas (1 minuto 30 segundos)

“El CRUD académico se adaptó al módulo de solicitudes de citas, porque el cliente no debe modificar la ficha clínica de sus mascotas.”

Demostrar en **Citas**:

1. **Crear**: pulsar el botón de nueva solicitud, elegir una mascota, fecha, hora y motivo.
2. **Consultar**: verificar que la nueva solicitud aparece con su estado.
3. **Reprogramar**: abrir la solicitud, cambiar fecha u hora y enviar la solicitud de reprogramación.
4. **Cancelar**: seleccionar **Cancelar solicitud** y confirmar la operación.

En DEMO, `DemoAppointmentRepository` ejecuta estas operaciones sobre una colección en memoria. En modo API, `ApiAppointmentRepository` utiliza los endpoints documentados: `GET` y `POST /solicitudes-citas`, `PATCH /solicitudes-citas/:id` y `DELETE /solicitudes-citas/:id`. La pantalla no cambia al cambiar de repositorio.

“Cada acción es asíncrona, muestra carga, informa errores y actualiza la lista al finalizar.”

## 9. Vacunas e historial (45 segundos)

“La aplicación presenta el servicio de **Vacunas** como orientación para el cliente. Desde el inicio se puede consultar el aviso del calendario de vacunación y coordinar la atención directamente con EIVET.”

En la ficha de cada mascota se muestran los datos que la veterinaria haya registrado, como especie, raza, género, nacimiento y notas. El historial clínico y el registro detallado de vacunas pertenecen al expediente veterinario: el cliente los consulta cuando estén disponibles, pero no puede editarlos ni eliminarlos desde la aplicación.

“Esta separación protege la información clínica y evita que el cliente modifique datos que solo debe administrar el personal autorizado.”

## 10. Notificaciones (45 segundos)

“La aplicación informa al usuario mediante mensajes visibles dentro de la interfaz. Después de crear, reprogramar o cancelar una solicitud se actualiza la lista y se muestra el resultado de la operación. Los errores, reintentos y datos de respaldo también se comunican en español.”

Estos avisos son notificaciones internas de la aplicación y no requieren permisos adicionales. Las notificaciones push, como recordar una cita o avisar que la veterinaria confirmó una solicitud, quedan preparadas como una futura responsabilidad del backend NestJS. Así se evita simular un servicio externo incompleto y se mantiene estable el modo DEMO.

## 11. GPS y mapa (1 minuto 30 segundos)

“Desde **Clima y ubicación** se puede consultar Tarija o pulsar **Usar mi ubicación**. La aplicación comprueba que el GPS esté activo, solicita el permiso Android y obtiene una posición puntual con `geolocator`.”

“Con la latitud y longitud se consulta el clima actual mediante Open-Meteo. Luego `flutter_map` muestra un mapa de OpenStreetMap y coloca un marcador en la posición obtenida. Se presentan las coordenadas, la temperatura y el origen de los datos.”

Demostrar también el caso sin conexión: pulsar **Simular error de conexión**, observar el mensaje y elegir **Reintentar** o **Usar dato de respaldo**. No existe seguimiento permanente en segundo plano; la ubicación solo se solicita por acción explícita del cliente.

## 12. Manejo de errores (1 minuto)

“Cada operación asíncrona tiene tres resultados controlados: cargando, correcto o error. Mientras se espera una respuesta aparece un indicador y se deshabilitan los botones para evitar solicitudes duplicadas.”

“Si falla la red o vence el tiempo de espera, el controlador convierte la excepción en un mensaje claro en español. Si el problema es el GPS, se informa si está desactivado o si el permiso fue rechazado. En los formularios se validan los datos obligatorios antes de llamar al repositorio.”

Demostrar **Simular error de conexión** en la pantalla de contexto. Después pulsar **Reintentar** para repetir la operación o **Usar dato de respaldo** para continuar en modo DEMO. El mismo patrón se aplica a mascotas y solicitudes de citas, evitando fallos silenciosos o pantallas congeladas.

## 13. Recorrido visual de la aplicación (1 minuto)

Mostrar la bienvenida y entrar al inicio. Explicar brevemente:

- Inicio: servicios, información de EIVET y acceso a las funciones principales.
- Mis mascotas: consulta de las mascotas registradas por la veterinaria.
- Citas: consulta y gestión de solicitudes de atención.
- Perfil y preferencias: persistencia local de preferencias de presentación.

Las interfaces siguen la referencia visual de Stitch, pero fueron implementadas como widgets Flutter nativos; los HTML de referencia no se ejecutan dentro de la aplicación.

## 14. Provider y separación por capas (1 minuto)

“Provider administra el estado y también inyecta las dependencias.”

En `main.dart` se registran los repositorios, controladores y servicios. Las pantallas observan los cambios con `context.watch` y solicitan acciones sin contener la lógica de acceso a datos.

La estructura separa:

- modelos Dart para representar mascotas, citas, clima y contenido;
- repositorios para DEMO o API;
- servicios para GPS, clima y preferencias;
- controladores `ChangeNotifier` para estados de carga, éxito y error;
- pantallas y widgets reutilizables para la interfaz.

Esto facilita explicar, probar y sustituir el origen de datos sin rehacer la interfaz.

## 15. Modo DEMO, API y persistencia (1 minuto)

“El modo DEMO es completamente funcional y utiliza repositorios en memoria.”

Al iniciar, `AppConfig` lee la configuración. En DEMO se cargan datos de ejemplo y las solicitudes de citas se pueden crear, reprogramar y cancelar durante la ejecución. En modo API se usan los mismos contratos desde `docs/07_CONTRATO_API_NESTJS.md` para conectarse posteriormente a NestJS.

Las preferencias sencillas, como la bienvenida ya vista, se guardan con `SharedPreferences`. Así se demuestra persistencia local sin usar Supabase, Firebase ni otra base de datos externa.

## 16. Complemento del CRUD de solicitudes (30 segundos)

Abrir **Citas** y demostrar el flujo:

1. Crear una solicitud seleccionando una mascota, fecha, hora y motivo.
2. Consultar la solicitud en la lista.
3. Abrirla y solicitar una reprogramación.
4. Cancelarla desde la opción **Cancelar solicitud**.

El CRUD se aplica únicamente a solicitudes de citas, como exige el proyecto. Las mascotas son de consulta solamente. En DEMO las operaciones son asíncronas para representar una fuente remota; en API corresponden a `GET`, `POST`, `PATCH` y `DELETE` documentados.

## 17. Complemento de GPS y API REST (30 segundos)

Desde **Clima y ubicación**, el usuario puede consultar Tarija o pulsar **Usar mi ubicación**. `LocationService` comprueba que el GPS esté activo, solicita el permiso Android y obtiene una posición puntual. Después se consulta el clima mediante Open-Meteo y se muestra la latitud, longitud, temperatura y un marcador sobre un mapa de OpenStreetMap con `flutter_map`.

No se realiza seguimiento permanente en segundo plano. Si no hay permiso o conexión, se informa al usuario y se ofrece reintentar o usar un dato de respaldo para la demostración.

## 18. Complemento de manejo de errores y estados (30 segundos)

Todas las operaciones asíncronas siguen el patrón `loading -> ready` o `loading -> error`.

- Los controladores exponen un estado observable mediante Provider.
- Mientras se espera una respuesta se deshabilitan botones y se muestra un indicador de carga.
- Los errores de red, tiempo de espera, permisos GPS y respuestas inválidas se convierten en mensajes claros en español.
- La pantalla conserva la acción que falló para que **Reintentar** repita la consulta correspondiente.
- Cuando la red no está disponible existe un dato de respaldo DEMO para no bloquear la exposición.
- En formularios se validan campos obligatorios antes de llamar al repositorio.

Para demostrarlo, pulsar **Simular error de conexión** en la pantalla de contexto, observar el mensaje y pulsar **Reintentar** o **Usar dato de respaldo**. Esta prueba evidencia que la aplicación no se queda congelada ni falla silenciosamente.

## 19. Pruebas y cierre (45 segundos)

“Se ejecutaron `flutter pub get`, `flutter analyze` y `flutter test`. Las pruebas cubren el repositorio DEMO, el modelo de mascota, el mapeo JSON de la API y el CRUD de citas. También se generó el APK debug Android.”

Como cierre: “La solución prioriza funciones pequeñas, completas y demostrables: consulta de mascotas, CRUD de citas, modo DEMO, futura conexión REST, preferencias, GPS, mapa, estados de carga y manejo de errores. Por eso puede defenderse sin depender de un backend activo.”

## 20. Conclusiones (45 segundos)

“La adaptación convierte el proyecto docente en una aplicación móvil enfocada en las necesidades reales de los clientes de EIVET. Se conservaron Provider, Future, `async/await`, modelos JSON, repositorios, persistencia local, GPS, mapa, pruebas y manejo de errores.”

“La función principal quedó delimitada correctamente: el cliente consulta sus mascotas y administra solicitudes de citas, mientras que la información clínica y el registro de mascotas permanecen bajo control de la veterinaria.”

“El modo DEMO permite una defensa estable sin servidor. Al mismo tiempo, los contratos REST están documentados para conectar NestJS posteriormente. Como resultado, se obtiene una base mantenible, demostrable y preparada para crecer sin depender de Supabase o Firebase.”

## Resumen de la adaptación

El proyecto Flutter docente fue convertido en una aplicación Android para clientes de la Veterinaria EIVET. Se conservaron Provider, Future, `async/await`, modelos Dart, JSON, repositorios, persistencia local, GPS, mapa, estados de carga, manejo de errores y pruebas.

La consulta de mascotas quedó en modo lectura. El CRUD académico se trasladó a las solicitudes de citas: crear, consultar, solicitar reprogramación y cancelar. Se implementaron repositorios DEMO en memoria y repositorios API preparados para NestJS, con sus endpoints documentados.

Se retiraron Supabase y Firebase del alcance. La aplicación funciona en DEMO sin backend, usa `SharedPreferences` para preferencias, solicita GPS solo cuando el cliente lo pide y ofrece datos de respaldo para una defensa estable. La carpeta Android fue generada mediante Flutter sin eliminar `lib/`, `test/`, `config/` ni `docs/`.

## Pantallas terminadas

- **Bienvenida:** presentación de EIVET y acceso inicial.
- **Inicio:** servicios veterinarios, información destacada y accesos rápidos.
- **Mis mascotas:** consulta de mascotas registradas, con carga, error y reintento.
- **Detalle de mascota:** datos de identificación y notas disponibles, en modo lectura.
- **Citas:** listado de solicitudes y estados actuales.
- **Formulario de cita:** creación y solicitud de reprogramación.
- **Confirmación de cancelación:** cancelación segura de una solicitud.
- **Perfil y preferencias:** tema, bienvenida persistente e información del proyecto.
- **Clima y ubicación:** Tarija, GPS, clima, mapa, error y dato de respaldo.
- **Información de adaptación:** explicación del alcance académico y técnico de EIVET.

## Funciones terminadas

- Navegación entre pantallas mediante rutas Flutter y navegación inferior.
- Acceso inicial DEMO y persistencia de la bienvenida.
- Gestión de tema y preferencias con `SharedPreferences`.
- Consulta de mascotas en modo lectura.
- Visualización de datos de mascota a partir de modelos Dart.
- CRUD de solicitudes de citas en memoria: crear, consultar, reprogramar y cancelar.
- Repositorio API REST preparado para NestJS, con contrato documentado.
- Conversión de respuestas JSON a modelos Dart.
- Estados de carga, éxito, error y reintento.
- Mensajes de validación y confirmación en español.
- Simulación de error de conexión y dato de respaldo offline.
- Solicitud puntual de ubicación GPS con permisos Android.
- Consulta de clima usando coordenadas.
- Mapa OpenStreetMap con marcador de ubicación.
- Pruebas automatizadas de repositorios, modelos, mapeo JSON y CRUD DEMO.
- Compilación de la aplicación Android en APK debug.

## Archivos creados

Archivos nuevos principales de la adaptación:

- `lib/config/app_config.dart`
- `lib/models/appointment_request.dart`
- `lib/models/context_snapshot.dart`
- `lib/models/pet_api_mapper.dart`
- `lib/models/pet_details.dart`
- `lib/models/veterinary_content.dart`
- `lib/models/weather_snapshot.dart`
- `lib/repositories/api_appointment_repository.dart`
- `lib/repositories/api_registro_repository.dart`
- `lib/repositories/appointment_repository.dart`
- `lib/repositories/demo_appointment_repository.dart`
- `lib/repositories/demo_registro_repository.dart`
- `lib/repositories/veterinary_catalog_repository.dart`
- `lib/services/location_service.dart`
- `lib/services/weather_service.dart`
- `lib/controllers/context_controller.dart`
- `lib/screens/appointment_form_screen.dart`
- `lib/screens/appointments_screen.dart`
- `lib/screens/context/context_lab_screen.dart`
- `lib/widgets/context_card.dart`
- `docs/07_CONTRATO_API_NESTJS.md`
- `docs/GUIA_DEFENSA.md`
- `docs/RECORRIDO_DEMO.md`

También se generó la plataforma Android mediante Flutter en `android/`, incluyendo Gradle, actividad principal, recursos y configuración de permisos. Los archivos existentes de `lib/`, `test/`, `config/` y `docs/` se conservaron y se adaptaron cuando fue necesario.

## Archivos modificados

Archivos existentes adaptados al contexto de Veterinaria EIVET:

- `README.md`
- `pubspec.yaml` y `pubspec.lock`
- `lib/main.dart`
- `lib/app.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/welcome_screen.dart`
- `lib/screens/records_screen.dart`
- `lib/screens/settings_screen.dart`
- `lib/screens/about_adaptation_screen.dart`
- `lib/repositories/registro_repository.dart`
- `lib/models/registro.dart`
- `lib/controllers/preferences_controller.dart`
- `config/demo.json`
- `config/api.example.json`
- `docs/05_RUTA_DE_ARCHIVOS.md`
- `docs/06_REGLAS_AULA.md`
- `platform_templates/android/AndroidManifest.xml`
- `scripts/01_MENU_WINDOWS.bat`
- `scripts/01_MENU_LINUX.sh`

La configuración Android generada también fue ajustada para mostrar el nombre **Veterinaria EIVET** y declarar los permisos necesarios para Internet y ubicación.

## Dependencias agregadas

Para completar las funciones móviles se agregaron únicamente estas dependencias al proyecto:

- `geolocator: 14.0.3`: permisos y obtención puntual de ubicación GPS.
- `flutter_map: 8.3.2`: renderizado del mapa dentro de Flutter.
- `latlong2: 0.10.1`: representación de coordenadas y marcadores.

Se conservaron las dependencias académicas necesarias (`provider`, `shared_preferences`, `http` y `flutter_test`) sin ejecutar `flutter pub upgrade`. La dependencia de Supabase fue eliminada y no se agregó Firebase.

## Dependencias eliminadas

- `supabase_flutter`: eliminada del `pubspec.yaml` y del código fuente porque el proyecto no debe utilizar Supabase como base de datos ni como autenticación.

También se retiraron las inicializaciones, repositorios, servicios de autenticación y configuraciones relacionadas con Supabase. No se eliminaron `provider`, `shared_preferences`, `http`, `geolocator`, `flutter_map`, `latlong2` ni las herramientas de pruebas, porque son necesarias para la aplicación EIVET.

## Resultado de `flutter analyze`

La verificación estática final se ejecutó después de formatear el código y resolver las dependencias. El resultado fue:

```text
No issues found! (ran in 73.3s)
```

Esto confirma que el código Dart y la configuración Flutter no presentan errores ni advertencias de análisis dentro del alcance del proyecto.

## Resultado de `flutter test`

Las pruebas automatizadas finales se ejecutaron correctamente:

```text
00:02 +5: All tests passed!
```

Las cinco pruebas verifican el repositorio DEMO de mascotas, la conversión de detalles de mascota, el mapeo de JSON de NestJS y el CRUD completo de solicitudes de citas en memoria.

## Resultado de `flutter run`

`flutter devices` detectó únicamente Windows, Chrome y Edge. No había un emulador ni un dispositivo Android conectado, por lo que `flutter run --dart-define=DEMO_MODE=true` no se ejecutó.

No se afirma una ejecución en Android durante esta verificación. La compilación APK debug sí fue realizada previamente con éxito; para ejecutar la aplicación en vivo se debe conectar un teléfono Android con depuración USB o iniciar un emulador desde Android Studio.

## Credenciales del modo DEMO

El modo DEMO no requiere usuario, correo ni contraseña. Para acceder durante la defensa:

1. Abrir la aplicación.
2. Pulsar **Comenzar** en la pantalla de bienvenida.
3. Continuar con los datos DEMO precargados.

Esto es intencional: se evita almacenar credenciales sensibles y se garantiza una demostración reproducible sin backend. La autenticación real con usuario, contraseña y token se conectará posteriormente al endpoint que defina NestJS; no se deben presentar credenciales de Supabase porque ese servicio fue retirado del proyecto.

## Comandos exactos para ejecutarlo

Ejecutar desde la raíz del proyecto:

```powershell
flutter pub get
flutter devices
flutter run --dart-define-from-file=config/demo.json
```

El último comando inicia el modo DEMO en el dispositivo Android seleccionado. Si no hay un dispositivo disponible, comprobar los emuladores con:

```powershell
flutter emulators
flutter emulators --launch <ID_DEL_EMULADOR>
flutter devices
```

Para generar el APK de demostración sin iniciar la aplicación:

```powershell
flutter build apk --debug
```

El archivo queda en `build/app/outputs/flutter-apk/app-debug.apk`. Para el futuro modo API se utilizará:

```powershell
flutter run --dart-define-from-file=config/api.example.json
```

## Datos de EIVET que debes reemplazar

Antes de una presentación institucional, revisar y sustituir estos datos si la veterinaria proporciona información oficial:

- **Nombre y logotipo:** `lib/app.dart`, `lib/screens/welcome_screen.dart` y `lib/screens/home_screen.dart`.
- **Textos de servicios, vacunas y atención:** `lib/repositories/veterinary_catalog_repository.dart`.
- **Mascota y solicitudes de ejemplo:** `lib/repositories/demo_registro_repository.dart` y `lib/repositories/demo_appointment_repository.dart`.
- **Ubicación de referencia:** coordenadas de Tarija en `lib/controllers/context_controller.dart`, si se desea mostrar otra sede.
- **URL del backend:** `config/api.example.json`, reemplazando `API_BASE_URL` por la URL documentada de NestJS.
- **Identidad Android:** etiqueta e icono en `android/app/src/main/AndroidManifest.xml` y recursos de `android/app/src/main/res/`.

No inventar teléfonos, dirección, horarios ni credenciales. Si EIVET aún no los ha entregado, conservar los textos informativos actuales y presentarlos como datos de demostración.

## Funciones pendientes

Estas funciones no bloquean la defensa y quedan claramente delimitadas para una siguiente iteración:

- **Backend NestJS real, autenticación, usuarios y tokens:** depende de que se definan el servidor, las reglas de seguridad y el contrato oficial.
- **Conexión API desplegada:** requiere una URL accesible, endpoints activos y respuestas JSON validadas con el equipo backend.
- **Notificaciones push:** necesita un proveedor, permisos Android, tokens de dispositivo y reglas para confirmar o recordar citas.
- **Historial clínico y vacunas detalladas:** requiere datos clínicos autorizados, diseño del modelo y permisos de privacidad de EIVET.
- **Datos institucionales definitivos:** deben ser proporcionados y aprobados por la veterinaria para evitar información incorrecta.
- **Firma de producción y Play Store:** necesita certificado, cuenta de publicación, política de privacidad y revisión de la tienda.
- **Prueba en teléfono Android físico:** depende de disponer de un dispositivo conectado, permisos GPS reales y una red móvil o Wi-Fi.

Estas tareas son ampliaciones planificadas; no se presentan como implementadas ni se simulan con datos falsos.

## Preguntas frecuentes del docente

**¿Por qué no se usa Supabase?**  Se retiró porque el alcance solicita NestJS como backend futuro y no Firebase ni Supabase. El modo DEMO permite trabajar sin servidor.

**¿Dónde está el CRUD?**  En las solicitudes de citas: crear, consultar, solicitar reprogramación y cancelar.

**¿El cliente puede registrar mascotas?**  No. Las mascotas pertenecen al registro de la veterinaria y la aplicación las muestra en modo consulta.

**¿Qué pasa si falla la API?**  Se muestra un error en español, se habilita reintento y el modo DEMO o el dato de respaldo permiten continuar la demostración.

**¿Qué hace Provider?**  Comparte el estado y los repositorios entre las pantallas, notificando automáticamente los cambios sin colocar toda la lógica en `main.dart`.

**¿Por qué se usa un repositorio DEMO?**  Permite demostrar la aplicación sin depender de Internet ni de un backend activo. La interfaz utiliza el mismo contrato que el repositorio API.

**¿Qué diferencia hay entre Future y `async/await`?**  Un `Future` representa un resultado que llegará después; `async/await` permite esperar ese resultado sin bloquear la interfaz.

**¿Cómo se transforma el JSON?**  La respuesta HTTP se decodifica y un mapeador crea modelos Dart como `Registro` y `AppointmentRequest`.

**¿Dónde se guarda la preferencia de bienvenida?**  En `SharedPreferences`, una persistencia local sencilla del dispositivo.

**¿Qué ocurre si NestJS no responde?**  El repositorio API devuelve un error controlado. La aplicación muestra reintento y la defensa puede continuar utilizando DEMO.

**¿Por qué el mapa no usa una clave de Google?**  Se utiliza `flutter_map` con teselas de OpenStreetMap, suficiente para la demostración y sin configurar una clave comercial.

**¿El GPS rastrea al cliente?**  No. Solo obtiene una ubicación puntual después de que el cliente pulsa el botón y concede permiso.

**¿Cómo se probó el proyecto?**  Con `flutter analyze` para detectar problemas estáticos y `flutter test` para validar repositorios, modelos, mapeo JSON y CRUD DEMO.
