# Guía de Postman para EIVET en producción

Esta guía corresponde a la colección «EIVET | Producción | Pruebas manuales (autoconfigurada)». Enviar cada petición por separado con **Send**. No usar Runner para toda la colección. Utilizar solo cuentas y datos ficticios. Ningún caso se considera aprobado hasta revisar su respuesta real y el efecto indicado.

## Preparación

1. Importar docs/EIVET_PROD.postman_collection.json y build/EIVET_PROD.local.postman_environment.json. Seleccionar el entorno importado arriba a la derecha. La URL y la clave publicable ya están cargadas en ese entorno local.
2. Escribir en el entorno el correo y la contraseña de propietario A y B: correo_propietario_a, password_propietario_a, correo_propietario_b y password_propietario_b. Para casos de personal, completar correo_veterinario y password_veterinario. No compartir credenciales ni tokens.
3. Mantener habilitar_escrituras=NO y confirmar_datos_ficticios=NO hasta llegar a las pruebas de escritura.
4. En las peticiones autenticadas, Postman aplica el Bearer Token desde el entorno. No pegar manualmente un token en la URL ni agregar otro header Authorization.
5. En cada caso registrar método, URL, código HTTP, tiempo y dato decisivo. Capturar la ventana de Postman con esos elementos; ocultar contraseñas, tokens, correos, teléfonos y cualquier dato clínico o personal real. Ocultar el body completo del login.

### Lo que Postman guarda solo

| Variable | Petición que la guarda | Condición |
|---|---|---|
| token_propietario_a y uid_propietario_a | PROD-03A | Login válido |
| token_propietario_b y uid_propietario_b | PROD-03B | Login válido |
| token_veterinario y uid_veterinario | PROD-03V | Login válido |
| mascota_a_id y mascota_b_id | PROD-04A/B; mascota_b_id también en PREP-B | Una mascota propia visible, o una mascota ficticia B recién creada y devuelta con su ID |
| cita_a_id | PROD-09 | Una única cita creada y devuelta con ID, cliente A y mascota A |
| mascota_clinica_id y consulta_clinica_id | PREP-C1 | Una única consulta ficticia creada para mascota B; mascota_clinica_id es el ID de la mascota, no de la consulta |

Un login fallido limpia su token anterior. Una consulta de mascotas fallida o con cero o varias filas limpia el ID automático: si hay varias mascotas, elegir manualmente una ficticia y comprobar su cliente_id.

### Valores que debes preparar

- fecha_cita_iso: fecha futura acordada para la cita ficticia, en formato ISO con zona horaria, por ejemplo 2026-10-20T15:00:00-04:00. Confirmar que sea una fecha adecuada antes de enviarla.
- mascota_clinica_id: ID de una mascota ficticia con una consulta clínica ficticia ya existente. Si se usa PREP-C1, se guarda automáticamente junto con consulta_clinica_id.
- correo_qa_rechazado y password_qa_rechazado: datos ficticios nuevos para PROD-07; la contraseña debe tener ocho o más caracteres.

## Alta de personal: preparación fuera de esta colección

El proyecto no contiene una Edge Function ni un flujo de cliente para crear personal. El panel solo inicia sesión y consulta public.perfiles para aceptar rol administrador o veterinario. El SQL del proyecto indica crear el usuario en Supabase Authentication y luego su fila en public.perfiles con el mismo id, nombre, correo y rol. Si no existe una cuenta ficticia de veterinario, un responsable del proyecto debe preparar ambas filas en el panel de Supabase y después comprobar el rol mediante PREP-V. No introducir service_role ni sb_secret_ en Postman. La función crear-propietario crea propietarios y solo permite llamarla a un administrador; no crea personal. Registrar esta preparación y su limpieza por separado.
## Casos de solo lectura y autenticación

### PROD-01 GET salud
Enviar «PROD-01 GET salud». No requiere credenciales ni body. El código local prevé 200 con {"status":"online"} cuando responde la comprobación interna, o 503 con {"status":"offline"} si falla. Registrar respuesta real. Captura: método, ruta, estado y body. No altera datos.

