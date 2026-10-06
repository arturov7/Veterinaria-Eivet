param(
    [string]$Url = 'https://xbvjhrfgznljtwxghvka.supabase.co/functions/v1/salud'
)

$ErrorActionPreference = 'Stop'
$cases = @(
    @{ Method = 'GET'; Expected = 200; Body = 'online' },
    @{ Method = 'HEAD'; Expected = 200; Body = $null },
    @{ Method = 'POST'; Expected = 405; Body = $null }
)

$failed = 0
foreach ($case in $cases) {
    $status = 0
    $body = ''
    try {
        $response = Invoke-WebRequest -Uri $Url -Method $case.Method -UseBasicParsing -TimeoutSec 20
        $status = [int]$response.StatusCode
        $body = [string]$response.Content
    } catch {
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
        } else {
            $body = $_.Exception.Message
        }
    }
    $passed = $status -eq $case.Expected
    if ($null -ne $case.Body) {
        try { $passed = $passed -and ((ConvertFrom-Json -InputObject $body).status -eq $case.Body) }
        catch { $passed = $false }
    }
    if ($case.Method -eq 'HEAD') { $passed = $passed -and [string]::IsNullOrEmpty($body) }
    if (-not $passed) { $failed++ }
    $result = if ($passed) { 'APROBADO' } else { 'FALLIDO' }
    Write-Output ("{0} {1}: HTTP {2}, esperado {3}, respuesta {4}" -f $result, $case.Method, $status, $case.Expected, $body)
}

if ($failed -gt 0) { exit 1 }
