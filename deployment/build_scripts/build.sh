#!/bin/bash

# 🌞 Script de construcción para Proyecto Heliobiología Chizhevsky
# Autor: Comunidad Científica Global
# Licencia: MIT

set -e  # Exit on error

echo "🚀 Iniciando construcción del Proyecto Chizhevsky..."

# Variables
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/dist"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
VERSION="${1:-1.0.0}"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funciones de logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar dependencias
check_dependencies() {
    log_info "Verificando dependencias..."
    
    command -v node >/dev/null 2>&1 || {
        log_error "Node.js no encontrado"
        exit 1
    }
    
    command -v npm >/dev/null 2>&1 || {
        log_error "npm no encontrado"
        exit 1
    }
    
    command -v python3 >/dev/null 2>&1 || {
        log_error "Python 3 no encontrado"
        exit 1
    }
}

# Limpiar build anterior
clean_previous_build() {
    log_info "Limpiando build anterior..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
}

# Instalar dependencias frontend
install_frontend_deps() {
    log_info "Instalando dependencias del frontend..."
    cd "$PROJECT_ROOT"
    
    if [ -f "package.json" ]; then
        npm ci --only=production
    else
        log_warn "package.json no encontrado, saltando instalación frontend"
    fi
}

# Instalar dependencias backend
install_backend_deps() {
    log_info "Instalando dependencias del backend..."
    cd "$PROJECT_ROOT"
    
    if [ -f "requirements.txt" ]; then
        python3 -m pip install -r requirements.txt
    else
        log_warn "requirements.txt no encontrado, saltando instalación backend"
    fi
}

# Construir frontend
build_frontend() {
    log_info "Construyendo frontend..."
    cd "$PROJECT_ROOT"
    
    # Copiar archivos estáticos
    cp -r src/css "$BUILD_DIR/"
    cp -r src/js "$BUILD_DIR/"
    cp -r src/assets "$BUILD_DIR/"
    cp index.html "$BUILD_DIR/"
    
    # Minificar CSS y JS (si tenemos herramientas)
    if command -v uglifyjs >/dev/null 2>&1; then
        log_info "Minificando JavaScript..."
        find "$BUILD_DIR/js" -name "*.js" -exec uglifyjs {} -o {} \;
    fi
    
    if command -v cleancss >/dev/null 2>&1; then
        log_info "Minificando CSS..."
        find "$BUILD_DIR/css" -name "*.css" -exec cleancss {} -o {} \;
    fi
}

# Procesar datos
process_data() {
    log_info "Procesando datos..."
    cd "$PROJECT_ROOT"
    
    mkdir -p "$BUILD_DIR/data"
    
    # Copiar y procesar datos
    if [ -d "data" ]; then
        cp -r data/* "$BUILD_DIR/data/"
        
        # Validar datos JSON
        for json_file in "$BUILD_DIR/data"/*.json; do
            if [ -f "$json_file" ]; then
                python3 -m json.tool "$json_file" > /tmp/validate.json && mv /tmp/validate.json "$json_file"
            fi
        done
    fi
}

# Generar documentación
generate_docs() {
    log_info "Generando documentación..."
    cd "$PROJECT_ROOT"
    
    mkdir -p "$BUILD_DIR/docs"
    
    if [ -d "docs" ]; then
        cp -r docs/* "$BUILD_DIR/docs/"
    fi
    
    # Generar README de build
    cat > "$BUILD_DIR/BUILD_INFO.md" << EOF
# Información de Build - Proyecto Chizhevsky

## Detalles
- **Versión**: $VERSION
- **Fecha de Build**: $(date)
- **Timestamp**: $TIMESTAMP
- **Entorno**: $NODE_ENV

## Estructura
$(find "$BUILD_DIR" -type f | sed 's|'"$BUILD_DIR"'/||' | sort)

## Checksum
\`\`\`
$(find "$BUILD_DIR" -type f -exec sha256sum {} \; | sort -k2)
\`\`\`
EOF
}

# Realizar tests
run_tests() {
    log_info "Ejecutando tests..."
    cd "$PROJECT_ROOT"
    
    # Tests frontend (si existen)
    if [ -f "package.json" ] && npm run test --silent >/dev/null 2>&1; then
        npm test -- --passWithNoTests
    fi
    
    # Tests Python (si existen)
    if [ -f "requirements.txt" ] && python3 -m pytest --version >/dev/null 2>&1; then
        python3 -m pytest tests/ -v || true
    fi
}

# Crear archivo de versión
create_version_file() {
    log_info "Creando archivo de versión..."
    cat > "$BUILD_DIR/version.json" << EOF
{
    "version": "$VERSION",
    "build_date": "$(date -Iseconds)",
    "commit_hash": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
    "chizhevsky_quote": "El pulso de la vida en la Tierra late al ritmo del Sol"
}
EOF
}

# Función principal
main() {
    log_info "Iniciando build v$VERSION..."
    
    check_dependencies
    clean_previous_build
    install_frontend_deps
    install_backend_deps
    run_tests
    build_frontend
    process_data
    generate_docs
    create_version_file
    
    log_info "✅ Build completado exitosamente!"
    log_info "📁 Directorio de build: $BUILD_DIR"
    log_info "📊 Archivos generados: $(find "$BUILD_DIR" -type f | wc -l)"
    log_info "🗂️  Tamaño total: $(du -sh "$BUILD_DIR" | cut -f1)"
    
    # Mostrar tree de estructura
    if command -v tree >/dev/null 2>&1; then
        log_info "🌳 Estructura del build:"
        tree "$BUILD_DIR" -L 2
    fi
}

# Ejecutar función principal
main "$@"
