#!/usr/bin/env bash
# =============================================================================
# Actualizaciones del sistema
# =============================================================================

set -euo pipefail

: "${REPO:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

_log()  { printf '  \e[1;34m[·]\e[0m %s\n' "$*"; }
_ok()   { printf '  \e[1;32m[✓]\e[0m %s\n' "$*"; }
_warn() { printf '  \e[1;33m[!]\e[0m %s\n' "$*"; }

# 1. APT — actualizar índice y paquetes instalados
_log "apt update"
sudo apt-get update -qq

_log "apt upgrade"
sudo apt-get upgrade -y -q
_ok "Sistema actualizado"

# 2. GRUB — parámetros Haswell (intel_idle.max_cstate=3, i915.enable_rc6=1)
_log "Configurando GRUB"
GRUB_SRC="$REPO/system/default/grub"
GRUB_DST="/etc/default/grub"

if [[ ! -f "$GRUB_SRC" ]]; then
    _warn "No se encontró $GRUB_SRC — omitiendo GRUB"
else
    # Respaldo del grub actual antes de sobrescribir
    if [[ -f "$GRUB_DST" ]]; then
        sudo cp "$GRUB_DST" "${GRUB_DST}.bak.$(date +%Y%m%d%H%M%S)"
        _log "Respaldo creado: ${GRUB_DST}.bak.*"
    fi
    sudo cp "$GRUB_SRC" "$GRUB_DST"
    sudo update-grub
    _ok "GRUB actualizado (intel_idle, rc6)"
fi

# 3. ZRAM — swap comprimida en RAM (lz4, 4 GiB, priority 100)
_log "Instalando zram-tools"
sudo apt-get install -y -q zram-tools

_log "Copiando configuración de ZRAM"
ZRAM_SRC="$REPO/zram/zramswap"
ZRAM_DST="/etc/default/zramswap"

if [[ ! -f "$ZRAM_SRC" ]]; then
    _warn "No se encontró $ZRAM_SRC — omitiendo zramswap"
else
    sudo cp "$ZRAM_SRC" "$ZRAM_DST"
    _ok "zramswap configurado (lz4, 4 GiB)"
fi

SYSCTL_SRC="$REPO/system/sysctl.d/60-swappiness.conf"
SYSCTL_DST="/etc/sysctl.d/60-swappiness.conf"

if [[ ! -f "$SYSCTL_SRC" ]]; then
    _warn "No se encontró $SYSCTL_SRC — omitiendo swappiness"
else
    sudo mkdir -p /etc/sysctl.d
    sudo cp "$SYSCTL_SRC" "$SYSCTL_DST"
    _log "Aplicando sysctl (vm.swappiness=60)"
    sudo sysctl --system -q
    _ok "sysctl aplicado"
fi

_log "Reiniciando zramswap"
# sudo sysctl --system
# zramctl
# swapon --show

# sudo systemctl restart zramswap 2>/dev/null \
#     || sudo service zramswap restart 2>/dev/null \
#     || _warn "No se pudo reiniciar zramswap (se activará al siguiente boot)"
 
_ok "ZRAM listo"