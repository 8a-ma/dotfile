#!/usr/bin/env bash
# =============================================================================
# display.sh — Gestión automática de pantallas para ThinkPad L440
# =============================================================================
# Uso:
#   display.sh             → Detección automática (modo principal)
#   display.sh --mirror    → Duplicar pantalla en monitor externo
#   display.sh --extend    → Extender escritorio (externo a la derecha)
#   display.sh --internal  → Solo pantalla interna (desconecta externo)
#   display.sh --status    → Muestra el estado actual de las salidas
#   display.sh --menu      → Lanza menú interactivo con rofi
#
# Bindea en i3/config:
#   bindsym $mod+p exec --no-startup-id ~/.config/i3/scripts/display.sh --menu
# =============================================================================

set -euo pipefail

# --- Constantes y colores para logs -----------------------------------------
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/tmp/display-manager.log"
readonly NOTIFY_TIMEOUT=4000  # ms

C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

# --- Funciones de utilidad ---------------------------------------------------

log() {
    local level="$1"; shift
    local msg="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"

    case "$level" in
        INFO)  echo -e "${C_GREEN}[INFO]${C_RESET}  $msg" ;;
        WARN)  echo -e "${C_YELLOW}[WARN]${C_RESET}  $msg" ;;
        ERROR) echo -e "${C_RED}[ERROR]${C_RESET} $msg" ;;
        DEBUG) echo -e "${C_BLUE}[DEBUG]${C_RESET} $msg" ;;
    esac
}

notify() {
    local summary="$1"
    local body="${2:-}"
    local icon="${3:-display}"

    if command -v notify-send &>/dev/null; then
        notify-send \
            --urgency=normal \
            --expire-time="$NOTIFY_TIMEOUT" \
            --icon="$icon" \
            "🖥️  $summary" \
            "$body" \
            2>/dev/null || true
    fi
    log INFO "$summary — $body"
}

# Verifica que xrandr esté disponible
check_dependencies() {
    local missing=()
    local deps=("xrandr")

    for dep in "${deps[@]}"; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log ERROR "Dependencias faltantes: ${missing[*]}"
        log ERROR "Instala con: sudo apt install ${missing[*]}"
        exit 1
    fi
}

# --- Detección de pantallas --------------------------------------------------

# Detecta la salida interna del notebook (eDP, LVDS)
get_internal_output() {
    xrandr --query | grep -E "^(eDP|LVDS)" | grep " connected" | awk '{print $1}' | head -n1
}

# Detecta la primera salida externa conectada (VGA, HDMI, DP)
get_external_output() {
    xrandr --query | grep -E "^(VGA|HDMI|DP|DVI)" | grep " connected" | awk '{print $1}' | head -n1
}

# Detecta todas las salidas externas conectadas
get_all_external_outputs() {
    xrandr --query | grep -E "^(VGA|HDMI|DP|DVI)" | grep " connected" | awk '{print $1}'
}

# Obtiene la resolución nativa preferida de una salida
get_preferred_resolution() {
    local output="$1"
    xrandr --query | awk "
        /^${output} / { found=1; next }
        found && /^\s+[0-9]+x[0-9]+/ { print \$1; exit }
    "
}

# Obtiene la resolución actual activa de una salida
get_current_resolution() {
    local output="$1"
    xrandr --query | grep -A1 "^${output} connected" | \
        grep -oP '\d+x\d+\+\d+\+\d+' | head -n1 | grep -oP '^\d+x\d+' || echo "off"
}

# Verifica si una pantalla está actualmente encendida
is_output_active() {
    local output="$1"
    xrandr --query | grep "^${output} connected" | grep -q "[0-9]x[0-9]"
}

# --- Estado del sistema ------------------------------------------------------

