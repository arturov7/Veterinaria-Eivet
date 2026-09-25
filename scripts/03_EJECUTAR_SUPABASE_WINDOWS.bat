@echo off
setlocal
cd /d "%~dp0\.."

if not exist ".env" (
  echo Falta el archivo .env.
  echo Copia .env.example como .env y configura Supabase.
  pause
  exit /b 1
)

flutter run --dart-define-from-file=.env %*