### PROD-01b HEAD salud
Enviar «PROD-01b HEAD salud». No requiere credenciales ni body. El código local prevé 200 sin body si responde la comprobación interna. Captura: método, ruta y estado; que no haya body es normal. No altera datos.

### PROD-02 Sin autenticación
Enviar «PROD-02 Sin autenticación»: POST a /functions/v1/crear-propietario, No Auth, body {}. El código local prevé 401 y {"error":"Inicia sesión."}. Si sale 405, comprobar que el método sea POST. Captura: método, ruta, estado y error. La respuesta no basta para demostrar que no se creó una cuenta; si se dispone de acceso autorizado, verificar Authentication y clientes.

### PROD-03A y PROD-03B Login A y B
Enviar primero «PROD-03A Login A» y luego «PROD-03B Login B». Los bodies de email/password ya usan las variables del entorno. Una respuesta válida debe contener access_token y user.id; los scripts guardan los tokens y UID correspondientes. Verificar que las cuatro variables quedaron definidas en el entorno. Captura: método, ruta y estado, con el body oculto. No altera los datos de negocio.

### PROD-03V Login veterinario
Solo si se hará PROD-06 o PROD-07: completar las credenciales ficticias y enviar «PROD-03V Login veterinario». El token se guarda automáticamente. Comprobar mediante una lectura autorizada de perfiles que su rol sea veterinario; el login por sí solo no acredita el rol. Ocultar la respuesta completa en la captura.

### PREP-V Verificar rol veterinario
Después de PROD-03V, enviar «PREP-V Verificar rol veterinario». Usa el token de personal y filtra perfiles por uid_veterinario. Para continuar con PREP-B o PROD-07, debe verse exactamente una fila cuyo id coincida y cuyo rol sea veterinario. Un login 200 o una lista [] no acreditan el rol. Captura: id, rol y código HTTP, ocultando datos adicionales. No altera datos.

### Identidad A e Identidad B
Enviar ambas peticiones GET /auth/v1/user. Comparar cada id con uid_propietario_a y uid_propietario_b. Confirmar que los UID son distintos. Captura: método, ruta, estado e id, ocultando correo y otros datos. No alteran datos.

### PROD-04A y PROD-04B Mascotas propias
Enviar ambas peticiones. Cada una usa el token de su dueño y filtra cliente_id=eq.UID. Observar id, cliente_id y nombre: cada cliente_id debe coincidir con el UID del token usado. Si hay una sola fila, Postman guarda automáticamente el ID de mascota. Capturas: respuesta A y respuesta B, con los datos ficticios pertinentes. No alteran datos.

Si PROD-04B devuelve [] porque B aún no tiene mascota, realizar PREP-B con una cuenta de personal antes de continuar con PROD-05 o PROD-11. Repetir PROD-04B para confirmar que B ve la nueva mascota.

### PREP-B0 Verificar cliente B
Después del login B, enviar «PREP-B0 Verificar cliente B»: GET a clientes filtrado por uid_propietario_b. Debe verse una fila cuyo id coincida. La mascota nueva usa cliente_id como clave foránea hacia esa tabla. Si sale [], detener PREP-B y revisar la creación de la cuenta ficticia B y el estado del trigger; no intentar compensarlo con un UUID inventado. Captura: ruta, id y código. No altera datos.

### PROD-05A y PROD-05B Lectura ajena
Hacerlas solo cuando PROD-04A/B demuestren que ambas mascotas ficticias existen y pertenecen a cuentas diferentes. PROD-05A usa token A y busca mascota B; PROD-05B usa token B y busca mascota A. Registrar el código HTTP real. RLS puede responder 200 con [] u otro rechazo. El criterio es que no aparezca ningún dato de la mascota ajena. Capturas: las dos respuestas cruzadas y las dos lecturas propias que prueban que los IDs existen. No alteran datos.

