#!/bin/bash

# =============================================================================
# Script 01: Window Manager (i3-gaps) & Estética
# Optimizado para: ThinkPad L440 - Proyecto 8a-ma/dotfile
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🪟 Instalando i3-wm y componentes del entorno...${NC}"

# 1. Instalación de i3 y utilidades base de escritorio
# Instalamos i3-wm (soporta gaps nativamente en Mint 22) y herramientas ligeras
sudo apt install -y \
    i3-wm \
    i3status \
    i3lock \
    suckless-tools \
    feh \
    picom \
    rofi \
    thunar \
    lxappearance \
    nitrogen

# 2. Instalación de Polybar (Opcional pero recomendado en el estilo JaKooLit)
# Si prefieres i3status, puedes omitir esto, pero Polybar es más flexible.
echo -e "${YELLOW}📊 Instalando Polybar para una interfaz moderna...${NC}"
sudo apt install -y polybar

# 3. Terminal: Kitty o Alacritty (Altamente recomendados para LLMs por rendimiento)
echo -e "${YELLOW}💻 Instalando emulador de terminal (Kitty)...${NC}"
sudo apt install -y kitty

# 4. Configuración de fuentes (Crucial para iconos en la barra)
echo -e "${YELLOW}🔤 Instalando fuentes (Font Awesome & Nerd Fonts)...${NC}"
sudo apt install -y fonts-font-awesome fonts-noto-color-emoji
# Nota: Se asume que las Nerd Fonts se gestionarán en un script de assets posterior.

# 5. Creación de directorios de configuración si no existen
mkdir -p ~/.config/i3
mkdir -p ~/.config/picom
mkdir -p ~/.config/rofi

# 6. Preparación de Picom (Configuración Anti-Tearing para Intel HD 4600)
# Creamos un config base optimizado para no consumir CPU
echo -e "${YELLOW}⚡ Generando configuración optimizada para Picom...${NC}"
cat <<EOF > ~/.config/picom/picom.conf
backend = "glx";
glx-no-stencil = true;
glx-copy-from-front = false;
vsync = true;
backend = "xrender"; # Cambiar a glx si hay tearing, xrender es más ligero para CPU
mark-wmwin-focused = true;
mark-ovlp-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
detect-transient = true;
detect-client-leader = true;
use-damage = true;
log-level = "warn";
EOF

echo -e "${GREEN}✅ Fase 01: i3-wm y componentes instalados correctamente.${NC}"