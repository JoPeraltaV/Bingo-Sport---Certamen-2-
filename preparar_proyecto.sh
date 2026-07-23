#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: Flutter no está instalado o no está en PATH." >&2
  exit 1
fi

RAIZ="$(cd "$(dirname "$0")" && pwd)"
RESPALDO="$(mktemp -d)"
trap 'rm -rf "$RESPALDO"' EXIT

cp -R "$RAIZ/lib" "$RESPALDO/lib"
cp -R "$RAIZ/test" "$RESPALDO/test"
cp "$RAIZ/pubspec.yaml" "$RESPALDO/pubspec.yaml"
cp "$RAIZ/analysis_options.yaml" "$RESPALDO/analysis_options.yaml"
cp "$RAIZ/README.md" "$RESPALDO/README.md"

cd "$RAIZ"
flutter create --platforms=android,ios,web .

rm -rf "$RAIZ/lib" "$RAIZ/test"
cp -R "$RESPALDO/lib" "$RAIZ/lib"
cp -R "$RESPALDO/test" "$RAIZ/test"
cp "$RESPALDO/pubspec.yaml" "$RAIZ/pubspec.yaml"
cp "$RESPALDO/analysis_options.yaml" "$RAIZ/analysis_options.yaml"
cp "$RESPALDO/README.md" "$RAIZ/README.md"

ANDROID_MANIFEST="$RAIZ/android/app/src/main/AndroidManifest.xml"
if [[ -f "$ANDROID_MANIFEST" ]] && ! grep -q 'android.permission.CAMERA' "$ANDROID_MANIFEST"; then
  python3 - "$ANDROID_MANIFEST" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
s = s.replace('<manifest xmlns:android="http://schemas.android.com/apk/res/android">', '<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n    <uses-permission android:name="android.permission.CAMERA" />', 1)
p.write_text(s)
PY
fi

IOS_PLIST="$RAIZ/ios/Runner/Info.plist"
if [[ -f "$IOS_PLIST" ]] && ! grep -q 'NSCameraUsageDescription' "$IOS_PLIST"; then
  python3 - "$IOS_PLIST" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
s = s.replace('</dict>', '\t<key>NSCameraUsageDescription</key>\n\t<string>Bingo Sport usa la cámara para escanear códigos QR de salas.</string>\n</dict>', 1)
p.write_text(s)
PY
fi

flutter pub get

echo "Proyecto preparado. Ejecuta: flutter run"