### PROD-06 Consulta clínica ficticia
Solo con veterinario verificado y consulta ficticia ya existente. Si se creó mediante PREP-C1, mascota_clinica_id ya está guardado. En otro caso, poner manualmente el ID de la mascota ficticia, no el ID de la consulta. Enviar la petición. Selecciona id, mascota_id, fecha, motivo y diagnostico de consultas. Registrar estado y confirmar que la consulta corresponde a esa mascota. Un 200 [] no prueba acceso a una consulta existente. Captura: ruta, estado y datos estrictamente ficticios; ocultar cualquier diagnóstico real. No altera datos.

### PROD-08 Citas propias A
Enviar antes de PROD-09. Filtra cliente_id=eq.uid_propietario_a con el token A. Registrar estado y filas visibles. Un 200 [] solo significa que no hay citas visibles para ese filtro en ese momento. Guardar captura previa. No altera datos.

## Escrituras manuales

Antes de estos casos, preparar datos ficticios y una forma de comprobar y limpiar sus efectos. Solo entonces cambiar habilitar_escrituras=SI y confirmar_datos_ficticios=SI. Los scripts bloquean el envío si alguna sigue en NO. Enviar una sola vez y revisar el resultado antes de repetir. Al terminar, devolver ambas variables a NO.

### PREP-B Crear mascota ficticia B (personal)
Esta es una preparación para PROD-05 y PROD-11, no una prueba de RLS entre propietarios. Primero comprobar con PROD-04B que B no tiene mascota. Confirmar que B es una cuenta ficticia, que su UID está en uid_propietario_b y que tiene una fila en clientes; si no existe esta fila, no crear datos por SQL para forzar la prueba. Haber confirmado PREP-V y PREP-B0 y tener un procedimiento de limpieza autorizado. Activar los dos interruptores en SI. Enviar una sola vez «PREP-B Crear mascota ficticia B (personal)»: POST a /rest/v1/mascotas, Bearer token_veterinario, body {"cliente_id":"{{uid_propietario_b}}","nombre":"Mascota B QA Postman","especie":"perro"}. El ID se genera en Supabase y el script lo guarda como mascota_b_id solo si la respuesta contiene una única fila vinculada a B. Registrar código y body reales; una política local permite alta por personal, pero su despliegue no está comprobado. Repetir PROD-04B con token B y confirmar que B ve esta mascota. Si falla o B no la ve, detener PROD-05/11. No borrar la mascota hasta terminar esas pruebas y verificar que no tenga citas ni registros dependientes; coordinar limpieza con personal autorizado.
### PREP-C1 Crear consulta clínica ficticia
Usar solo después de crear y verificar con PROD-04B la mascota B ficticia, y confirmar rol veterinario con PREP-V. Tener ambos interruptores de escritura en SI y la limpieza prevista. Enviar una sola vez «PREP-C1 Crear consulta clínica ficticia»: POST a /rest/v1/consultas con token_veterinario. El body ya incluye mascota_id={{mascota_b_id}}, motivo y diagnóstico explícitamente ficticios, y observaciones de prueba. Si Supabase devuelve una única consulta creada de esa mascota, el script guarda consulta_clinica_id y mascota_clinica_id automáticamente. Recién entonces enviar PROD-06 y comprobar que su respuesta contiene ese consulta_clinica_id. Registrar estado y respuesta; no declarar creada una consulta si hubo rechazo RLS.

