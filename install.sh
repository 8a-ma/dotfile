#!/bin/bash

# =============================================================================
# Script de Instalación: i3-gaps "Mint-Edition"
# Optimizado para: ThinkPad L440 (i5-4200M / 16GB RAM)
# =============================================================================

clear

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Iniciando instalación de i3-gaps para Linux Mint 22.3...${NC}"

# 1. Crear directorio para logs
if [ ! -d .install-logs ]; then
    mkdir .install-logs
fi

LOG=".install-logs/01-Installer-Scripts-$(date +$%d_%H:%M:%S).log"

# 2. Verificación de privilegios (No ejecutar como root, pero requerir sudo)
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}⚠️ No ejecutes este script como root directamente. Usa un usuario con sudo.${NC}" | tee -a "$LOG"
    exit 1
fi

# 3. Desactivación de servicios innecesarios de XFCE (Optimización LLM)
# Esto libera ciclos de CPU y RAM eliminando procesos en segundo plano de Mint XFCE
echo -e "${YELLOW}🧠 Optimizando sistema para LLM: Desactivando servicios XFCE innecesarios...${NC}" | tee -a "$LOG"
services_to_disable=(
    "xfce4-screensaver"
    "bluez" # Se reactivará solo si usas blueman
    "cups"  # Servicio de impresión (opcional, desactivar si no imprimes)
)

for service in "${services_to_disable[@]}"; do
    if systemctl is-active --quiet "$service"; then
        sudo systemctl stop "$service"
        sudo systemctl disable "$service"
        echo -e "${GREEN}✔ $service desactivado.${NC}" | tee -a "$LOG"
    fi
done

# 4. Instalación de pciutils. Necesaria para detectar GPU
if ! dpkg -l | grep -qw pciutils; then
    echo "pciutils no esta instalado. Instalando..." | tee -a "$LOG"
    sudo apt install -y pciutils
fi

#5. Ejecución modular de scripts
script_directory="install-scripts"

if [ -d "$script_directory" ]; then
    chmod +x "$script_directory"/*.sh 2>/dev/null
else
    echo "Error: El directorio $script_directory no existe." | tee -a "$LOG"
    exit 1
fi

execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"

    if [ -f "$script_path" ]; then
        if [ -x "$script_path" ]; then
            env "$script_path"
        else
            echo "Fallo en hacer el script '$script' ejecutable." | tee -a "$LOG"
        fi
    else
        echo "Script '$script' no encontrado en '$script_directory'." | tee -a "$LOG"
    fi
}

##################################
# List of services to check for active login managers
check_services_running() {
    if systemctl is-active --quiet display-manager.service && dpkg -l | grep -qw lightdm; then
        return 0
    else
        return 1
    fi
}

if ! check_services_running; then
    echo "${RED}Error: No se detectó un gestor de sesión activo. Abortando instalación.${NC}" | tee -a "$LOG"
    exit 1
fi

##################################
echo "${YELLOW} Corriendo una update completa al sistema...${NC}" | tee -a "$LOG"
sudo apt update

echo -e "${YELLOW}📦 Instalando dependencias base...${NC}"
sleep 1
execute_script "00-dependencies.sh" | tee -a "$LOG"

# https://github.com/JaKooLit/Ubuntu-Hyprland/tree/24.04/install-scripts
# https://github.com/8a-ma/dotfile/tree/main