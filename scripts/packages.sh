
#!/usr/bin/env bash
# =============================================================================
# packages.sh — Instalación de aplicaciones
# =============================================================================

set -euo pipefail

: "${REPO:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

_log()  { printf '  \e[1;34m[·]\e[0m %s\n' "$*"; }
_ok()   { printf '  \e[1;32m[✓]\e[0m %s\n' "$*"; }
_warn() { printf '  \e[1;33m[!]\e[0m %s\n' "$*"; }
_die()  { printf '  \e[1;31m[✗]\e[0m %s\n' "$*" >&2; exit 1; }

# 1. PAQUETES APT
_log "Instalando paquetes apt"

sudo apt-get install -y -q \
    i3 \
    i3status \
    dunst \
    kitty \
    rofi \
    feh \
    xss-lock \
    i3lock \
    network-manager-gnome \
    dex \
    playerctl \
    pulseaudio-utils \
    imagemagick \
    flatpak \
    wget

_ok "Paquetes apt instalados"

# 2. OBSIDIAN — AppImage
# ....

# 3. READEST — vía Flatpak (Flathub)
_log "Configurando Flatpak + Flathub"

# flatpak remote-add --user --if-not-exists flathub \
#     https://dl.flathub.org/repo/flathub.flatpakrepo \
#     2>/dev/null || true

_log "Instalando Readest"

if flatpak install --user --noninteractive -y flathub com.bilingify.readest 2>/dev/null; then
    _ok "Readest instalado"
else
    _warn "No se pudo instalar Readest desde Flathub."
    _warn "Verifica el App ID o instálalo manualmente:"
    _warn "  flatpak install flathub com.bilingify.readest"
fi
