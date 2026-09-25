import { createClient } from 'npm:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

function json(body: Record<string, unknown>, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (request: Request) => {
  if (request.method === 'OPTIONS') return new Response(null, { headers: corsHeaders })
  if (request.method !== 'POST') return json({ error: 'Método no permitido.' }, 405)

  const url = Deno.env.get('SUPABASE_URL')
  const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (!url || !serviceRole) return json({ error: 'La función no está configurada.' }, 500)

  const bearer = request.headers.get('Authorization')
  if (!bearer?.startsWith('Bearer ')) return json({ error: 'Inicia sesión.' }, 401)
  const token = bearer.slice(7)
  const admin = createClient(url, serviceRole, {
    auth: { autoRefreshToken: false, persistSession: false },
  })

  const { data: caller, error: authError } = await admin.auth.getUser(token)
  if (authError || !caller.user) return json({ error: 'Sesión inválida.' }, 401)

  const { data: profile, error: profileError } = await admin
    .from('perfiles')
    .select('rol')
    .eq('id', caller.user.id)
    .maybeSingle()
  if (profileError) return json({ error: 'No se pudo verificar el rol.' }, 500)
  if (profile?.rol !== 'administrador') {
    return json({ error: 'Solo un administrador puede crear cuentas.' }, 403)
  }

  let input: Record<string, unknown>
  try {
    input = await request.json()
  } catch {
    return json({ error: 'Datos inválidos.' }, 400)
  }
  const name = typeof input.nombre === 'string' ? input.nombre.trim() : ''
  const email = typeof input.correo === 'string' ? input.correo.trim().toLowerCase() : ''
  const password = typeof input.contrasena === 'string' ? input.contrasena : ''
  const phone = typeof input.telefono === 'string' ? input.telefono.trim() : ''
  const address = typeof input.direccion === 'string' ? input.direccion.trim() : ''
  if (!name || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || password.length < 8) {
    return json({ error: 'Nombre, correo y contraseña de 8 caracteres son obligatorios.' }, 400)
  }

  const { data: created, error: createError } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { full_name: name },
  })
  if (createError || !created.user) {
    const status = createError?.code === 'email_exists' ? 409 : 400
    return json({ error: createError?.message ?? 'No se pudo crear la cuenta.' }, status)
  }

  const { error: clientError } = await admin.from('clientes').upsert({
    id: created.user.id,
    nombre: name,
    correo: email,
    telefono: phone,
    direccion: address,
  })
  if (clientError) {
    const { error: rollbackError } = await admin.auth.admin.deleteUser(created.user.id)
    return json({
      error: rollbackError
        ? 'La cuenta se creó, pero faltó completar su perfil. Revisa Authentication > Users.'
        : 'No se pudo guardar el perfil del cliente. Revisa el script 10_CLIENTES_EN_PANEL.sql.',
    }, 500)
  }

  return json({ id: created.user.id, correo: email }, 201)
})