show_status() {
    echo ""
    echo "════════════════════════════════════════"
    echo "   Estado de Pantallas — ThinkPad L440  "
    echo "════════════════════════════════════════"

    local internal external_list
    internal="$(get_internal_output)"
    readarray -t external_list < <(get_all_external_outputs)

    # Pantalla interna
    if [[ -n "$internal" ]]; then
        local int_res
        int_res="$(get_current_resolution "$internal")"
        local int_pref
        int_pref="$(get_preferred_resolution "$internal")"
        echo -e "\n  ${C_GREEN}● Interna${C_RESET}: $internal"
        echo "    Resolución actual : $int_res"
        echo "    Resolución nativa : $int_pref"
    else
        echo -e "\n  ${C_RED}✗ No se detectó pantalla interna${C_RESET}"
    fi

    # Pantallas externas
    echo ""
    if [[ ${#external_list[@]} -eq 0 || ( ${#external_list[@]} -eq 1 && -z "${external_list[0]}" ) ]]; then
        echo -e "  ${C_YELLOW}○ Sin monitor externo conectado${C_RESET}"
    else
        for ext in "${external_list[@]}"; do
            [[ -z "$ext" ]] && continue
            local ext_res ext_pref
            ext_res="$(get_current_resolution "$ext")"
            ext_pref="$(get_preferred_resolution "$ext")"
            echo -e "  ${C_BLUE}● Externo${C_RESET}: $ext"
            echo "    Resolución actual : $ext_res"
            echo "    Resolución nativa : $ext_pref"
        done
    fi

    echo ""
    echo "════════════════════════════════════════"
    echo ""
}

# --- Modos de configuración --------------------------------------------------

# Modo: Solo pantalla interna
mode_internal_only() {
    local internal
    internal="$(get_internal_output)"

    if [[ -z "$internal" ]]; then
        log ERROR "No se encontró salida interna (eDP/LVDS)."
        notify "Error de pantalla" "No se encontró salida interna." "dialog-error"
        exit 1
    fi

    log INFO "Activando solo pantalla interna: $internal"

    # Apaga todas las salidas externas
    local external_list
    readarray -t external_list < <(get_all_external_outputs)
    for ext in "${external_list[@]}"; do
        [[ -z "$ext" ]] && continue
        log INFO "Apagando salida externa: $ext"
        xrandr --output "$ext" --off
    done

    # Asegura que la interna esté en su resolución nativa
    local pref_res
    pref_res="$(get_preferred_resolution "$internal")"
    xrandr --output "$internal" --primary --auto --preferred

    notify "Solo pantalla interna" "$internal @ ${pref_res}" "video-display"
    log INFO "Modo interno activado correctamente."

    # Reinicia polybar si está corriendo
    restart_polybar
}

# Modo: Espejo (mirror) — misma imagen en ambas pantallas
mode_mirror() {
    local internal external
    internal="$(get_internal_output)"
    external="$(get_external_output)"

    if [[ -z "$internal" ]]; then
        log ERROR "No se encontró salida interna."
        notify "Error" "No se encontró pantalla interna." "dialog-error"
        exit 1
    fi

    if [[ -z "$external" ]]; then
        log WARN "No hay monitor externo conectado para hacer mirror."
        notify "Sin monitor externo" "Conecta un VGA/HDMI primero." "dialog-warning"
        exit 0
    fi

    local int_res ext_res
    int_res="$(get_preferred_resolution "$internal")"
    ext_res="$(get_preferred_resolution "$external")"

    log INFO "Iniciando modo espejo: $internal ($int_res) ↔ $external ($ext_res)"

    # Usa la resolución de la pantalla externa para el espejo
    # Si la interna no la soporta, usa la resolución de la interna
    xrandr \
        --output "$internal" --primary --auto --preferred \
        --output "$external" --same-as "$internal" --auto

    notify "Modo Espejo activado" "$internal ↔ $external" "video-display"
    log INFO "Modo espejo configurado."

    restart_polybar
}

# Modo: Extender (el monitor externo queda a la DERECHA)
mode_extend() {
    local internal external
    internal="$(get_internal_output)"
    external="$(get_external_output)"

    if [[ -z "$internal" ]]; then
        log ERROR "No se encontró salida interna."
        notify "Error" "No se encontró pantalla interna." "dialog-error"
        exit 1
    fi

    if [[ -z "$external" ]]; then
        log WARN "No hay monitor externo conectado para extender."
        notify "Sin monitor externo" "Conecta un VGA/HDMI primero." "dialog-warning"
        exit 0
    fi

    local int_res ext_res
    int_res="$(get_preferred_resolution "$internal")"
    ext_res="$(get_preferred_resolution "$external")"

    log INFO "Iniciando modo extendido: $internal ($int_res) + $external ($ext_res) [derecha]"

    xrandr \
        --output "$internal" --primary --auto --preferred \
        --output "$external" --auto --right-of "$internal"

    notify "Modo Extendido activado" "$internal ← → $external (derecha)" "video-display"
    log INFO "Modo extendido configurado. $external a la derecha de $internal."

    restart_polybar
}

# Modo: Solo pantalla externa (útil para presentaciones con tapa cerrada)
mode_external_only() {
    local internal external
    internal="$(get_internal_output)"
    external="$(get_external_output)"

    if [[ -z "$external" ]]; then
        log WARN "No hay monitor externo conectado."
        notify "Sin monitor externo" "Conecta un VGA/HDMI primero." "dialog-warning"
        exit 0
    fi

    log INFO "Activando solo pantalla externa: $external"

    xrandr \
        --output "$external" --primary --auto --preferred \
        --output "$internal" --off

    local ext_res
    ext_res="$(get_preferred_resolution "$external")"
    notify "Solo pantalla externa" "$external @ ${ext_res}" "video-display"
    log INFO "Modo externo exclusivo activado."

    restart_polybar
}

# --- Detección automática ---------------------------------------------------
# Se ejecuta al conectar/desconectar un monitor (llamado desde udev o i3)

mode_auto() {
    local internal external
    internal="$(get_internal_output)"
    external="$(get_external_output)"

    log INFO "Detección automática iniciada."
    log INFO "Interna detectada : ${internal:-ninguna}"
    log INFO "Externa detectada : ${external:-ninguna}"

    if [[ -z "$external" ]]; then
        # Sin externo → asegura que solo esté la interna activa
        log INFO "Sin monitor externo. Activando pantalla interna."
        [[ -n "$internal" ]] && xrandr --output "$internal" --primary --auto --preferred
        notify "Pantalla interna" "Sin monitor externo detectado." "video-display"
    else
        # Externo conectado → extiende por defecto (se puede cambiar a mirror aquí)
        log INFO "Monitor externo detectado ($external). Aplicando modo extendido."
        mode_extend
    fi

    restart_polybar
}

# --- Menú interactivo con rofi -----------------------------------------------

mode_menu() {
    local internal external
    internal="$(get_internal_output)"
    external="$(get_external_output)"

    # Construye opciones dinámicamente según lo que esté conectado
    local options=()
    options+=("🖥️  Solo pantalla interna")

    if [[ -n "$external" ]]; then
        options+=("🔁  Espejo (mirror)")
        options+=("➡️  Extender (externo a la derecha)")
        options+=("📺  Solo pantalla externa")
    else
        options+=("⚠️  Sin monitor externo detectado")
    fi

    options+=("ℹ️  Ver estado actual")

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi \
        -dmenu \
        -i \
        -p "🖥️ Pantallas" \
        -theme-str 'window {width: 400px;}' \
        2>/dev/null) || { log INFO "Menú cancelado por el usuario."; exit 0; }

    case "$choice" in
        *"Solo pantalla interna"*)    mode_internal_only ;;
        *"Espejo"*)                   mode_mirror ;;
        *"Extender"*)                 mode_extend ;;
        *"Solo pantalla externa"*)    mode_external_only ;;
        *"Ver estado"*)               show_status; mode_menu ;;
        *"Sin monitor externo"*)
            notify "Sin monitor externo" "Conecta un VGA/HDMI y vuelve a intentarlo." "dialog-info"
            ;;
        *) log WARN "Opción no reconocida: $choice" ;;
    esac
}

