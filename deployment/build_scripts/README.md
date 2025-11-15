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
