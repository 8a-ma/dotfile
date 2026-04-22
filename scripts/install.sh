#!/usr/bin/env bash
# =============================================================================
# install.sh — Instalador principal de Dotfiles Hypr-i3
# ThinkPad L440 | Linux Mint XFCE | i3-gaps
# =============================================================================
#
# Uso:
#   chmod +x install.sh
#   ./install.sh
#
# Qué hace:
#   1. Verifica dependencias del sistema
#   2. Instala los paquetes necesarios (apt)
#   3. Hace backup de configuraciones existentes en ~/.config-backup/
#   4. Crea symlinks de este repo hacia ~/.config/
#   5. Instala la regla udev de hotplug de pantalla
#   6. Aplica permisos de ejecución a scripts
#   7. Informa el resultado final
#
# =============================================================================

set -euo pipefail

# --- Colores y constantes ----------------------------------------------------
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"
readonly CONFIG_DIR="$HOME/.config"

# Paquetes a instalar vía apt
readonly APT_PACKAGES=(
    # Window manager
    "i3"
    "i3status"
    "i3lock"

    # Compositor y efectos
    "picom"

    # Barra de estado
    "polybar"

    # Launcher
    "rofi"

    # Terminal
    "kitty"
    "alacritty"

    # Fondo de pantalla
    "nitrogen"
    "feh"

    # Gestión de pantallas
    "arandr"
    "xrandr"

    # Notificaciones
    "dunst"
    "libnotify-bin"

    # Audio
    "pulseaudio"
    "pavucontrol"
    "playerctl"

    # Brillo
    "brightnessctl"

    # Red
    "network-manager-gnome"

    # Fuentes e iconos
    "fonts-font-awesome"
    "fonts-noto"
    "fonts-noto-color-emoji"

    # Utilidades
    "xclip"
    "xdotool"
    "xss-lock"
    "lxappearance"
    "thunar"
    "btop"
    "git"
    "curl"
    "wget"
    "unzip"
    "jq"
)

# Configuraciones que se van a linkear (origen_en_repo → destino_en_home)
declare -A CONFIG_LINKS=(
    [".config/i3"]="$CONFIG_DIR/i3"
    [".config/polybar"]="$CONFIG_DIR/polybar"
    [".config/rofi"]="$CONFIG_DIR/rofi"
    [".config/picom"]="$CONFIG_DIR/picom"
    [".config/eww"]="$CONFIG_DIR/eww"
    [".config/kitty"]="$CONFIG_DIR/kitty"
    [".config/dunst"]="$CONFIG_DIR/dunst"
)

# --- Funciones de logging ----------------------------------------------------

log_info()    { echo -e "${C_GREEN}[✔]${C_RESET} $*"; }
log_warn()    { echo -e "${C_YELLOW}[⚠]${C_RESET} $*"; }
log_error()   { echo -e "${C_RED}[✘]${C_RESET} $*" >&2; }
log_section() { echo -e "\n${C_BOLD}${C_BLUE}══ $* ══${C_RESET}\n"; }
log_step()    { echo -e "  ${C_BLUE}→${C_RESET} $*"; }

# --- Verificaciones iniciales -------------------------------------------------

check_not_root() {
    if [[ "$EUID" -eq 0 ]]; then
        log_error "No ejecutes este script como root. Usa tu usuario normal."
        log_error "El script pedirá sudo cuando lo necesite."
        exit 1
    fi
}

check_linux_mint() {
    if [[ ! -f /etc/linuxmint/info ]]; then
        log_warn "No se detectó Linux Mint. El script está optimizado para Mint/Ubuntu."
        read -rp "  ¿Continuar de todas formas? [s/N]: " response
        [[ "$response" =~ ^[sS]$ ]] || exit 0
    fi
}

check_internet() {
    log_step "Verificando conexión a internet..."
    if ! ping -c1 -W2 apt.example.com &>/dev/null && \
       ! curl -s --head --connect-timeout 3 http://archive.ubuntu.com > /dev/null 2>&1; then
        log_warn "No se pudo verificar la conexión. Continuando..."
    else
        log_info "Conexión a internet OK."
    fi
}

# --- Instalación de paquetes --------------------------------------------------

install_packages() {
    log_section "Instalando paquetes del sistema"

    log_step "Actualizando índice de paquetes..."
    sudo apt-get update -qq

    local to_install=()
    for pkg in "${APT_PACKAGES[@]}"; do
        if dpkg -s "$pkg" &>/dev/null 2>&1; then
            log_step "$pkg — ya instalado, omitiendo."
        else
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_info "Todos los paquetes ya están instalados."
        return 0
    fi

    log_step "Instalando: ${to_install[*]}"
    sudo apt-get install -y "${to_install[@]}"
    log_info "Paquetes instalados correctamente."
}

# --- Backup de configuraciones existentes ------------------------------------

