# Medición de rendimiento en producción — 03/10/2026

## Método

- Objetivo: observar disponibilidad y latencia de la ruta pública de salud.
- URL: `https://xbvjhrfgznljtwxghvka.supabase.co/functions/v1/salud`.
- Cliente: `curl.exe` ejecutado desde Windows, con 30 solicitudes GET secuenciales, pausa de 150 ms y tiempo máximo de 15 s por solicitud.
- Script reproducible: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/medir_rendimiento_salud.ps1`.
- Datos sin resumir: [CSV de 30 muestras](evidencias/rendimiento_salud_2026-10-03.csv), con fecha, código HTTP y tiempo total percibido por el cliente.

## Resultado observado

| Medida | Resultado |
|---|---:|
| Solicitudes | 30 |
| HTTP 200 | 30 |
| Respuestas en 3 s o menos | 29 (96,7 %) |
| Media | 0,896 s |
| Percentil 90 | 0,908 s |
| Mínimo / máximo | 0,565 s / 3,431 s |
| Intervalo local de la medición | 21:58:48–21:59:19, UTC−04:00 |

Este resultado corresponde únicamente a `GET /functions/v1/salud`, desde un cliente y durante un intervalo de unos 31 segundos. No confirma RNF-01: ese requisito exige que al menos el 90 % de las **operaciones principales** responda en 3 s o menos. Faltan mediciones autenticadas de consultas, registros y modificaciones, con cuentas ficticias, datos de prueba y condiciones documentadas. La medición debe repetirse después de sincronizar la función de salud en producción.
