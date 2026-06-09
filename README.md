# i3-gaps "Mint-Edition" para ThinkPad L440
Este repositorio contiene los dotfiles y scripts de automatización para transformar **Linux Mint 22.3 XFCE** en un entorno de alto rendimiento basado en **i3-gaps**, optimizado en hardware limitado (Intel i5-4200M, 8GB, Intel HD Graphics 4600).

## Características Principales
- **Base:** Linux Mint 22.3 "Wilma" (X11).
- **Window Manager:** i3-gaps con soporte de gaps dinámicos.
- **Gestor de Sesión:** lightdm
- **Barra de Estado:** i3status
- **Lanzador de aplicaciones:** Rofi

## Estructura del Proyecto
Cada programa tiene su propia carpeta con su configuración respectiva

## Instalación
1. Clonar el repositorio:
```bash
git clone https://github.com/8a-ma/dotfile.git ~/dotfile
```
...

# Optimización local
# To-Do
- [ ] Reconfiguración
    - [X] I3
        - [X] Separación de configuración en archivos de con responsabilidad única (bindkeys, Autostart-apps, workspaces, etc..)
        - [~] Implementación del uso de xrandr para resoluciones externas vía mDP
        - [X] I3 status
            - [~] Monitoreo de RAM con `htop`
    - [X] Kitty
    - [X] Dunst
    - [ ] Rofi
        - [X] Launcher
        - [ ] wallpaper selector
        - [ ] Powermenu
- [ ] Optimización i3-status para bajo consumo de ciclos
- [ ] Implementación ZRAM con un ratio 1:1.5
- [ ] Implementación picom
- [ ] terminar README