### PREP-C2 Limpiar consulta clínica ficticia
Solo después de guardar la evidencia de PROD-06 y de confirmar que la consulta ficticia no tiene tratamientos ni otros registros dependientes. Cambiar confirmar_limpieza_clinica=SI, además de los dos interruptores de escritura. Verificar que consulta_clinica_id es el ID devuelto por PREP-C1 y que mascota_clinica_id es el ID de la mascota B ficticia. Enviar una sola vez «PREP-C2 Limpiar consulta clínica ficticia»: DELETE a /rest/v1/consultas con filtros por ambos IDs y token_veterinario. La respuesta debe confirmar exactamente la fila esperada; luego repetir PROD-06 para comprobar que ya no aparece. Si la limpieza se confirma, el script vacía consulta_clinica_id y vuelve confirmar_limpieza_clinica a NO. No usar esta petición con datos clínicos reales.
### PROD-07 Veterinario sin permiso para crear propietario
Requiere rol veterinario confirmado, correo_qa_rechazado y password_qa_rechazado ficticios. Enviar la petición; el body ya contiene nombre, correo, contrasena, telefono y direccion. El código local prevé 403 y {"error":"Solo un administrador puede crear cuentas."}. Registrar respuesta real y comprobar mediante lectura autorizada de Authentication > Users y clientes que la cuenta no exista. Captura: petición y respuesta, sin contraseña. Si se creó inesperadamente, detenerse y coordinar la limpieza con personal autorizado.

### PROD-09 Solicitar cita propia
Requiere mascota_a_id confirmada en PROD-04A, fecha_cita_iso futura y ambos interruptores en SI. El body ya incluye mascota_id, fecha_hora, motivo, estado Pendiente y cliente_id. Antes de enviar, comprobar que el token, cliente_id y mascota correspondan a A. Enviar una sola vez; registrar estado y respuesta. Si la respuesta contiene una única cita propia creada, Postman guarda cita_a_id. Volver a enviar PROD-08 para verificar que aparece una sola cita. Si se obtiene 403 por RLS, no se creó ni se obtuvo ID válido: conservar evidencia y dejar PROD-10 pendiente. Captura: body sin credenciales, respuesta y verificación posterior.

### PROD-10 Cancelar cita propia
Solo si cita_a_id pertenece a una cita ficticia realmente creada. Enviar PATCH a citas con los filtros id=eq.cita_a_id y cliente_id=eq.uid_propietario_a; body {"estado":"Cancelada"}. Registrar estado y filas devueltas: un 200 [] puede significar cero filas modificadas. Repetir PROD-08 y confirmar que la misma cita tiene estado Cancelada. La fila no se borra. Captura: antes, PATCH y después. Si PROD-09 falló, dejar este caso pendiente.

### PROD-11 A intenta modificar mascota B
Solo si mascota B es ficticia y existe una forma autorizada de restaurar su nombre. Primero anotar su nombre original con PROD-04B. Enviar la petición con token A, filtro por mascota_b_id y body {"nombre":"Mascota B QA intento ajeno"}. Registrar el código real y filas devueltas. Repetir PROD-04B con token B: el nombre debe seguir igual. Un 200 [] puede indicar que RLS afectó cero filas; el criterio es que A no modificó la mascota B. Si cambió, documentar el fallo y restaurar con B o personal autorizado. Captura: antes, intento y después.

## Errores comunes

- PGRST301 o JWT inválido: volver a iniciar sesión. El Bearer Token debe ser la variable de token correspondiente; no pegar access_token en un filtro de URL.
- PGRST100 o filtro inválido: los parámetros de URL usan eq. seguido de un UUID, por ejemplo cliente_id=eq.{{uid_propietario_a}}.
- 22P02 o UUID inválido: en el body JSON usar solo {{uid_propietario_a}} o {{mascota_a_id}}, sin eq. delante. Confirmar que la variable está resuelta.
- 42501 o rechazo RLS: registrar el fallo; no dar por creada la cita ni pasar a PROD-10 sin una fila verificable.
- 200 []: comprobar primero que el recurso existe desde su cuenta propietaria; luego interpretar el acceso ajeno o la actualización de cero filas.

La cancelación de citas usa PATCH. El único DELETE de la colección es la limpieza explícita de la consulta ficticia creada en PREP-C1; no borra mascotas ni citas. Los archivos SQL del repositorio describen políticas propuestas; comprobar por separado cuáles están desplegadas en producción.