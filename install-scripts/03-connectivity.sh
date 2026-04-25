#!/bin/bash

# --- 03-connectivity.sh ---
# Instalación de Network Manager Applet y Blueman (Bandeja del sistema)

# Definición de colores para la terminal
CNT="[\e[1;36mNOTE\e[0m]"

echo -e "$CNT Instalando nm-applet y blueman-applet para la bandeja del sistema..."

# 1. Instalación de paquetes necesarios
# --no-install-recommends se usa para evitar bloatware y ahorrar CPU [cite: 301, 390]
sudo apt update
sudo apt install -y --no-install-recommends \
    network-manager-gnome \
    blueman \
    bluez \
    bluez-tools

# 2. Habilitar y arrancar el servicio de Bluetooth
echo -e "$CNT Configurando servicios de Bluetooth..."
sudo systemctl enable --now bluetooth

# 3. Asegurar permisos para el usuario actual (grupo bluetooth)
if ! groups $USER | grep -q bluetooth; then
    sudo usermod -aG bluetooth $USER
fi

# 4. Nota técnica para i3/config
# Para que estos aparezcan en la bandeja de Polybar, se requiere 
# tener las siguientes líneas en tu i3 config (ya contemplado en fases previas):
# exec --no-startup-id nm-applet
# exec --no-startup-id blueman-applet

echo -e "$CNT Configuración de conectividad completada."