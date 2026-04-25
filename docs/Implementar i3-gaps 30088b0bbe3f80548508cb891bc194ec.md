# Implementar i3-gaps

## Requerimientos
- Tener una GUI para las conexiones a internet como la aplicación por defecto de network de linux mint cinnamon
- Tener una manera clara y concisa para poder compartir pantalla al conectar el VGA al notebook
- Tener todas las carpetas del nuevo sistema organizados por aplicación (smiliar a lo que tiene jakoolit en https://github.com/JaKooLit/Ubuntu-Hyprland)
- Las consideraciones y reqerimientos redactados a lo largo del documento.
- El gestor de sesión debe de ser posible editarlo y personalizarlo lo máximo posible (personalización principalmente estética)
- La creación de nuevos widgets para este sistema debe de ser un apartado completo en el README.md

## Recomendaciones

Para codificar y diseñar sistemas en Linux Mint con i3-gaps en un ThinkPad L440 (i5-4200M, 16 GB RAM, SSD 960 GB), enfócate en instalación ligera, atajos eficientes, herramientas dev y optimizaciones de hardware para desarrollo de software y ejecución de agentes LLMs usando opencode (la instalación de opencode y de los modelos LLM se harán post instalación del i3-gaps por parte del usuario, la tarea es solo optimizar el linux mint para soportar la carga del uso de los modelos).

- Instala Linux Mint (edición XFCE para base ligera), luego agrega i3-gaps vía apt: `sudo apt install i3 i3status dmenu`.
- Selecciona "i3" en el login screen; genera config inicial (~/.config/i3/config) con modkey Win.
- Añade gaps: `gaps inner 10` y `gaps outer 5`; reinicia con `$mod+Shift+r`.

### **Atajos Esenciales para Dev**

| **Acción** | **Atajo ($mod=Win)** |
| --- | --- |
| Terminal (zsh) | $mod+Enter |
| Nueva ventana | $mod+Enter |
| Workspaces (1-10) | $mod+1 a $mod+0 |
| Mover ventana | $mod+Shift+<num> |
| Split horizontal | $mod+h / $mod+v |
| Fullscreen | $mod+f |
| Scratchpad (notas) | $mod+Shift+Minus |

Configura `bindsym $mod+d exec dmenu_run` para launchers rápidos.

### **Herramientas de Desarrollo**

- **Editor/IDE**: VS Code (`code --install-extension ms-vscode.cpptools`).
- **Terminal dev**: zsh (Oh My Zsh); `sudo apt install build-essential git curl`.
- **Gestión**: LazyGit, Docker (para contenedores), Podman; Polybar para status (CPU/RAM/batería).
- **Diseño sistemas**: Draw.io (diagrama.cl), PlantUML para UML en Markdown.

### **Optimizaciones L440**

- **Gráficos Intel HD 4600**: `sudo apt install mesa-utils`; usa xrandr para resoluciones externas vía mDP.
- **Teclado/Trackpoint**: `xset m 0 0` para sensibilidad; fn+Trackpoint buttons para scroll.
- **Batería/Power**: TLP (`sudo apt install tlp tlp-rdw`), undervolt con ThrottleStop en Wine si dual-boot.
- **RAM**: Actualiza a 16 GB; monitorea con `htop` o `btop`.
- **Audio/WiFi**: PulseAudio/Pipewire; firmware Intel si AC estándar falla.

### **Flujo de Trabajo Dev**

1. Workspace 1: Terminal + editor (nvim/VSCode).
2. Workspace 2: Browser (Brave) + docs.
3. Workspace 3: Docker/VMs (QEMU/Virt-Manager).
4. Usa scratchpad para logs; `i3-msg [class="^float$"] move scratchpad` para floats (diagrama.cl).
5. Autostart apps: Agrega `exec_always --no-startup-id` en config para Polybar, picom (compositing).

### **Configuración Inicial Recomendada**

Copia este bloque base en ~/.config/i3/config:

```jsx
set $mod Mod4
gaps inner 10
bindsym $mod+Return exec alacritty
bindsym $mod+d exec dmenu_run
bindsym $mod+q kill
exec --no-startup-id polybar top
```

Prueba con `i3-msg restart`; backup config en Git. Esto maximiza productividad en hardware limitado sin lags.

### Documentación oficial

Revisa el **User's Guide de i3** (i3wm.org/docs/userguide.html): cubre gaps, bindings, scratchpad, floating y scripting IPC para automatizaciones.

Para gaps específicos, usa `gaps:inner|outer_size` y `smart_gaps` en ~/.config/i3/config; reload con `$mod+Shift+r`. https://www.youtube.com/watch?v=5gpxoQRMMG4

Wiki de i3-gaps en GitHub (github.com/Airblader/i3/wiki) explica animaciones básicas vía `animation_duration` y easing.

### **Guías para Funcionalidades Avanzadas**

- **Polybar**: Status bar dinámica (github.com/polybar/polybar/wiki). Instala `sudo apt install polybar`, configura módulos para CPU/RAM/batería L440: `module/thinkpad-battery`.
- **Picom**: Animaciones y sombras (`sudo apt install picom`). En config: `shadow = true; fading = true; animation = true;`, backend "glx" para Intel HD 4600.
- **Rofi**: Launcher moderno (`rofi -show drun`), dmenu replacement con themes (github.com/davatorium/rofi).
- **Eww**: Widgets flotantes (elkowar.github.io/eww/); ideal para dashboards dev sin sobrecargar RAM.

### **Mejoras en Configuración**

| Mejora | Configuración en ~/.config/i3/config | Beneficio en L440 |
| --- | --- | --- |
| Animaciones | `for_window [class=".*"] fade_in 0.2` + picom | Suave sin lag (8GB) |
| Workspaces dinámicos | `dynamic_i3status` o `i3ipc` python script | Auto-nombre por app |
| Scratchpad dev | `bindcode $mod+35 move scratchpad` (p para logs) | Logs compilación |
| IPC Hooks | `ipc "window::title" exec ~/scripts/notif.py` | Notificaciones custom |
| Autostart | `exec_always --no-startup-id picom & polybar &` | Inicio optimizado |

Copia configs de GitHub (ej. LukeSmithxyz), prueba en workspace vacío y mide RAM con `htop` para evitar sobrecarga en tu hardware. Reinicia i3 frecuentemente durante pruebas.

## Bibliografía

- https://unixporn-dots.github.io/#main_header
- https://www.youtube.com/watch?v=pXnOB9fE8Uo
- https://www.reddit.com/r/linuxmint/comments/1ks4amb/linux_mint_cinnamon_i3_configuration_you_can/
- https://www.youtube.com/watch?v=nvAPhnx0Z5Q
- https://www.vivaolinux.com.br/topico/Linux-Mint/i3-gaps-como-instalar
- https://www.youtube.com/watch?v=qCwOsjdL410
- http://i3wm.org/docs/userguide.html
