import { createClient } from 'npm:@supabase/supabase-js@2'

function response(status: 'online' | 'offline', httpStatus: number): Response {
  return new Response(JSON.stringify({ status }), {
    status: httpStatus,
    headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' },
  })
}

Deno.serve(async (request: Request) => {
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    return new Response(null, { status: 405, headers: { Allow: 'GET, HEAD' } })
  }

  const url = Deno.env.get('SUPABASE_URL')
  const key = Deno.env.get('SUPABASE_ANON_KEY')
  if (!url || !key) return response('offline', 503)

  try {
    const supabase = createClient(url, key, {
      auth: { autoRefreshToken: false, persistSession: false },
    })
    const { error } = await supabase.rpc('salud')
    if (error) return response('offline', 503)
    return response('online', 200)
  } catch {
    return response('offline', 503)
  }
})
