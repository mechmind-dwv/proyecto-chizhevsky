#!/bin/bash

# 🚀 Script de despliegue para Proyecto Heliobiología Chizhevsky

set -e

echo "🌞 Iniciando despliegue del Proyecto Chizhevsky..."

# Variables
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEPLOY_DIR="$PROJECT_ROOT/deployment"
BUILD_DIR="$PROJECT_ROOT/dist"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Verificar que existe el build
check_build() {
    if [ ! -d "$BUILD_DIR" ]; then
        log_error "No se encontró directorio de build. Ejecuta build.sh primero."
        exit 1
    fi
    
    if [ ! -f "$BUILD_DIR/index.html" ]; then
        log_error "Build incompleto. Falta index.html"
        exit 1
    fi
}

# Desplegar con Docker
deploy_docker() {
    log_info "Desplegando con Docker Compose..."
    cd "$DEPLOY_DIR"
    
    # Crear secrets si no existen
    mkdir -p secrets
    if [ ! -f "secrets/db_password.txt" ]; then
        echo "chizhevsky_$(openssl rand -hex 16)" > secrets/db_password.txt
    fi
    if [ ! -f "secrets/grafana_password.txt" ]; then
        echo "admin_$(openssl rand -hex 16)" > secrets/grafana_password.txt
    fi
    
    # Crear certificados SSL self-signed para desarrollo
    mkdir -p ssl
    if [ ! -f "ssl/chizhevsky.key" ]; then
        log_info "Generando certificados SSL..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ssl/chizhevsky.key \
            -out ssl/chizhevsky.crt \
            -subj "/C=US/ST=Science/L=Cosmos/O=Heliobiology/CN=chizhevsky.local"
    fi
    
    # Desplegar
    docker-compose down
    docker-compose up -d
    
    log_info "✅ Despliegue Docker completado"
}

# Verificar servicios
check_services() {
    log_info "Verificando servicios..."
    
    sleep 10  # Esperar que los servicios inicien
    
    # Verificar web
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        log_info "✅ Servicio web funcionando"
    else
        log_error "❌ Servicio web no responde"
    fi
    
    # Verificar nginx
    if curl -f http://localhost > /dev/null 2>&1; then
        log_info "✅ Nginx funcionando"
    else
        log_error "❌ Nginx no responde"
    fi
}

# Mostrar información de despliegue
show_deploy_info() {
    log_info "🎉 Despliegue completado!"
    echo ""
    echo "🌐 URLs de acceso:"
    echo "   Frontend:    http://localhost"
    echo "   API:         http://localhost:3000"
    echo "   Monitor:     http://localhost:3001"
    echo ""
    echo "🔧 Comandos útiles:"
    echo "   Ver logs:    docker-compose logs -f"
    echo "   Detener:     docker-compose down"
    echo "   Reiniciar:   docker-compose restart"
    echo ""
    echo "📊 Health checks:"
    echo "   Aplicación:  http://localhost/health"
    echo "   Web:         http://localhost:3000/health"
}

# Función principal
main() {
    log_info "Iniciando proceso de despliegue..."
    
    check_build
    deploy_docker
    check_services
    show_deploy_info
}

main "$@"
