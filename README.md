# i3-gaps "Mint-Edition" para ThinkPad L440
Este repositorio contiene los dotfiles y scripts de automatización para transformar **Linux Mint 22.3 XFCE** en un entorno de escritorio
minimalista basado en **i3-gaps**, optimizado en hardware limitado (Intel i5-4200M, 8GiB, Intel HD Graphics 4600).

El foco es bajo consumo de recursos, arranque rápido y un flujo de trabajo orientado a desarrollo de software y uso personal.

---

## Hardware objetivo

| Componente | Especificación |
|---|---|
| CPU | Intel Core i5-4200M (Haswell, 2C/4T, 2.5 GHz) |
| RAM | 8 GiB DDR3 |
| GPU | Intel HD Graphics 4600 (Mesa i965, X11) |
| Almacenamiento | HDD/SSD interno |
| Conectividad | Wi-Fi + Ethernet |

---

## Características Principales

| Rol | Programa |
|---|---|
| Base | Linux Mint 22.3 "Wilma" (X11) |
| Window manager | i3-gaps |
| Gestor de sesión | LightDM |
| Terminal | Kitty |
| Barra de estado | i3status |
| Lanzador | Rofi |
| Notificaciones | Dunst |
| Fondo de pantalla | feh |
| Swap comprimida | zram-tools (lz4) |

---

## Estructura del Proyecto

```
dotfile/
├── i3/
│   ├── config                  # Entrada principal de i3 (solo variables e includes)
│   ├── i3status.conf           # Configuración de la barra de estado
│   └── conf.d/
│       ├── appearance.conf     # Gaps, bordes y paleta de colores
│       ├── autostart.conf      # Aplicaciones que inician con la sesión
│       ├── bar.conf            # i3bar (colores y status_command)
│       ├── hardware.conf       # Teclas de volumen, brillo y media
│       ├── keybinds.conf       # Atajos de teclado principales
│       ├── rules.conf          # for_window y assign por aplicación
│       └── workspaces.conf     # Definición y bindings de workspaces 1–6
├── kitty/
│   └── kitty.conf              # Terminal: fuente, paleta, rendimiento iGPU
├── rofi/
│   ├── config.rasi             # Configuración global de Rofi
│   ├── colors/                 # Esquemas de color intercambiables (.rasi)
│   ├── launcher/               # Lanzador de aplicaciones (style-1)
│   │   ├── launcher.sh
│   │   ├── style-1.rasi
│   │   └── shared/             # fonts.rasi + colors.rasi compartidos
│   ├── powermenu/              # Menú de energía (style-9)
│   │   ├── powermenu.sh
│   │   ├── style-9.rasi
│   │   └── shared/
│   └── wallpaper/              # Selector de wallpaper con miniaturas
│       ├── ws.sh
│       └── ws.rasi
├── dunst/
│   └── dunstrc                 # Notificaciones con barras de progreso
├── zram/
│   ├── GUIDE.md                # Instrucciones para activar ZRAM
│   ├── zramswap                # Configuración: lz4, 4 GiB, priority 100
│   └── 60-swappiness.conf      # vm.swappiness = 60
├── system/
│   └── default/
│       └── grub                # Parámetros de arranque optimizados para Haswell
└── README.md
```

---

## Características destacadas

### i3 modular
 
La configuración de i3 está dividida en archivos de responsabilidad única dentro de `conf.d/`. El `config` principal solo declara variables globales y los `include`. Esto facilita editar una sola sección sin tocar el resto.

### Kitty — optimizado para Intel HD 4600
 
`text_composition_strategy legacy` evita glitches en el renderer Mesa i965. `repaint_delay 50` limita el refresco a ~20 fps, suficiente para una terminal y con bajo impacto en la iGPU. Las ligaduras están desactivadas por el mismo motivo.

### Dunst — notificaciones con barra de progreso
 
Las notificaciones de volumen y brillo muestran una barra de progreso nativa de Dunst. Las reglas por aplicación en `dunstrc` asignan íconos y timeouts distintos según la urgencia: las críticas (batería baja, errores) persisten hasta que el usuario las cierre.

### ZRAM
 
Swap comprimida en RAM con el algoritmo lz4 (prioridad velocidad sobre compresión). Tamaño fijo de 4 GiB con `PRIORITY=100`, de modo que se usa antes que cualquier swap en disco. Sigue la guía en `zram/GUIDE.md`.


## Instalación
1. Clonar el repositorio:
```bash
git clone https://github.com/8a-ma/dotfile.git ~/dotfile
```

...