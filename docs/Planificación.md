Esta es la planificación detallada para transformar tu **Linux Mint** en un entorno productivo con **i3-gaps** que emule la estética y fluidez de **Hyprland**.

Dado que usarás los tiers gratuitos de **Claude** y **Gemini**, la estrategia consiste en usar a Gemini como el "Arquitecto y Documentador" (contexto amplio, búsqueda de info) y a Claude como el "Ingeniero de Software" (lógica compleja, CSS para widgets y scripts de automatización).

---

## 🗓️ Cronograma de Hitos: Proyecto "Dotfiles Hypr-i3"

### Semana 1: Cimientos y Estructura del Repositorio
**Objetivo:** Tener el sistema base funcional, la jerarquía de carpetas estilo "Jakoolit" y el control de versiones.

| Tarea | Responsable | Acción Específica |
| :--- | :--- | :--- |
| **Diseño de Estructura** | **Gemini** | Crear el árbol de directorios `~/.config/` organizado por app y el esqueleto del `README.md`. |
| **Configuración Core i3** | **Gemini** | Generar el archivo `config` básico con binds de movimiento, espacios de trabajo y gaps. |
| **Gestión de Pantallas (VGA)** | **Claude** | Crear un script robusto en `bash` que use `xrandr` para detectar y configurar el VGA automáticamente al conectar. |
| **Repositorio Git** | **Gemini** | Estructurar el `.gitignore` y los comandos iniciales para el seguimiento de los dotfiles. |

---

### Semana 2: Estética y Capa de Interfaz (UX Hyprland)
**Objetivo:** Lograr el "look & feel" moderno con transparencias, bordes redondeados y una barra funcional.

| Tarea | Responsable | Acción Específica |
| :--- | :--- | :--- |
| **Compositor Picom** | **Claude** | Configurar `picom.conf` con animaciones, sombras y blur (optimizado para Intel HD 4600). |
| **Polybar / Waybar-like** | **Claude** | Programar el CSS y la configuración de Polybar para que parezca la barra superior de Hyprland. |
| **Launcher Rofi** | **Gemini** | Buscar temas de Rofi estilo "dracula" o "catppuccin" y ajustar el lanzador de aplicaciones. |
| **Integración de Red** | **Gemini** | Configurar el applet de `nm-applet` para que se vea integrado en la bandeja del sistema (estilo Mint). |

---

### Semana 3: Widgets Avanzados y Lógica (El "Heavy Programming")
**Objetivo:** Implementar los widgets de **Eww** y la lógica de estados de máquina para el sistema de billing/dev-blog que mencionaste.

| Tarea | Responsable | Acción Específica |
| :--- | :--- | :--- |
| **Dashboard Eww** | **Claude** | Escribir el código `yuck` y el CSS para un widget lateral de control de volumen, brillo y status de CPU/RAM. |
| **Session Manager** | **Claude** | Crear una pantalla de bloqueo/salida (Logout screen) personalizada y estética usando Rofi o Eww. |
| **Scripts de Automatización** | **Claude** | Crear scripts de Python/Bash para "Scratchpads" dinámicos (ventanas flotantes que aparecen/desaparecen). |
| **Widget de Notificaciones** | **Gemini** | Configurar `dunst` para que las notificaciones sigan el esquema de colores del sistema. |

---

### Semana 4: Instalador, Documentación y Optimización
**Objetivo:** Crear el `install.sh` y dejar el repositorio listo para que cualquier usuario (o tú mismo en una instalación limpia) lo use.

| Tarea | Responsable | Acción Específica |
| :--- | :--- | :--- |
| **Script install.sh** | **Claude** | Programar un script con manejo de errores que instale dependencias, cree backups y mueva los dotfiles. |
| **README.md Final** | **Gemini** | Redactar la guía completa, incluyendo la sección solicitada sobre "Cómo crear nuevos widgets". |
| **Optimización L440** | **Gemini** | Ajustes finales de TLP para batería y limpieza de servicios innecesarios en el inicio. |
| **Pruebas de Usuario** | **Gemini** | Generar una lista de verificación (checklist) para probar cada shortcut y funcionalidad. |

---

## 🛠️ Organización del Repositorio (Estilo Jakoolit)
El repositorio deberá seguir esta estructura para mantener el orden por aplicación:

```text
.
├── install.sh              # Script principal de instalación
├── README.md               # Guía de uso y creación de widgets
├── .config/
│   ├── i3/                 # Configuración principal y atajos
│   ├── polybar/            # Barra de estado
│   ├── rofi/               # Lanzador y menús
│   ├── picom/              # Animaciones y efectos
│   ├── eww/                # Widgets personalizados (Yuck/CSS)
│   ├── kitty/              # Terminal
│   └── scripts/            # Scripts de VGA, Audio, Brillo
└── .themes/                # Temas GTK e iconos
```

---

## 💡 Notas para la ejecución con IAs

### Uso de Claude (El Programador)
Cuando le pidas código a Claude, sé específico con las limitaciones de tu hardware:
> *"Genera un archivo picom.conf para i3-gaps en un Intel HD 4600. Necesito esquinas redondeadas (radius=10) y animaciones de apertura de ventana, pero sin que causen input lag al usar VS Code."*

### Uso de Gemini (El Organizador)
Úsalo para estructurar la documentación:
> *"Genera una sección para mi README.md en Markdown que explique paso a paso cómo añadir un nuevo widget en Eww, incluyendo la estructura de carpetas y cómo recargar la configuración sin reiniciar i3."*

### Consideración Técnica: Pantalla VGA
Para el requerimiento de compartir pantalla, solicitaremos a **Claude** en la **Semana 1** un script que use `arandr` para generar archivos `.sh` de configuración, los cuales vincularemos a un atajo de teclado en i3 (ej. `$mod+p`) para alternar rápidamente entre modos de espejo o pantalla extendida.

¿Deseas que comencemos con el esqueleto del `README.md` y la estructura de carpetas para la **Semana 1**?
