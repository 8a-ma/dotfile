#!/bin/bash

# =============================================================================
# Script 02: Personalización de LightDM (Gestor de Sesión)
# Objetivo: Implementar LightDM WebKit2 Greeter para estética moderna
# Proyecto: 8a-ma/dotfile - Linux Mint 22.3
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔑 Configurando LightDM y WebKit2 Greeter...${NC}"

# 1. Instalación de LightDM y el motor WebKit2
# Mint ya trae LightDM, pero necesitamos el greeter específico y sus dependencias
sudo apt install -y \
    lightdm \
    lightdm-webkit2-greeter \
    gir1.2-webkit2-4.1 \
    liblightdm-gobject-1-dev

# 2. Configuración del Greeter por defecto
# Editamos el archivo de configuración de LightDM para usar WebKit2
echo -e "${YELLOW}⚙️ Estableciendo WebKit2 como greeter principal...${NC}"
sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf

# 3. Preparación de Temas (Inspirado en el minimalismo de JaKooLit)
# Creamos el directorio de temas si no existe
sudo mkdir -p /usr/share/lightdm-webkit/themes/

# Nota: Aquí puedes clonar un tema específico (como glorious o litarvan)
# Por ahora configuramos el archivo maestro para que acepte temas externos
sudo sed -i 's/^webkit_theme.*/webkit_theme = material/' /etc/lightdm/lightdm-webkit2-greeter.conf

# 4. Habilitar el servicio LightDM
# Nos aseguramos de que LightDM esté habilitado frente a otros GDM o SDDM
sudo systemctl enable lightdm

# 5. Configuración de Sesión i3 por defecto
# Esto asegura que al iniciar sesión, i3 sea la primera opción
if [ ! -d "/usr/share/xsessions" ]; then
    sudo mkdir -p /usr/share/xsessions
fi

echo -e "${YELLOW}🖼️ Asegurando entrada de sesión para i3...${NC}"
# Normalmente i3 instala su propio .desktop, pero lo verificamos:
if [ ! -f "/usr/share/xsessions/i3.desktop" ]; then
    sudo cp /usr/share/doc/i3-wm/examples/i3.desktop /usr/share/xsessions/ 2>/dev/null || true
fi

# 6. Optimizaciones para el L440 (HiDPI / Resolución)
# Si usas un monitor externo con el L440, LightDM a veces falla en la resolución
# Creamos un script de inicio básico para LightDM
sudo bash -c 'cat <<EOF > /etc/lightdm/display-setup.sh
#!/bin/sh
xrandr --auto
EOF'
sudo chmod +x /etc/lightdm/display-setup.sh
sudo sed -i 's|^#display-setup-script=.*|display-setup-script=/etc/lightdm/display-setup.sh|' /etc/lightdm/lightdm.conf

echo -e "${GREEN}✅ Fase 02: LightDM WebKit2 configurado.${NC}"