from pathlib import Path
from html import escape
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT, TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, Image
from reportlab.lib.colors import HexColor

ROOT = Path(r"C:\Users\Arturo Vedia\Desktop\Modulo 3 Android\PROYECTO_FINAL_360_SESION2_FINAL")
OUT = ROOT / "output" / "pdf"
OUT.mkdir(parents=True, exist_ok=True)
LOGO = ROOT / "assets" / "logo.png"
FONT = Path(r"C:\Windows\Fonts")
pdfmetrics.registerFont(TTFont("ArialCustom", str(FONT / "arial.ttf")))
pdfmetrics.registerFont(TTFont("ArialCustom-Bold", str(FONT / "arialbd.ttf")))
pdfmetrics.registerFont(TTFont("ArialCustom-Italic", str(FONT / "ariali.ttf")))
pdfmetrics.registerFontFamily("ArialCustom", normal="ArialCustom", bold="ArialCustom-Bold", italic="ArialCustom-Italic", boldItalic="ArialCustom-Bold")

GREEN = HexColor("#0B4B3D")
DARK = HexColor("#18332B")
MINT = HexColor("#EAF5EF")
PALE = HexColor("#F6F9F6")
GOLD = HexColor("#C3982B")
MUTED = HexColor("#53665E")
LINE = HexColor("#D6E5DB")
WHITE = colors.white
PAGE_W, PAGE_H = A4
LEFT = 50
RIGHT = 50
WIDTH = PAGE_W - LEFT - RIGHT

S = {}
S["eyebrow"] = ParagraphStyle("eyebrow", fontName="ArialCustom-Bold", fontSize=10, leading=14, textColor=GREEN, spaceAfter=10)
S["cover_title"] = ParagraphStyle("cover_title", fontName="ArialCustom-Bold", fontSize=30, leading=35, textColor=DARK, spaceAfter=14)
S["cover_sub"] = ParagraphStyle("cover_sub", fontName="ArialCustom", fontSize=15, leading=22, textColor=MUTED, spaceAfter=12)
S["h1"] = ParagraphStyle("h1", fontName="ArialCustom-Bold", fontSize=17, leading=22, textColor=GREEN, spaceBefore=4, spaceAfter=11, keepWithNext=True)
S["h2"] = ParagraphStyle("h2", fontName="ArialCustom-Bold", fontSize=12.5, leading=17, textColor=DARK, spaceBefore=11, spaceAfter=6, keepWithNext=True)
S["body"] = ParagraphStyle("body", fontName="ArialCustom", fontSize=10, leading=15, textColor=DARK, spaceAfter=8)
S["small"] = ParagraphStyle("small", fontName="ArialCustom", fontSize=8.6, leading=12.4, textColor=MUTED, spaceAfter=6, splitLongWords=True)
S["table"] = ParagraphStyle("table", fontName="ArialCustom", fontSize=9, leading=12.7, textColor=DARK, splitLongWords=True)
S["tablehead"] = ParagraphStyle("tablehead", fontName="ArialCustom-Bold", fontSize=9, leading=12.5, textColor=WHITE)
S["stepnum"] = ParagraphStyle("stepnum", fontName="ArialCustom-Bold", fontSize=10, leading=13, textColor=GREEN, alignment=TA_CENTER)
S["callout"] = ParagraphStyle("callout", fontName="ArialCustom", fontSize=9.7, leading=14.5, textColor=DARK)
S["code"] = ParagraphStyle("code", fontName="Courier", fontSize=8.4, leading=12.5, textColor=GREEN, splitLongWords=True)

def p(txt, style="body"):
    return Paragraph(txt, S[style])

def section(title):
    return p(title, "h1")

def sub(title):
    return p(title, "h2")

