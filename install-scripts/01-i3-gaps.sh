#!/bin/bash

# =============================================================================
# Script 01: Window Manager (i3-gaps) & Estética
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

# 2. Instalación de Polybar
echo -e "${YELLOW}📊 Instalando Polybar para una interfaz moderna...${NC}"
sudo apt install -y polybar

# 3. Terminal: Kitty o Alacritty (Altamente recomendados para LLMs por rendimiento)
echo -e "${YELLOW}💻 Instalando emulador de terminal (Kitty)...${NC}"
sudo apt install -y kitty

# 4. Configuración de fuentes (Crucial para iconos en la barra)
echo -e "${YELLOW}🔤 Instalando fuentes (Font Awesome & Nerd Fonts)...${NC}"
sudo apt install -y fonts-font-awesome fonts-noto-color-emoji

# 5. Creación de directorios de configuración si no existen
mkdir -p ~/.config/i3
mkdir -p ~/.config/picom
mkdir -p ~/.config/rofi


# 6. Preparación de archivos de configuración
# 6.1 I3 creamos el config
echo -e "${YELLOW}⚡ Generando configuración optimizada para I3...${NC}"
cat <<EOF > ~/.config/i3/config
# =============================================================================
# i3-gaps Config - Proyecto 8a-ma/dotfile (Mint Edition)
# Hardware: ThinkPad L440 (Intel HD 4600)
# =============================================================================

# --- Variables Principales
set $mod Mod4
set $term kitty
# set $menu rofi -show drun -theme ~/.config/rofi/config.rasi # INVESTIGAR

# --- Fuentes
font pango:JetBrainsMono Nerd Font 10

# --- Gaps (Estilo JaKooLit)
gaps inner 12
gaps outer 5
smart_gaps on
smart_borders on

# --- Apariencia de Ventanas
for_window [class=".*"] border pixel 2
default_border pixel 2
default_floating_border pixel 2

# Colores (Catppuccin Mocha para coherencia visual)
set $base    #1e1e2e
set $blue    #89b4fa
set $red     #f38ba8
set $surface #313244
set $text    #cdd6f4

client.focused          $blue    $base    $text    $blue    $blue
client.focused_inactive $surface $base    $text    $surface $surface
client.unfocused        $surface $base    $text    $surface $surface
client.urgent           $red     $base    $text    $red     $red

# --- Movimiento y Foco (hjkl)
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# --- Atajos de Aplicaciones
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m '¿Salir de i3?' -B 'Sí' 'i3-msg exit'"

# --- Control de Hardware (ThinkPad L440)
# Brillo
bindsym XF86MonBrightnessUp exec --no-startup-id brightnessctl set +10%
bindsym XF86MonBrightnessDown exec --no-startup-id brightnessctl set 10%-

# Audio (Usando pactl como en tu base)
bindsym XF86AudioRaiseVolume  exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume  exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute         exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
bindsym XF86AudioMicMute      exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle

# --- Gestión de Espacios de Trabajo (Workspaces)
set $ws1 "1: "
set $ws2 "2: "
set $ws3 "3: "
set $ws4 "4: "
set $ws5 "5: "

bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5

bindsym $mod+Shift+1 move container to workspace $ws1
bindsym $mod+Shift+2 move container to workspace $ws2
bindsym $mod+Shift+3 move container to workspace $ws3
bindsym $mod+Shift+4 move container to workspace $ws4
bindsym $mod+Shift+5 move container to workspace $ws5

# --- Autostart (Optimizado para LLM - Menos es más)
# Lanzar barra de estado
exec_always --no-startup-id ~/.config/polybar/launch.sh

# Fondo de pantalla (Requiere feh)
exec_always --no-startup-id feh --bg-fill ~/dotfile/wallpapers/default.jpg

# Compositor (Picom para transparencias suaves)
exec --no-startup-id picom --config ~/.config/picom/picom.conf -b

# Applets esenciales (Red y Bluetooth)
exec --no-startup-id nm-applet
exec --no-startup-id blueman-applet

# Notificaciones ligeras
exec --no-startup-id dunst

# --- Modo Resize
mode "resize" {
    bindsym h resize shrink width 10 px
    bindsym j resize grow height 10 px
    bindsym k resize shrink height 10 px
    bindsym l resize grow width 10 px
    bindsym Escape mode "default"
    bindsym Return mode "default"
}
bindsym $mod+r mode "resize"

# Reglas de ventanas (Flotantes)
for_window [window_role="pop-up"] floating enable
for_window [window_role="task_dialog"] floating enable
for_window [class="Blueman-manager"] floating enable
for_window [class="Pavucontrol"] floating enable

# Priorizar el servidor X y picom sobre procesos de fondo (LLM)
exec --no-startup-id renice -n -5 $(pgrep -x Xorg)
exec --no-startup-id renice -n -5 $(pgrep -x picom)
EOF


# 6.2 Picom creamos un config base optimizado para no consumir CPU (Configuración Anti-Tearing para Intel HD 4600)
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