#!/usr/bin/env bash
# =============================================================================
# picom-check.sh — Verifica la versión de picom y ofrece instalar FT-Labs
# =============================================================================
#
# Uso: ./picom-check.sh
#
# Comprueba si el picom instalado soporta:
#   - Bordes redondeados (corner-radius) → picom ≥ 10
#   - Animaciones de ventanas           → picom FT-Labs
#   - Blur dual_kawase                  → picom ≥ 9
#
# =============================================================================

set -euo pipefail

C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

ok()   { echo -e "  ${C_GREEN}[✔]${C_RESET} $*"; }
warn() { echo -e "  ${C_YELLOW}[⚠]${C_RESET} $*"; }
err()  { echo -e "  ${C_RED}[✘]${C_RESET} $*"; }
info() { echo -e "  ${C_BLUE}[i]${C_RESET} $*"; }

echo ""
echo -e "${C_BOLD}══ Verificador de Picom ══${C_RESET}"
echo ""

# --- Comprueba si picom está instalado
if ! command -v picom &>/dev/null; then
    err "picom no está instalado."
    info "Instala con: sudo apt install picom"
    exit 1
fi

PICOM_VERSION=$(picom --version 2>&1 | grep -oP 'v?\K[0-9]+\.[0-9]+' | head -n1)
PICOM_FULL=$(picom --version 2>&1)

echo -e "  Versión detectada: ${C_BOLD}$PICOM_FULL${C_RESET}"
echo ""

# --- Extrae el número mayor de versión
MAJOR=$(echo "$PICOM_VERSION" | cut -d. -f1)

# --- Chequea dual_kawase blur (≥ 9)
echo -e "${C_BOLD}Soporte de funcionalidades:${C_RESET}"

if [[ "$MAJOR" -ge 9 ]]; then
    ok "blur dual_kawase soportado (versión ≥ 9)"
else
    warn "blur dual_kawase NO soportado. Cambia blur-method a \"gaussian\" en picom.conf"
fi

# --- Chequea corner-radius (≥ 10)
if [[ "$MAJOR" -ge 10 ]]; then
    ok "Bordes redondeados (corner-radius) soportados (versión ≥ 10)"
else
    warn "Bordes redondeados NO soportados en esta versión."
    info "Para obtenerlos sin compilar, intenta: sudo add-apt-repository ppa:ricotz/unstable && sudo apt install picom"
fi

# --- Chequea si es FT-Labs (animaciones)
if picom --version 2>&1 | grep -qi "ftlabs\|ft-labs\|animations"; then
    ok "Animaciones de ventana soportadas (FT-Labs build)"
else
    warn "Animaciones de ventana NO soportadas (picom estándar)."
    info "El picom estándar usa fade-in/fade-out como alternativa (ya configurado)."
    echo ""
    echo -e "  Para instalar picom con animaciones (FT-Labs), ejecuta:"
    echo -e "  ${C_BLUE}~/.config/picom/install-picom-ftlabs.sh${C_RESET}"
fi

echo ""
echo -e "${C_BOLD}Para probar la configuración:${C_RESET}"
echo "  pkill picom; picom --config ~/.config/picom/picom.conf -b"
echo ""
echo -e "${C_BOLD}Para ver errores en tiempo real:${C_RESET}"
echo "  picom --config ~/.config/picom/picom.conf --log-level debug 2>&1 | tail -f"
echo ""