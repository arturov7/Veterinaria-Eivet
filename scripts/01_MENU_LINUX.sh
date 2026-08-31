#!/usr/bin/env bash
set -u
cd "$(dirname "$0")/.."

while true; do
  clear
  echo "============================================================"
  echo "VETERINARIA EIVET - ANDROID"
  echo "============================================================"
  echo "1. DEMO local - Android"
  echo "2. API NestJS - Android"
  echo "3. Ver dispositivos"
  echo "4. Reparar Ninja"
  echo "0. Salir"
  echo "============================================================"
  read -r -p "Opcion: " option

  case "$option" in
    1) flutter run --dart-define-from-file=config/demo.json ;;
    2) flutter run --dart-define-from-file=config/api.json ;;
    3) flutter devices ;;
    4) bash scripts/98_REPARAR_NINJA_LINUX.sh ;;
    0) exit 0 ;;
    *) echo "Opcion invalida" ;;
  esac

  echo
  read -r -p "ENTER para volver..."
done
