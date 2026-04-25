#!/bin/bash

# =============================================================================
# Script 00: Dependencias Base - Proyecto 8a-ma/dotfile
# Basado en la Planificación para Linux Mint 22.3
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🛠️ Actualizando repositorios y sistema base...${NC}"
sudo apt update && sudo apt upgrade -y

# 1. Herramientas de Compilación y Esenciales
# Necesarias para compilar i3-gaps (si no se usa el repo) y extensiones de Python para LLMs
echo -e "${YELLOW}📦 Instalando herramientas de compilación...${NC}"
sudo apt install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    pkg-config \
    libtool \
    m4 \
    autoconf \
    automake

# 2. Dependencias de X11 y Desarrollo para i3-gaps
# Según tu Planificación.md para el ThinkPad L440
echo -e "${YELLOW}🖥️ Instalando librerías de X11 y desarrollo...${NC}"
sudo apt install -y \
    libxcb1-dev \
    libxcb-keysyms1-dev \
    libpango1.0-dev \
    libxcb-util0-dev \
    libxcb-icccm4-dev \
    libyajl-dev \
    libstartup-notification0-dev \
    libxcb-randr0-dev \
    libev-dev \
    libxcb-cursor-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    xcb \
    libxcb-shape0-dev \
    libxcb-xrm-dev

# 3. Python y Entorno para LLMs
# Crucial para la fase de "Ejecución de LLMs" de tu docs/Planificación.md
echo -e "${YELLOW}🐍 Instalando Python y gestores de paquetes...${NC}"
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev

# 4. Micro-utilidades del Sistema
echo -e "${YELLOW}🔧 Instalando utilidades de gestión...${NC}"
sudo apt install -y \
    htop \
    neofetch \
    unzip \
    software-properties-common \
    apt-transport-https

echo -e "${GREEN}✅ Fase 00: Dependencias base completadas.${NC}"