#!/bin/bash
# install.sh - Script de instalación automática

echo "🌞 Instalando Proyecto Heliobiología Chizhevsky..."

# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Crear estructura de carpetas
mkdir -p data/raw data/processed docs research/papers src/{js,css,assets}

echo "✅ Instalación completada!"
echo "🌍 Activación: source venv/bin/activate"
echo "🚀 Ejecución: python src/main.py"