backup_existing_configs() {
    log_section "Haciendo backup de configuraciones existentes"

    local needs_backup=false
    for src_key in "${!CONFIG_LINKS[@]}"; do
        local dest="${CONFIG_LINKS[$src_key]}"
        if [[ -e "$dest" && ! -L "$dest" ]]; then
            needs_backup=true
            break
        fi
    done

    if ! $needs_backup; then
        log_info "No hay configuraciones existentes que respaldar."
        return 0
    fi

    mkdir -p "$BACKUP_DIR"
    log_step "Backup en: $BACKUP_DIR"

    for src_key in "${!CONFIG_LINKS[@]}"; do
        local dest="${CONFIG_LINKS[$src_key]}"
        local name
        name="$(basename "$dest")"

        if [[ -e "$dest" && ! -L "$dest" ]]; then
            mv "$dest" "$BACKUP_DIR/$name"
            log_step "Respaldado: $dest → $BACKUP_DIR/$name"
        fi
    done

    log_info "Backup completado en $BACKUP_DIR"
}

# --- Creación de symlinks -----------------------------------------------------

create_symlinks() {
    log_section "Vinculando configuraciones (symlinks)"

    for src_key in "${!CONFIG_LINKS[@]}"; do
        local src="$DOTFILES_DIR/$src_key"
        local dest="${CONFIG_LINKS[$src_key]}"
        local dest_parent
        dest_parent="$(dirname "$dest")"

        # Verifica que el origen exista en el repo
        if [[ ! -e "$src" ]]; then
            log_warn "Origen no encontrado, omitiendo: $src"
            continue
        fi

        # Crea el directorio padre si no existe
        mkdir -p "$dest_parent"

        # Elimina symlink roto o crea el nuevo
        if [[ -L "$dest" ]]; then
            log_step "Actualizando symlink existente: $dest"
            rm "$dest"
        fi

        ln -sf "$src" "$dest"
        log_info "Vinculado: $dest → $src"
    done
}

# --- Permisos de ejecución en scripts ----------------------------------------

set_permissions() {
    log_section "Aplicando permisos de ejecución"

    local script_dirs=(
        "$DOTFILES_DIR/.config/i3/scripts"
        "$DOTFILES_DIR/scripts"
        "$DOTFILES_DIR/.config/polybar"
        "$DOTFILES_DIR/.config/eww/scripts"
    )

    for dir in "${script_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            find "$dir" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
            log_info "Permisos aplicados en: $dir"
        fi
    done
}

# --- Regla udev de hotplug ----------------------------------------------------

install_udev_rule() {
    log_section "Configurando detección automática de monitor (udev)"

    local rule_src="$DOTFILES_DIR/scripts/95-monitor-hotplug.rules"
    local rule_dst="/etc/udev/rules.d/95-monitor-hotplug.rules"
    local username
    username="$(whoami)"

    if [[ ! -f "$rule_src" ]]; then
        log_warn "Archivo de regla udev no encontrado: $rule_src"
        return 0
    fi

    # Sustituye el placeholder NOMBRE_USUARIO por el usuario real
    local tmp_rule
    tmp_rule="$(mktemp)"
    sed "s/NOMBRE_USUARIO/$username/g" "$rule_src" > "$tmp_rule"

    sudo cp "$tmp_rule" "$rule_dst"
    rm "$tmp_rule"
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    log_info "Regla udev instalada. Monitor externo detectado automáticamente al conectar."
}

# --- Configuración de i3 por defecto -----------------------------------------

configure_i3_defaults() {
    log_section "Verificando configuración de i3"

    local i3_config="$CONFIG_DIR/i3/config"

    if [[ ! -f "$i3_config" ]]; then
        log_warn "Archivo i3/config no encontrado. Asegúrate de que el repo lo incluya."
    else
        log_info "Archivo i3/config presente."
    fi
}

# --- Resumen final ------------------------------------------------------------

print_summary() {
    echo ""
    echo -e "${C_BOLD}${C_GREEN}╔══════════════════════════════════════════╗"
    echo -e "║   ✅  Instalación completada con éxito   ║"
    echo -e "╚══════════════════════════════════════════╝${C_RESET}"
    echo ""
    echo -e "  ${C_BOLD}Próximos pasos:${C_RESET}"
    echo -e "  1. Cierra sesión y selecciona ${C_BOLD}i3${C_RESET} en el login screen."
    echo -e "  2. Al iniciar, presiona ${C_BOLD}\$mod+Shift+r${C_RESET} para recargar la config."
    echo -e "  3. Gestión de pantallas: ${C_BOLD}\$mod+p${C_RESET} para abrir el menú."
    echo ""
    echo -e "  ${C_YELLOW}Log de instalación:${C_RESET} /tmp/install-dotfiles.log"
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "  ${C_YELLOW}Backup de configs previas:${C_RESET} $BACKUP_DIR"
    fi
    echo ""
}

# --- Main --------------------------------------------------------------------

main() {
    # Redirige stderr al log también
    exec 2> >(tee -a /tmp/install-dotfiles.log >&2)

    echo ""
    echo -e "${C_BOLD}${C_BLUE}"
    echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
    echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
    echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
    echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
    echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
    echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
    echo -e "${C_RESET}"
    echo -e "  ${C_BOLD}Hypr-i3 Dotfiles — ThinkPad L440${C_RESET}"
    echo ""

    check_not_root
    check_linux_mint
    check_internet
    install_packages
    backup_existing_configs
    create_symlinks
    set_permissions
    install_udev_rule
    configure_i3_defaults
    print_summary
}

main "$@"