def callout(title, text, color=MINT):
    content = p(f"<b>{escape(title)}</b><br/>{text}", "callout")
    t = Table([[content]], colWidths=[WIDTH], hAlign="LEFT")
    t.setStyle(TableStyle([
        ("BACKGROUND", (0,0), (-1,-1), color),
        ("BOX", (0,0), (-1,-1), 0.6, LINE),
        ("LEFTPADDING", (0,0), (-1,-1), 12),
        ("RIGHTPADDING", (0,0), (-1,-1), 12),
        ("TOPPADDING", (0,0), (-1,-1), 10),
        ("BOTTOMPADDING", (0,0), (-1,-1), 10),
    ]))
    return [t, Spacer(1, 12)]

def steps(items):
    data=[]
    for i, item in enumerate(items, 1):
        data.append([p(f"{i:02d}", "stepnum"), p(item, "table")])
    t=Table(data, colWidths=[34, WIDTH-34], hAlign="LEFT", repeatRows=0)
    styles=[
        ("VALIGN", (0,0), (-1,-1), "TOP"),
        ("LINEBELOW", (0,0), (-1,-2), 0.5, LINE),
        ("LEFTPADDING", (0,0), (0,-1), 4),
        ("RIGHTPADDING", (0,0), (0,-1), 7),
        ("LEFTPADDING", (1,0), (1,-1), 7),
        ("RIGHTPADDING", (1,0), (1,-1), 6),
        ("TOPPADDING", (0,0), (-1,-1), 8),
        ("BOTTOMPADDING", (0,0), (-1,-1), 8),
    ]
    t.setStyle(TableStyle(styles))
    return [t, Spacer(1, 8)]

def grid(headers, rows, widths=None):
    widths=widths or [WIDTH/len(headers)]*len(headers)
    data=[[p(escape(h), "tablehead") for h in headers]]
    for row in rows:
        data.append([p(cell, "table") for cell in row])
    t=Table(data, colWidths=widths, hAlign="LEFT", repeatRows=1)
    t.setStyle(TableStyle([
        ("BACKGROUND",(0,0),(-1,0),GREEN),
        ("ROWBACKGROUNDS",(0,1),(-1,-1),[WHITE,PALE]),
        ("VALIGN",(0,0),(-1,-1),"TOP"),
        ("LINEBELOW",(0,0),(-1,-1),0.4,LINE),
        ("LEFTPADDING",(0,0),(-1,-1),9),
        ("RIGHTPADDING",(0,0),(-1,-1),9),
        ("TOPPADDING",(0,0),(-1,-1),7),
        ("BOTTOMPADDING",(0,0),(-1,-1),7),
    ]))
    return [t, Spacer(1, 10)]

def code(lines):
    txt="<br/>".join(escape(line).replace(" ", "&nbsp;") for line in lines)
    t=Table([[p(txt,"code")]], colWidths=[WIDTH], hAlign="LEFT")
    t.setStyle(TableStyle([
        ("BACKGROUND",(0,0),(-1,-1),PALE),
        ("BOX",(0,0),(-1,-1),0.6,LINE),
        ("LEFTPADDING",(0,0),(-1,-1),11),
        ("RIGHTPADDING",(0,0),(-1,-1),11),
        ("TOPPADDING",(0,0),(-1,-1),8),
        ("BOTTOMPADDING",(0,0),(-1,-1),8),
    ]))
    return [t, Spacer(1, 10)]

def cover(kind, subtitle, audience):
    story=[Spacer(1,75)]
    if LOGO.exists():
        story.extend([Image(str(LOGO), width=126, height=126, hAlign="LEFT"), Spacer(1,26)])
    story += [
        p("VETERINARIA EIVET  /  DOCUMENTACIÓN", "eyebrow"),
        p(kind, "cover_title"),
        p(subtitle, "cover_sub"),
        Spacer(1,19),
    ]
    story += callout("Dirigido a", audience, PALE)
    story += [
        Spacer(1,82),
        p("Edición: 10 de octubre de 2026", "small"),
        p("Versión del proyecto consultado: 3.0.0+1. Este documento explica el uso o el procedimiento; no certifica por sí mismo pruebas ni despliegues.", "small"),
        PageBreak(),
    ]
    return story

