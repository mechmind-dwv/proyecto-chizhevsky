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
