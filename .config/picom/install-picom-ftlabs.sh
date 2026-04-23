#!/usr/bin/env bash
# =============================================================================
# install-picom-ftlabs.sh — Compila e instala picom FT-Labs (con animaciones)
# =============================================================================
#
# FT-Labs es un fork de picom que agrega:
#   - Animaciones de apertura/cierre de ventanas (zoom, slide, fly-in)
#   - Animaciones de cambio de workspace
#   - Compatible con todas las demás funciones de picom estándar
#
# Repositorio: https://github.com/FT-Labs/picom
#
# Tiempo estimado de compilación en L440 (i5-4200M): ~3–5 minutos
#
# =============================================================================

set -euo pipefail

C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

ok()      { echo -e "${C_GREEN}[✔]${C_RESET} $*"; }
warn()    { echo -e "${C_YELLOW}[⚠]${C_RESET} $*"; }
err()     { echo -e "${C_RED}[✘]${C_RESET} $*"; exit 1; }
section() { echo -e "\n${C_BOLD}${C_BLUE}══ $* ══${C_RESET}\n"; }

BUILD_DIR="$HOME/.local/src/picom-ftlabs"

section "Instalando dependencias de compilación"

sudo apt-get update -qq
sudo apt-get install -y \
    libconfig-dev \
    libgl-dev \
    libpcre2-dev \
    libevdev-dev \
    libx11-xcb-dev \
    libxcb-damage0-dev \
    libxcb-dpms0-dev \
    libxcb-glx0-dev \
    libxcb-image0-dev \
    libxcb-present-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-sync-dev \
    libxcb-xfixes0-dev \
    libxcb-xinerama0-dev \
    libxcb1-dev \
    libxext-dev \
    libxresource-dev \
    uthash-dev \
    meson \
    ninja-build \
    cmake \
    pkg-config

ok "Dependencias instaladas."

section "Clonando repositorio FT-Labs"

if [[ -d "$BUILD_DIR" ]]; then
    warn "Directorio $BUILD_DIR ya existe. Actualizando..."
    cd "$BUILD_DIR"
    git pull
else
    git clone https://github.com/FT-Labs/picom "$BUILD_DIR"
    cd "$BUILD_DIR"
fi

section "Compilando picom (esto puede tomar ~5 min en el L440)"

# Limpia build anterior si existe
[[ -d build ]] && rm -rf build

meson setup --buildtype=release build
ninja -C build

ok "Compilación exitosa."

section "Instalando picom FT-Labs"

# Hace backup del picom del sistema antes de reemplazarlo
if command -v picom &>/dev/null; then
    SYSTEM_PICOM=$(which picom)
    warn "Haciendo backup de picom actual → ${SYSTEM_PICOM}.backup"
    sudo cp "$SYSTEM_PICOM" "${SYSTEM_PICOM}.backup" 2>/dev/null || true
fi

sudo ninja -C build install

ok "picom FT-Labs instalado en $(which picom)"

section "Verificación"

picom --version
echo ""

# Activa las animaciones en picom.conf descomentando el bloque
PICOM_CONF="$HOME/.config/picom/picom.conf"
if [[ -f "$PICOM_CONF" ]]; then
    ok "picom.conf encontrado en $PICOM_CONF"
    echo ""
    echo -e "  ${C_YELLOW}Ahora descomenta el bloque de animaciones en picom.conf${C_RESET}"
    echo -e "  Busca la línea: # animations = true;"
    echo -e "  y descomenta desde ahí hasta animation-exclude."
    echo ""
    echo -e "  O ejecuta este one-liner para hacerlo automáticamente:"
    echo -e "  ${C_BLUE}sed -i 's/^# animation/animation/g' ~/.config/picom/picom.conf${C_RESET}"
fi

echo ""
echo -e "${C_BOLD}Reinicia picom para aplicar:${C_RESET}"
echo "  pkill picom; picom --config ~/.config/picom/picom.conf -b"
echo ""