@echo off
setlocal
cd /d "%~dp0\.."

if not exist "config\local.json" (
  echo Falta el archivo config\local.json.
  echo Copia config\local.example.json como config\local.json y configura Supabase.
  pause
  exit /b 1
)

flutter run --dart-define-from-file=config/local.json
