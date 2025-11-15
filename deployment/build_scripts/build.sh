#!/bin/bash

# Script de construcción para el Proyecto Heliobiología Chizhevsky
# Este script construye la aplicación frontend y prepara los archivos para despliegue.

echo "🌞 Iniciando construcción del Proyecto Chizhevsky..."

# Directorio base del proyecto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DIST_DIR="$PROJECT_DIR/dist"

# Limpiar construcción anterior
echo "🧹 Limpiando directorio de distribución..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Construcción del frontend (si hay pasos de build, como minificación, etc.)
# Por ahora, solo copiamos los archivos estáticos.

echo "📦 Copiando archivos estáticos..."

# Copiar HTML, CSS, JS y assets
cp -r "$PROJECT_DIR/src/css" "$DIST_DIR/"
cp -r "$PROJECT_DIR/src/js" "$DIST_DIR/"
cp -r "$PROJECT_DIR/src/assets" "$DIST_DIR/"
cp "$PROJECT_DIR/index.html" "$DIST_DIR/"

# Copiar datos (si están en data/)
if [ -d "$PROJECT_DIR/data" ]; then
    cp -r "$PROJECT_DIR/data" "$DIST_DIR/"
fi

# Copiar documentación (si queremos incluirla en el despliegue)
if [ -d "$PROJECT_DIR/docs" ]; then
    cp -r "$PROJECT_DIR/docs" "$DIST_DIR/"
fi

# Si hay algún paso de construcción para CSS o JS, lo hacemos aquí.
# Por ejemplo, si usamos SASS o algún bundler.

# Ejemplo para SASS (si lo usamos):
# sass "$PROJECT_DIR/src/scss/styles.scss" "$DIST_DIR/css/styles.css" --style compressed

# Ejemplo para TypeScript (si lo usamos):
# tsc --project "$PROJECT_DIR/src/ts" --outDir "$DIST_DIR/js"

echo "✅ Construcción completada en $DIST_DIR"
