#!/usr/bin/env bash
# =============================================================================
# dotfiles.sh — Copia de configuraciones a sus destinos finales
# =============================================================================

set -euo pipefail

: "${REPO:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
 
CONFIG="$HOME/.config"
 
_log()  { printf '  \e[1;34m[·]\e[0m %s\n' "$*"; }
_ok()   { printf '  \e[1;32m[✓]\e[0m %s\n' "$*"; }
_warn() { printf '  \e[1;33m[!]\e[0m %s\n' "$*"; }