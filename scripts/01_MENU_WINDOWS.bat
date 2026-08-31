@echo off
setlocal
cd /d "%~dp0\.."

:menu
cls
echo ============================================================
echo VETERINARIA EIVET - ANDROID
echo ============================================================
echo 1. DEMO local - Android
echo 2. API NestJS - Android
echo 3. Ver dispositivos
echo 0. Salir
echo ============================================================
set /p option=Opcion: 

if "%option%"=="1" flutter run --dart-define-from-file=config/demo.json
if "%option%"=="2" flutter run --dart-define-from-file=config/api.json
if "%option%"=="3" flutter devices
if "%option%"=="0" exit /b 0

echo.
pause
goto menu