# --- Reinicio de Polybar -----------------------------------------------------

restart_polybar() {
    if command -v polybar &>/dev/null; then
        log INFO "Reiniciando polybar..."
        # Mata instancias previas
        killall -q polybar 2>/dev/null || true
        sleep 0.5

        local launch_script="$HOME/.config/polybar/launch.sh"
        if [[ -x "$launch_script" ]]; then
            "$launch_script" &
            log INFO "Polybar reiniciada via launch.sh"
        else
            # Fallback: lanza el bar por defecto
            polybar main &>/dev/null &
            log INFO "Polybar reiniciada (fallback)."
        fi
    fi
}

# --- udev hook (para detección automática al conectar cable) ----------------
# Para activar detección automática al conectar VGA, crea una regla udev:
#
#   /etc/udev/rules.d/95-monitor-hotplug.rules:
#   ACTION=="change", SUBSYSTEM=="drm", RUN+="/bin/su tu_usuario -c 'DISPLAY=:0 XAUTHORITY=/home/tu_usuario/.Xauthority /ruta/display.sh'"
#
# El script también puede llamarse desde el hook de i3 en ~/.config/i3/config:
#   exec_always --no-startup-id ~/.config/i3/scripts/display.sh

# --- Entry point -------------------------------------------------------------

main() {
    check_dependencies

    local mode="${1:---auto}"

    case "$mode" in
        --auto)          mode_auto ;;
        --mirror)        mode_mirror ;;
        --extend)        mode_extend ;;
        --internal)      mode_internal_only ;;
        --external-only) mode_external_only ;;
        --status)        show_status ;;
        --menu)          mode_menu ;;
        --help|-h)
            echo "Uso: $SCRIPT_NAME [OPCIÓN]"
            echo ""
            echo "Opciones:"
            echo "  (sin args)       Detección automática"
            echo "  --auto           Detección automática"
            echo "  --mirror         Duplicar pantalla"
            echo "  --extend         Extender (externo a la derecha)"
            echo "  --internal       Solo pantalla interna"
            echo "  --external-only  Solo pantalla externa"
            echo "  --status         Ver estado actual"
            echo "  --menu           Menú interactivo (rofi)"
            echo "  --help           Esta ayuda"
            echo ""
            echo "Log: $LOG_FILE"
            ;;
        *)
            log ERROR "Opción desconocida: $mode"
            echo "Usa --help para ver las opciones disponibles."
            exit 1
            ;;
    esac
}

main "$@"