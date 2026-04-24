#!/bin/bash

# =============================================================================
# Script de Instalación: i3-gaps "Mint-Edition"
# Optimizado para: ThinkPad L440 (i5-4200M / 16GB RAM)
# Objetivo: Minimizar uso de CPU/RAM para ejecución de LLMs
# =============================================================================

set -e

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Iniciando instalación de i3-gaps para Linux Mint 22.3...${NC}"

# 1. Verificación de privilegios (No ejecutar como root, pero requerir sudo)
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}⚠️ No ejecutes este script como root directamente. Usa un usuario con sudo.${NC}"
    exit 1
fi

# 2. Desactivación de servicios innecesarios de XFCE (Optimización LLM)
# Esto libera ciclos de CPU y RAM eliminando procesos en segundo plano de Mint XFCE
echo -e "${YELLOW}🧠 Optimizando sistema para LLM: Desactivando servicios XFCE innecesarios...${NC}"
services_to_disable=(
    "xfce4-screensaver"
    "bluez" # Se reactivará solo si usas blueman
    "cups"  # Servicio de impresión (opcional, desactivar si no imprimes)
)

for service in "${services_to_disable[@]}"; do
    if systemctl is-active --quiet "$service"; then
        sudo systemctl stop "$service"
        sudo systemctl disable "$service"
        echo -e "${GREEN}✔ $service desactivado.${NC}"
    fi
done

# 3. Creación de directorios necesarios
mkdir -p ~/.config
mkdir -p ~/.local/share/fonts
mkdir -p ~/scripts

# 4. Ejecución modular de scripts (Inspirado en JaKooLit)
# Los scripts se encuentran en install-scripts/
chmod +x install-scripts/*.sh

echo -e "${YELLOW}📦 Instalando dependencias base...${NC}"
./install-scripts/00-dependencies.sh

echo -e "${YELLOW}🪟 Configurando Window Manager (i3-gaps)...${NC}"
./install-scripts/01-i3-gaps.sh

echo -e "${YELLOW}🔑 Configurando Login Manager (LightDM + WebKit2)...${NC}"
./install-scripts/02-lightdm-custom.sh

echo - -e "${YELLOW}🔌 Configurando Bluetooth y Red (Estilo XFCE)...${NC}"
# Instalación de blueman y nm-applet
sudo apt install --no-install-recommends -y blueman network-manager-gnome [cite: 342, 343]

# 5. Aplicación de Dotfiles
echo -e "${YELLOW}📂 Aplicando configuraciones (Dotfiles)...${NC}"
cp -r dotfiles/* ~/.config/

# 6. Configuración de Optimización LLM (ZRAM y Prioridad)
echo -e "${YELLOW}⚡ Configurando optimizaciones térmicas y de memoria...${NC}"
if [ -f "install-scripts/04-llm-optim.sh" ]; then
    ./install-scripts/04-llm-optim.sh
fi

# 7. Finalización
echo -e "${GREEN}✅ Instalación completada con éxito.${NC}"
echo -e "${YELLOW}🔄 Se recomienda reiniciar para aplicar todos los cambios de X11 y LightDM.${NC}"

# Opción de reinicio rápido
read -p " ¿Deseas reiniciar ahora? (s/n): " resp
if [[ $resp == "s" || $resp == "S" ]]; then
    sudo reboot
fi