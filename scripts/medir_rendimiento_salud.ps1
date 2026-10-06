param(
    [int]$Muestras = 30,
    [string]$Url = 'https://xbvjhrfgznljtwxghvka.supabase.co/functions/v1/salud',
    [string]$Salida = ("docs/evidencias/rendimiento_salud_{0}.csv" -f (Get-Date -Format 'yyyy-MM-dd'))
)

$ErrorActionPreference = 'Stop'
if ($Muestras -lt 10) { throw 'Use al menos 10 muestras.' }
$rows = @()
for ($i = 1; $i -le $Muestras; $i++) {
    $timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
    $result = & curl.exe --silent --show-error --max-time 15 --output NUL --write-out '%{http_code},%{time_total}' $Url
    if ($LASTEXITCODE -ne 0) { throw "curl falló en la muestra ${i}; código de salida $LASTEXITCODE. No se publicarán resultados parciales." }
    $parts = $result -split ','
    if ($parts.Count -ne 2) { throw "Respuesta de curl inesperada en muestra ${i}: $result" }
    $seconds = [double]::Parse($parts[1], [Globalization.CultureInfo]::InvariantCulture)
    $rows += [pscustomobject]@{
        muestra = $i
        fecha_hora = $timestamp
        metodo = 'GET'
        codigo_http = [int]$parts[0]
        tiempo_segundos = $seconds
    }
    if ($i -lt $Muestras) { Start-Sleep -Milliseconds 150 }
}

$directory = Split-Path -Parent $Salida
if ($directory) { New-Item -ItemType Directory -Force -Path $directory | Out-Null }
$rows | Export-Csv -LiteralPath $Salida -NoTypeInformation -Encoding UTF8
$ok = @($rows | Where-Object { $_.codigo_http -eq 200 })
$within = @($ok | Where-Object { $_.tiempo_segundos -le 3.0 })
$sorted = @($ok | Sort-Object tiempo_segundos)
if ($sorted.Count -eq 0) { throw 'Ninguna respuesta HTTP 200; revise el CSV.' }
$p90Index = [Math]::Ceiling(0.9 * $sorted.Count) - 1
$mean = ($ok | Measure-Object tiempo_segundos -Average).Average
Write-Output ("Muestras={0}; HTTP 200={1}; <=3 s={2}; cumplimiento={3:N1}%; promedio={4:N3} s; p90={5:N3} s; CSV={6}" -f $rows.Count, $ok.Count, $within.Count, (100*$within.Count/$rows.Count), $mean, $sorted[$p90Index].tiempo_segundos, $Salida)
