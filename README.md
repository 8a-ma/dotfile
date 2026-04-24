# Guía de Implementación: i3-gaps "Mint-Edition" (ThinkPad L440)
Este documento detalla la configuración de un entorno de trabajo basado en Linux Mint 22.3 XFCE, optimizado para un ThinkPad L440 (i5-4200M, 16GB RAM) y diseñado para soportar flujos de trabajo de desarrollo y ejecución de modelos LLM.

# Especificaciones del Sistema
- SO: Linux Mint 22.3 "Wilma" (Edición XFCE).
- WM: X11 con i3-gaps.
- Gestor de Sesión: LightDM con el tema WebKit2 Greeter (Altamente personalizable).
- Hardware Target: Optimizado para ThinkPad L440 (Intel HD 4600 / 16GB RAM).

# Estructura del Proyecto
El sistema se organiza por aplicación en la carpeta de configuración:

```text
~/dotfile/
├── install.sh              # Script principal de instalación
├── install-scripts/        # Scripts modulares (inspirado en JaKooLit)
│   ├── 00-dependencies.sh
│   ├── 01-i3-gaps.sh
│   ├── 02-lightdm-custom.sh
│   └── 03-graphics-intel.sh
├── assets/                 # Wallpapers, iconos y fuentes
└── dotfiles/               # Archivos de configuración (~/.config/)
    ├── i3/                 # Configuración de i3-gaps
    ├── polybar/            # Barra de estado dinámica
    ├── rofi/               # Launcher y menús
    ├── picom/              # Compositor para transparencias/sombras
    └── nvim/               # Configuración de Neovim
```

# Componentes Clave y Configuración
## 1. Gestor de Sesión (Login Screen)
Se utilizará LightDM con LightDM WebKit2 Greeter, lo que permite usar temas basados en HTML/JS/CSS para máxima personalización estética.

- **Instalación:**
`sudo apt install lightdm lightdm-webkit2-greeter`

- **Configuración:** `/etc/lightdm/lightdm.conf` para establecer `greeter-session=lightdm-webkit2-greeter`.

## 2. Conectividad y GUI
Para cumplir con la necesidad de interfaces claras de red y Bluetooth similares a XFCE:
- **Internet:** Se mantiene `nm-applet` (Network Manager), que proporciona el icono en la bandeja del sistema idéntico al de Mint estándar.
- **Bluetooth:** Instalar `blueman`. la aplicación por defecto en entornos ligeros que ofrece una GUI completa y similar a la de Cinnamon/XFCE para gestionar dispositivos.
- **Pantalla Externa (VGA/mDP):** Se recomienda `arandr` para una gestión visual y concisa de las pantallas mediante X11, permitiendo guardar perfiles de configuración para el notebook.

## 3. Window Manager: i3-gaps
Configuración base en `~/.config/i3/config`:
```text
# Configuración de Gaps
gaps inner 10
gaps outer 5

# Compositor (Picom) para evitar screen tearing en Intel HD 4600
exec_always --no-startup-id picom --backend glx &

# Autostart de herramientas esenciales
exec --no-startup-id nm-applet &
exec --no-startup-id blueman-applet &
exec --no-startup-id polybar top &
```

# Optimizaciones para Carga de LLMs
Ejecución de agentes LLM mediante `opencode` en un i5 de 4ª generación:
1. **ZRAM/Swap:** Configurar ZRAM para manejar picos de memoria al cargar modelos en los 16GB de RAM.
2. **Gestión Térmica:** Instalar `tlp` y `thermald` para evitar el throttling excesivo del i5-4200M durante la inferencia.
3. **Prioridad de Procesos:** Usar `nice` o `ionice` para asegurar que el entorno gráfico (i3) permanezca fluido mientras el modelo LLM consume CPU.

# Creación de Widgets
Para añadir nuevos widgets al sistema (vía **Eww** o **Polybar**), sigue estos pasos:

1. **Definición de Script:** Crea un script en Bash o Python en `~/scripts/` que devuelva el dato deseado (ej. uso de memoria del LLM).
2. **Módulo de Interfaz:**
    - En **Polybar**: Define un `module/custom` que ejecute el script con un `interval`.
    - En **Eww:** Crea un `defpoll` que actualice la variable y úsala en un `widget` de tipo `box` o `text`.
3. **Estilo:** Aplica clases CSS en el archivo de estilo de la aplicación elegida para mantener la coherencia visual.

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
# Optimización para ThinkPad L440
- Gestión de Energía: Configurado con TLP para maximizar la batería.
- Gráficos: El archivo `picom.conf` utiliza el backend `glx` para suavizar animaciones sin sobrecargar la Intel HD 4600.
- Monitores Externos: Uso de `xrandr` automatizado medainte `$mod+p` para detectar conexiones VGA/mDP.

# Notas de Desarrollo
Este entorno está preparado para soportar cargas de trabajo de OpenCode y modelos LLM locales una vez finalizada la optimización del sistema base.