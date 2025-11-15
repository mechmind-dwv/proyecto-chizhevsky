# Guía para Contribuir al Proyecto Heliobiología

¡Gracias por tu interés en contribuir al Proyecto Heliobiología en honor a Alexander Chizhevsky! 

## Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [¿Cómo Puedo Contribuir?](#cómo-puedo-contribuir)
- [Reportando Bugs](#reportando-bugs)
- [Sugiriendo Mejoras](#sugiriendo-mejoras)
- [Tu Primera Contribución](#tu-primera-contribución)
- [Pull Requests](#pull-requests)
- [Estilos y Guías](#estilos-y-guías)
- [Atribución](#atribución)

## Código de Conducta

Este proyecto y everyone participating in it is governed by our [Código de Conducta](CODE_OF_CONDUCT.md). Al participar, se espera que upholds this code. Please report unacceptable behavior to [proyecto-chizhevsky@protonmail.com].

## ¿Cómo Puedo Contribuir?

### 🧪 Científicos e Investigadores

- Verificar correlaciones con nuevos datasets
- Proponer mecanismos biofísicos
- Replicar análisis independientes
- Contribuir con papers y bibliografía

### 💻 Desarrolladores

- Mejorar visualizaciones de datos
- Optimizar el motor de correlaciones
- Implementar nuevas funcionalidades
- Mejorar la documentación técnica

### 📚 Educadores y Traductores

- Crear material educativo
- Traducir contenido a otros idiomas
- Diseñar lecciones para aulas
- Mejorar la documentación para no técnicos

### 🔍 Revisores y Críticos

- Revisar el método científico aplicado
- Sugerir mejoras en el análisis estadístico
- Identificar sesgos o errores metodológicos

## Reportando Bugs

Esta sección te guía para reportar un bug. Sigue estas guidelines para ayudar a los mantenedores y la comunidad a entender tu reporte, reproducir el comportamiento, y encontrar related reports.

### Seguridad

**No reports security vulnerabilities en public issues.** Por favor, envíalos a [proyecto-chizhevsky@protonmail.com].

### Antes de Reportar un Bug

Realiza una búsqueda rápida en las issues para ver si el problema ya ha sido reportado. Si lo encuentras, añade un comentario en la issue existente en lugar de abrir una nueva.

### Escribiendo un Buen Reporte de Bug

Usa nuestro [template de issues](ISSUE_TEMPLATE.md) para crear tu reporte.

## Sugiriendo Mejoras

Esta sección te guía para sugerir una mejora para el proyecto, incluyendo completamente nuevas características y mejoras menores a funcionalidad existente.

### Antes de Sugerir una Mejora

Realiza una búsqueda en las issues para ver si la mejora ya ha sido sugerida. Si lo encuentras, añade un comentario en la issue existente en lugar de abrir una nueva.

### Escribiendo una Buena Sugerencia de Mejora

1. **Usa un título claro y descriptivo** para la issue.
2. **Proporciona una descripción paso a paso** de la mejora sugerida.
3. **Describe el comportamiento actual** y **explica qué comportamiento esperabas ver** y por qué.
4. **Incluye capturas de pantalla o animaciones** si es posible.

## Tu Primera Contribución

### Configuración del Entorno Local

1. Fork el repositorio
2. Clona tu fork localmente:
   ```bash
   git clone https://github.com/tu-usuario/proyecto-heliobiologia-chizhevsky.git
   cd proyecto-heliobiologia-chizhevsky
   ```
3. Crea una rama para tu feature:
   ```bash
   git checkout -b feature/nueva-caracteristica
   ```

### Estructura del Proyecto

Familiarízate con la [estructura del proyecto](../../README.md#estructura-del-proyecto) en el README principal.

### Proceso de Desarrollo

1. **Haz tus cambios** en tu rama
2. **Ejecuta tests** si existen
3. **Asegúrate de que tu código sigue las guías de estilo**
4. **Commit de tus cambios** con mensajes descriptivos
5. **Push a tu fork**
6. **Abre un Pull Request**

## Pull Requests

Sigue estos pasos para que tus contribuciones sean aceptadas:

1. Sigue las [instrucciones](#tu-primera-contribución)
2. Sigue el [template de Pull Request](PULL_REQUEST_TEMPLATE.md)
3. No olvides [enlazar tu PR a una Issue](https://help.github.com/articles/linking-a-pull-request-to-an-issue/) si existe
4. Permite que los mantenedores hagan cambios en tu rama

## Estilos y Guías

### Guías de Estilo para Código

- **JavaScript**: Usar ESLint con configuración estándar
- **Python**: Seguir PEP 8
- **HTML/CSS**: Usar formato consistente

### Guías de Commit

- Usa el formato: `tipo(ámbito): descripción breve`
- Tipos: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Ejemplo: `feat(visualizacion): añade gráfico de correlación solar`

### Guías de Documentación

- Escribe en español claro o inglés
- Incluye ejemplos cuando sea posible
- Actualiza la documentación cuando cambies el código

## Atribución

Este CONTRIBUTING.md está adaptado del [Contributing Template](https://github.com/nayafia/contributing-template) disponible en GitHub.
