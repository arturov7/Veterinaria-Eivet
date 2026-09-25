#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

: "${SUPABASE_URL:?Configura SUPABASE_URL en las variables de build de Netlify.}"
: "${SUPABASE_PUBLISHABLE_KEY:?Configura SUPABASE_PUBLISHABLE_KEY en las variables de build de Netlify.}"
: "${FLUTTER_VERSION:?Configura FLUTTER_VERSION en netlify.toml.}"

# Instala el SDK fuera del repositorio; las claves proceden del entorno de Netlify.
flutter_dir="$(mktemp -d "${TMPDIR:-/tmp}/eivet-flutter.XXXXXX")"
git clone --depth 1 --branch "$FLUTTER_VERSION" \
  https://github.com/flutter/flutter.git "$flutter_dir/sdk"
export PATH="$flutter_dir/sdk/bin:$PATH"

flutter config --no-analytics
flutter pub get
flutter build web --release --no-pub \
  --dart-define=APP_MODE=supabase \
  --dart-define="SUPABASE_URL=$SUPABASE_URL" \
  --dart-define="SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY"
