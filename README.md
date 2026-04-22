# Dotfiles Hypr-i3 (ThinkPad L440)
Este repositorio contiene la configuración modular de i3-gaps diseñada para emular la estética y experiencia de usuario de Hyprland en un entorno Linux Mint XFCE. Optimizado específicamente para el hardware de una ThinkPad L440 (Intel HD 4600) y flujos de trabajo de desarrollo de software y ejecución de agentes LLM.

# Especificaciones del Sistema
- SO: Linux Mint (Base XFCE recomendada).
- WM: i3-gaps.
- Compositor: Picom (con animaciones y bordes redondeados).
- Barra: Polybar.
- Terminal: Kitty / Alacritty.
- Launcher: Rofi.

# Estructura del Proyecto
```text
~/dotfile/
├── .config/
│   ├── i3/                       # Configuración de ventanas y atajos core
│   │   ├── config                # Archivo principal de i3
│   │   └── scripts/              # Scripts específicos de i3 (VGA, scratchpads)
│   ├── polybar/                  # Barra de estado superior
│   │   ├── config.ini            # Estructura de la barra
│   │   └── launch.sh             # Script de arranque
│   ├── rofi/                     # Menú de aplicaciones y sesión
│   │   ├── config.rasi           # Configuración del launcher
│   │   └── themes/               # Temas (Dracula/Catppuccin)
│   ├── picom/                    # Efectos visuales y transparencia
│   │   └── picom.conf            # Compositor (Sombras y Gaps)
|   ├── eww/                      # Dashboard y widgets personalizados
│   ├── kitty/                    # Configuración de la terminal
│   │   └── kitty.conf            # Terminal configurada
│   └── dunst/                    # Notificaciones del sistema
│       └── dunstrc               # Notificaciones
├── .themes/                      # Temas GTK
├── scripts/                      # Automatización (VGA, Audio, Brillo)
│   └── install.sh                # Script de instalación principal
├── .gitignore                    # Filtros para Git
└── README.md                     # Documentación del sistema
```

# Instalación Rápida
1. Clonar repositorio
``` bash
git clone https://github.com/8a-ma/dotfile.git ~/dotfile
```

2. Ejecutar el instalador:
``` bash
cd ~/dotfile/scripts
chmod +x install.sh
./install.sh
```

*El script instalará las dependencias necesarias (`i3-gaps`, `polybar`, `picom`, `rofi`, `nitrogen`, etc.) y vinculará los archivos de configuración.*

# Guía de Creación de Widgets (Eww)
Para extender el sistema con nuevos elementos visuales (Dashboards, controles de volumen, etc.):
1. Definir el Widget: Edita `~/.config/eww/eww.yuck` para declarar la estructura del widget
2. Aplicar Estilo: `~/.config/eww/eww.scss` para definir colores y bordes redondeados
3. Lógica de Datos: Los widgets deben consumir datos de scripts en `~/.config/eww/scripts/`
4. Recarga: Los cambios se aplican instantáneamente al guardar, o usa `eww reload` para forzar la actualización.

# Optimización para ThinkPad L440
- Gestión de Energía: Configurado con TLP para maximizar la batería.
- Gráficos: El archivo `picom.conf` utiliza el backend `glx` para suavizar animaciones sin sobrecargar la Intel HD 4600.
- Monitores Externos: Uso de `xrandr` automatizado medainte `$mod+p` para detectar conexiones VGA/mDP.

# Notas de Desarrollo
Este entorno está preparado para soportar cargas de trabajo de OpenCode y modelos LLM locales una vez finalizada la optimización del sistema base.

