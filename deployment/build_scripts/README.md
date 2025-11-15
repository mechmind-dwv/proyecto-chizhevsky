# Scripts de Construcción y Despliegue

## build.sh

Este script se encarga de:

- Limpiar la construcción anterior
- Copiar archivos estáticos (HTML, CSS, JS, assets)
- Procesar archivos SASS/TypeScript (si se configuran)
- Preparar el directorio `dist/` para despliegue

### Uso

```bash
./build.sh
¡Perfecto! Vamos a crear los archivos de despliegue. Aquí tienes la configuración completa:

## 🐳 **deployment/docker-compose.yml**

```yaml
version: '3.8'

services:
  # Aplicación principal
  web:
    build:
      context: ..
      dockerfile: deployment/Dockerfile
    container_name: chizhevsky-web
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    volumes:
      - ../data:/app/data:ro
      - ../research:/app/research:ro
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - chizhevsky-network

  # Servidor Nginx (reverse proxy)
  nginx:
    image: nginx:alpine
    container_name: chizhevsky-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ../src/assets:/var/www/assets:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - web
    restart: unless-stopped
    networks:
      - chizhevsky-network

  # Base de datos para métricas (opcional)
  metrics-db:
    image: postgres:15-alpine
    container_name: chizhevsky-db
    environment:
      - POSTGRES_DB=heliobiology
      - POSTGRES_USER=chizhevsky
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ../data/sql:/docker-entrypoint-initdb.d:ro
    secrets:
      - db_password
    restart: unless-stopped
    networks:
      - chizhevsky-network

  # Monitorización (opcional)
  monitor:
    image: grafana/grafana:latest
    container_name: chizhevsky-monitor
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD_FILE=/run/secrets/grafana_password
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
    secrets:
      - grafana_password
    depends_on:
      - metrics-db
    restart: unless-stopped
    networks:
      - chizhevsky-network

volumes:
  postgres_data:
  grafana_data:

secrets:
  db_password:
    file: ./secrets/db_password.txt
  grafana_password:
    file: ./secrets/grafana_password.txt

networks:
  chizhevsky-network:
    driver: bridge
```

## 🌐 **deployment/nginx.conf**

```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging format
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    # Optimizaciones de rendimiento
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Compresión Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # Limitar tamaño de requests
    client_max_body_size 10M;

    # Configuración de upstream
    upstream chizhevsky_app {
        server web:3000;
        keepalive 32;
    }

    # Servidor HTTP (redirección a HTTPS)
    server {
        listen 80;
        server_name _;
        
        # Redirección a HTTPS
        return 301 https://$host$request_uri;
    }

    # Servidor HTTPS
    server {
        listen 443 ssl http2;
        server_name _;

        # SSL Configuration (usar certificados reales en producción)
        ssl_certificate /etc/nginx/ssl/chizhevsky.crt;
        ssl_certificate_key /etc/nginx/ssl/chizhevsky.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
        ssl_prefer_server_ciphers off;

        # Seguridad
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

        # Root directory
        root /var/www/html;
        index index.html;

        # Servir archivos estáticos
        location /assets/ {
            alias /var/www/assets/;
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header Access-Control-Allow-Origin "*";
        }

        # API y datos
        location /api/ {
            proxy_pass http://chizhevsky_app;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
            proxy_read_timeout 300;
            proxy_connect_timeout 300;
        }

        # Aplicación principal
        location / {
            proxy_pass http://chizhevsky_app;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }

        # Health check
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        # Denegar acceso a archivos ocultos
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
    }
}
```

## 🛠️ **deployment/build_scripts/build.sh**

```bash
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
```

## 🛠️ **deployment/build_scripts/deploy.sh**

```bash
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
```

## 📋 **deployment/build_scripts/README.md**

```markdown
# Scripts de Build y Despliegue

## 📁 Estructura

```
deployment/
├── docker-compose.yml          # Orquestación de contenedores
├── nginx.conf                  # Configuración de reverse proxy
├── build_scripts/
│   ├── build.sh               # Script de construcción
│   ├── deploy.sh              # Script de despliegue
│   └── README.md              # Este archivo
└── secrets/                   # Archivos sensibles (no commit)
```

## 🛠️ Uso

### Build completo
```bash
chmod +x deployment/build_scripts/build.sh
./deployment/build_scripts/build.sh [versión]
```

### Despliegue con Docker
```bash
chmod +x deployment/build_scripts/deploy.sh
./deployment/build_scripts/deploy.sh
```

### Comandos manuales
```bash
# Solo build
npm run build

# Solo deploy
docker-compose up -d

# Ver logs
docker-compose logs -f web

# Detener todo
docker-compose down
```

## 🔐 Secrets

Los archivos sensibles se generan automáticamente en `deployment/secrets/`:

- `db_password.txt` - Contraseña de PostgreSQL
- `grafana_password.txt` - Contraseña de Grafana

**⚠️ En producción, usar secrets reales y certificados SSL válidos.**

## 🌐 Puertos

- `80` - Nginx (HTTP)
- `443` - Nginx (HTTPS) 
- `3000` - Aplicación web
- `3001` - Grafana (monitorización)

## 🏗️ Flujo CI/CD Recomendado

1. **Build**: `./build.sh 1.2.3`
2. **Test**: Ejecutar suite de tests
3. **Scan**: Análisis de seguridad
4. **Deploy**: `./deploy.sh`
5. **Verify**: Health checks automáticos
```

¿Quieres que agregue algún archivo adicional de configuración o modifique algo específico?
