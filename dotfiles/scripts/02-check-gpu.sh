#!/bin/bash
# Script para asegurar aceleración por hardware en Intel HD 4600

echo "--- Verificando drivers Intel para Picom ---"

# Instalar drivers de aceleración necesarios
sudo apt update && sudo apt install -y --no-install-recommends \
    mesa-utils \
    libvulkan1 \
    intel-media-va-driver-non-free \
    vainfo

# Configuración para evitar el tearing a nivel de kernel/X11 si picom no bastara
if [ ! -d /etc/X11/xorg.conf.d ]; then
    sudo mkdir -p /etc/X11/xorg.conf.d
fi

cat <<EOF | sudo tee /etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
  Identifier "Intel Graphics"
  Driver "intel"
  Option "TearFree" "true"
  Option "AccelMethod" "sna"
EndSection
EOF

echo "Configuración de GPU completada. Reinicio recomendado para aplicar cambios de X11."