def page_bg(canvas, doc, label):
    canvas.saveState()
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.7)
    canvas.line(LEFT, PAGE_H-45, PAGE_W-RIGHT, PAGE_H-45)
    canvas.setFont("ArialCustom-Bold", 8)
    canvas.setFillColor(GREEN)
    canvas.drawString(LEFT, PAGE_H-36, "EIVET")
    canvas.setFont("ArialCustom", 8)
    canvas.setFillColor(MUTED)
    canvas.drawRightString(PAGE_W-RIGHT, PAGE_H-36, label)
    canvas.line(LEFT, 39, PAGE_W-RIGHT, 39)
    canvas.drawString(LEFT, 26, "Veterinaria EIVET")
    canvas.drawRightString(PAGE_W-RIGHT, 26, f"{doc.page}")
    canvas.restoreState()

def cover_bg(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(GREEN)
    canvas.rect(0, PAGE_H-15, PAGE_W, 15, fill=1, stroke=0)
    canvas.setFillColor(GOLD)
    canvas.rect(LEFT, 56, 95, 4, fill=1, stroke=0)
    canvas.restoreState()

def build(path, story, label):
    doc=SimpleDocTemplate(
        str(path), pagesize=A4, rightMargin=RIGHT, leftMargin=LEFT,
        topMargin=61, bottomMargin=55, title=label, author="Veterinaria EIVET",
        subject="Manual del proyecto Flutter y Supabase"
    )
    doc.build(story, onFirstPage=cover_bg, onLaterPages=lambda c,d: page_bg(c,d,label))

user=cover(
    "Manual de usuario",
    "Aplicación móvil para propietarios de mascotas",
    "Personas que usan EIVET en un teléfono Android. No se necesitan conocimientos técnicos."
)
user += [
    section("1. Antes de comenzar"),
    p("EIVET permite consultar las mascotas vinculadas a tu cuenta, revisar cuidados y enviar solicitudes de cita a la clínica. Necesitas un teléfono Android con la aplicación instalada, conexión a Internet y una cuenta de propietario."),
]
user += callout("Si todavía no aparece tu mascota", "El personal de EIVET debe registrarla y vincularla a tu cuenta. Desde la app de propietario puedes consultarla, pero no crearla ni cambiar su ficha.")
user += [sub("Instalar y abrir la aplicación")]
user += steps([
    "Recibe el archivo de instalación de una fuente confirmada por EIVET. Si la clínica no te entregó un archivo, solicita el canal oficial antes de instalar.",
    "Abre el archivo en tu teléfono y sigue las indicaciones de Android para instalarlo. Si aparece un bloqueo de seguridad, pide ayuda a quien te entregó la aplicación.",
    "Toca el ícono <b>Veterinaria EIVET</b>. Con Internet disponible, verás la pantalla para iniciar sesión."
])
user += [sub("Entrar o crear una cuenta")]
user += steps([
    "Si ya te dieron una cuenta, escribe tu <b>correo</b> y <b>contraseña</b>, acepta los términos y toca <b>Ingresar</b>.",
    "Si necesitas una cuenta nueva, toca <b>Regístrate</b>. Completa nombre, correo, contraseña y confirmación; acepta los términos y toca <b>Crear cuenta</b>.",
    "Si te registraste desde la app, revisa el correo de confirmación indicado por EIVET. Luego vuelve a <b>Iniciar sesión</b>.",
    "Si olvidaste la contraseña, escribe tu correo y toca <b>¿Olvidaste tu contraseña?</b>; sigue el enlace que llegue a tu correo."
])
user += [
    sub("Dónde encontrar cada función"),
]
user += grid(["Pestaña", "Para qué sirve"], [
    ["<b>Inicio</b>", "Vista general y avisos disponibles."],
    ["<b>Mascotas</b>", "Ver y buscar las mascotas vinculadas a tu cuenta."],
    ["<b>Cuidados</b>", "Consultar vacunas, tratamientos e indicaciones disponibles."],
    ["<b>Citas</b>", "Solicitar, revisar, reprogramar o cancelar solicitudes."],
    ["<b>Perfil</b>", "Datos personales, preferencias, seguridad y cierre de sesión."],
], [105, WIDTH-105])
user += [
    section("2. Consultar tus mascotas"),
]
user += steps([
    "En la barra inferior, toca <b>Mascotas</b>. Espera a que termine la carga.",
    "Si tienes varias mascotas, usa <b>Buscar mascota...</b> para encontrar una por nombre.",
    "Toca la tarjeta de la mascota para abrir <b>Tarjeta de mascota</b>.",
    "Cambia entre <b>Información</b>, <b>Historial</b>, <b>Vacunas</b> y <b>Tratamientos</b>. Para recargar la ficha, usa <b>Actualizar expediente</b>."
])
user += callout("Historial y cuidados", "La información clínica aparece solo si el personal de EIVET la registró y tu cuenta tiene acceso. Si falta un dato, solicita su revisión a la clínica.")
user += [
    p("En la ficha también encontrarás <b>Ver historial</b> y <b>Agendar cita</b>. Estos botones abren el detalle clínico o la solicitud de cita de esa mascota."),
    PageBreak(),
    section("3. Solicitar y seguir una cita"),
]
user += steps([
    "Abre <b>Citas</b> y toca <b>Solicitar cita</b>; también puedes usar <b>Agendar cita</b> en la ficha de tu mascota.",
    "En <b>Mascota</b>, selecciona la mascota correspondiente. Si no hay mascotas disponibles, solicita al personal que vincule una a tu cuenta.",
    "En <b>Servicio</b>, elige el servicio veterinario y toca <b>Continuar</b>.",
    "En <b>Fecha</b>, selecciona día y horario. La disponibilidad debe ser confirmada por la clínica.",
    "En <b>Confirmar</b>, revisa el resumen y explica el motivo de la consulta. Toca <b>Confirmar solicitud</b>."
])
user += callout("La cita se envía como solicitud", "El estado inicial es <b>Pendiente</b>. Elegir un horario no significa que ya esté confirmado; EIVET debe confirmar su disponibilidad.")
user += [
    sub("Revisar, reprogramar o cancelar"),
    p("En <b>Citas</b> verás las solicitudes enviadas, su fecha, motivo y estado. Para actualizar la lista usa el botón de actualizar. En el menú de una cita puedes tocar <b>Solicitar reprogramación</b> o <b>Cancelar solicitud</b>. La cancelación pide confirmación y cambia el estado; no borra necesariamente el registro."),
    PageBreak(),
    section("4. Cuidados y perfil"),
    sub("Cuidados y seguimiento"),
    p("En <b>Cuidados</b> consulta vacunas, tratamientos, indicaciones y próximos controles cuando EIVET haya registrado estos datos. Usa <b>Actualizar cuidados</b> o <b>Reintentar</b> si la pantalla no carga."),
    sub("Tus datos y preferencias"),
]
user += steps([
    "Abre <b>Perfil</b> para revisar tus datos. En <b>Información personal</b> puedes cambiar el nombre y guardar.",
    "En <b>Editar foto</b> puedes elegir una imagen de la galería, usar un enlace o quitar la foto actual.",
    "En <b>Preferencias</b> puedes activar el <b>Tema oscuro</b>. Se guarda en el dispositivo.",
    "En <b>Seguridad</b> puedes cambiar la contraseña o cerrar las otras sesiones de tu cuenta.",
    "Para salir del teléfono, toca <b>Cerrar sesión</b> y confirma."
])
user += [
    PageBreak(),
    section("5. Ayuda rápida"),
]
user += grid(["Si ocurre esto...", "Qué hacer"], [
    ["No puedo entrar", "Revisa correo y contraseña. Si olvidaste la contraseña, usa el enlace de recuperación desde la pantalla de acceso."],
    ["No veo mi mascota", "En Mascotas, actualiza la pantalla. Si sigue sin aparecer, pide a EIVET que la vincule a tu cuenta."],
    ["No puedo solicitar una cita", "Comprueba que tu mascota aparezca en Mascotas y que tengas Internet. Si la solicitud no se guarda, comunícalo a la clínica."],
    ["No aparecen cuidados", "Actualiza la pantalla. Puede que el personal aún no haya registrado vacunas o tratamientos para esa mascota."],
    ["La app no carga", "Comprueba la conexión, cierra y vuelve a abrir la app. Si persiste, informa a EIVET del mensaje que aparece."],
], [155, WIDTH-155])
user += callout("Cuida tu información", "No compartas tu contraseña ni capturas de tu historial clínico con terceros. Si pierdes el teléfono, cambia tu contraseña y usa la opción para cerrar otras sesiones.")
user += [
    Spacer(1,9),
    p("Esta guía describe la interfaz móvil del código de EIVET revisado para la versión 3.0.0+1. Las funciones que dependen de Internet, permisos y datos registrados por la clínica pueden mostrar información vacía o errores si el servicio no está disponible.", "small"),
]
build(OUT/"Manual_de_usuario_EIVET.pdf", user, "Manual de usuario")

deploy=cover(
    "Manual de despliegue e instalación",
    "Flutter Android + panel web + Supabase",
    "Responsables técnicos de instalación, operación y publicación de EIVET. No contiene contraseñas ni claves."
)
deploy += [
    section("1. Alcance y arquitectura"),
    p("EIVET usa una base de código Flutter: en Android muestra la aplicación del propietario y en web el panel administrativo. Ambos usan el mismo proyecto Supabase configurado para Auth, PostgreSQL con RLS, Storage y Edge Functions. El panel web se compila y publica en Netlify."),
]
deploy += grid(["Componente", "Punto de instalación o despliegue"], [
    ["Android", "APK compilado desde Flutter. Paquete: bo.edu.uajms.proyecto_final_360."],
    ["Web", "Compilación Flutter Web en build/web; alojamiento definido en netlify.toml."],
    ["Supabase", "Auth, tablas SQL, políticas RLS, RPC salud y funciones salud / crear-propietario."],
], [110, WIDTH-110])
deploy += callout("Estado que debe comprobarse", "Los archivos del repositorio describen el esquema y la publicación previstos; no prueban que la base, RLS, funciones y APK final estén sincronizados en producción. Registra la versión, fecha y resultado de cada verificación.")
deploy += [
    sub("Herramientas y accesos"),
    p("Se necesitan Flutter (el proyecto exige Flutter 3.35 o superior y Dart 3.9), Android SDK, Java 17 para compilar Android, acceso autorizado al proyecto Supabase y a su SQL Editor, y acceso al sitio Netlify/Git para publicar web. El build de Netlify fija Flutter 3.44.8."),
    PageBreak(),
    section("2. Preparación local"),
]
deploy += steps([
    "Trabaja con la revisión Git acordada y registra su commit. Comprueba el entorno con <b>flutter doctor</b>.",
    "Copia <b>.env.example</b> a <b>.env</b>. Define APP_MODE=supabase, SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY del mismo proyecto Supabase.",
    "Ejecuta <b>flutter pub get</b>. Para desarrollo local usa <b>flutter run --dart-define-from-file=.env</b> con un Android conectado o un emulador.",
    "Mantén .env fuera de Git y de las capturas. La publishable key puede estar en el cliente; una clave service_role o sb_secret_ nunca debe entrar en Flutter, Netlify público ni Postman."
])
deploy += code([
    "Copy-Item .env.example .env",
    "# Completar .env localmente, sin publicar sus valores",
    "flutter pub get",
    "flutter run --dart-define-from-file=.env",
])
deploy += [
    section("3. Preparar Supabase"),
    p("<b>Entorno nuevo:</b> ejecuta los SQL desde Supabase SQL Editor en el orden documentado. <b>Producción existente:</b> antes de aplicar cualquier script, respalda y compara el esquema y políticas activos. No vuelvas a ejecutar toda la secuencia a ciegas."),
]
deploy += grid(["Orden", "Archivo SQL"], [
    ["1", "01_SCHEMA_RLS.sql"],
    ["2", "02_MASCOTAS_CRUD_RLS.sql"],
    ["3", "05_ADMIN_WEB_SCHEMA_RLS.sql"],
    ["4", "06_VINCULAR_CITAS_CLIENTES.sql"],
    ["5", "09_TRATAMIENTOS_CLIENTES_RLS.sql"],
    ["6", "10_CLIENTES_EN_PANEL.sql"],
    ["7", "12_MASCOTAS_TITULAR_SOLO_PERSONAL.sql"],
    ["8", "13_CITAS_RLS_PROPIETARIOS.sql"],
], [55, WIDTH-55])
deploy += [
    p("Ejecuta también <b>supabase/salud.sql</b> para crear la RPC de salud. El script 04_DATOS_EJEMPLO_CUIDADOS.sql es opcional y requiere cuentas/mascotas de ejemplo. Comprueba en Supabase que existan las tablas y que las políticas RLS estén activas, especialmente las de mascotas y citas."),
    PageBreak(),
    section("4. Usuarios, roles y funciones"),
    sub("Cuentas y roles"),
    p("Una cuenta de Auth recibe un UUID. El trigger crear_cliente crea su fila en clientes. Para personal, crea la cuenta con acceso administrativo a Supabase y una fila en public.perfiles con el mismo UUID y rol administrador o veterinario. El panel web consulta ese rol al iniciar sesión. La función crear-propietario solo crea cuentas de propietario si llama un administrador."),
    sub("Desplegar Edge Functions"),
]
deploy += steps([
    "Instala Supabase CLI, inicia sesión con una cuenta autorizada y enlaza este repositorio con el proyecto correcto.",
    "Despliega salud y crear-propietario desde la raíz del proyecto. Verifica sus respuestas en el entorno de destino.",
    "La configuración local marca verify_jwt=false para ambas funciones: salud es pública; crear-propietario valida dentro del código el JWT y el rol administrador. La clave de servicio se mantiene solo en Supabase."
])
deploy += code([
    "supabase login",
    "supabase link --project-ref PROJECT_REF",
    "supabase functions deploy salud",
    "supabase functions deploy crear-propietario",
])
deploy += callout("Verificación de publicación", "GET /functions/v1/salud debe registrar su código y body reales. El repositorio exige GET/HEAD, pero hay evidencia previa de una versión publicada que aceptaba POST; vuelve a verificar después de cada despliegue. Una respuesta de salud no acredita todos los permisos ni recorridos de negocio.")
deploy += [
    PageBreak(),
    section("5. Compilar e instalar Android"),
    sub("Compilación local"),
]
deploy += code([
    "flutter build apk --release --dart-define-from-file=.env",
    "# Salida: build/app/outputs/flutter-apk/app-release.apk",
    "Get-FileHash build/app/outputs/flutter-apk/app-release.apk -Algorithm SHA256",
])
deploy += [p("Antes de distribuir, guarda la revisión Git, la versión de pubspec.yaml, fecha, tamaño y SHA-256 del APK. Instala exactamente el archivo cuya huella registraste. Comprueba que abre, muestra el login y conecta con el proyecto Supabase previsto.")]
deploy += callout("Firma de publicación pendiente", "En android/app/build.gradle.kts la variante release usa actualmente signingConfigs.debug. Esto permite una compilación local, pero para una distribución final debe configurarse una clave de firma release y generarse un APK nuevo. No presentes un APK existente como distribución final sin comprobar su firma, huella e instalación.", HexColor("#FFF5DF"))
deploy += [
    sub("Instalación en dispositivo"),
]
deploy += steps([
    "Conecta un Android por USB y usa flutter install, o transfiere al teléfono el APK verificado por un canal acordado.",
    "En el teléfono abre el APK. Si Android solicita permiso para instalar desde esa fuente, sigue las indicaciones del dispositivo solo para la fuente de confianza.",
    "Abre Veterinaria EIVET, inicia sesión con una cuenta ficticia y comprueba el recorrido permitido. Documenta modelo, versión Android, fecha, versión app y captura sin datos sensibles."
])
deploy += [
    PageBreak(),
    section("6. Publicar el panel web"),
]
deploy += steps([
    "Conecta el repositorio al sitio Netlify autorizado. Comprueba la rama de producción y la revisión que se va a publicar.",
    "Configura SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY como variables de build en Netlify para ese proyecto Supabase.",
    "El archivo netlify.toml ejecuta bash scripts/build_netlify.sh y publica build/web. El script instala Flutter 3.44.8 y compila en modo release con APP_MODE=supabase.",
    "Tras el deploy, abre la URL del panel indicada para el proyecto y comprueba inicio de sesión del personal, lectura de perfiles y acceso a módulos autorizados. Guarda el ID del deploy y capturas."
])
deploy += code([
    "# Configuración del repositorio: netlify.toml",
    "command = bash scripts/build_netlify.sh",
    "publish = build/web",
])
deploy += callout("Variables del cliente", "La publishable key se incorpora al JavaScript web y al APK. La protección de datos depende de Auth y RLS, no del secreto de esa clave. Nunca configures service_role como variable de build que termine dentro de la aplicación.")
deploy += [
    section("7. Verificación antes de entregar"),
]
deploy += grid(["Comprobación", "Evidencia mínima"], [
    ["Base y RLS", "Políticas activas; dos propietarios ficticios: cada uno ve su mascota y no la ajena."],
    ["Funciones", "GET salud y rechazo de crear-propietario sin sesión/con rol no autorizado."],
    ["Android", "APK firmado para la distribución prevista; SHA-256; instalación y apertura en un dispositivo."],
    ["Web", "Deploy Netlify identificado y login del personal con rol confirmado."],
    ["Citas", "Solicitud ficticia creada y vista por su propietario; cancelación o rechazo documentado."],
], [115, WIDTH-115])
deploy += [
    p("Si una inserción devuelve 403 por RLS, no se considera completado el recorrido de citas. Conserva respuesta y revisa las políticas desplegadas antes de reintentar. No marques una prueba como aprobada sin su resultado y comprobación posterior."),
    PageBreak(),
    section("8. Mantenimiento y referencias"),
    p("Para cada nueva entrega, conserva revisión Git, artefactos anteriores, huellas y capturas. Antes de modificar SQL de producción, revisa dependencias, datos y posibilidades de restauración. Publica una versión web o APK nueva solo tras repetir las verificaciones esenciales."),
    sub("Archivos del proyecto"),
]
deploy += grid(["Archivo", "Uso"], [
    ["README.md", "Resumen, comandos Flutter y despliegue Netlify."],
    ["docs/SUPABASE_EIVET.md", "Orden SQL, roles, RLS y Edge Functions."],
    ["netlify.toml / scripts/build_netlify.sh", "Build y publicación web."],
    ["supabase/config.toml / supabase/functions", "Configuración y código de funciones."],
    ["android/app/build.gradle.kts", "Identificador, versión y firma Android."],
], [205, WIDTH-205])
deploy += [
    sub("Documentación oficial consultada"),
    p('<link href="https://docs.flutter.dev/deployment/android" color="#0B4B3D">Flutter - Build and release an Android app</link>; <link href="https://docs.flutter.dev/deployment/web" color="#0B4B3D">Flutter - Build and release a web app</link>; <link href="https://supabase.com/docs/guides/functions/deploy" color="#0B4B3D">Supabase - Deploy to Production</link>; <link href="https://docs.netlify.com/build/configure-builds/environment-variables/" color="#0B4B3D">Netlify - Build environment variables</link>.'),
    p("Manual redactado a partir del repositorio local y documentación oficial consultada el 10/10/2026. Las instrucciones describen el procedimiento previsto; cada despliegue e instalación debe verificarse en su entorno real.", "small"),
]
build(OUT/"Manual_de_despliegue_e_instalacion_EIVET.pdf", deploy, "Despliegue e instalación")

print("CREATED")
for path in sorted(OUT.glob("Manual_*EIVET.pdf")):
    print(path, path.stat().st_size)
