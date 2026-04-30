# i3-gaps "Mint-Edition" para ThinkPad L440
Este repositorio contiene los dotfiles y scripts de automatización para transformar **Linux Mint 22.3 XFCE** en un entorno de alto rendimiento basado en **i3-gaps**, optimizado específicamente para la ejecución de modelos de lenguaje (LLM) en hardware limitado (Intel i5-4200M).

## Características Principales
- **Base:** Linux Mint 22.3 "Wilma" (X11).
- **Window Manager:** i3-gaps con soporte de gaps dinámicos.
- **Gestor de Sesión:** LightDM + WebKit2 Greeter.
- **Barra de Estado:** Polybar optimizada (bajo consumo de ciclos).
- **Optimización LLM:** Gestión agresiva de memoria y priorización de procesos.

## Estructura del Proyecto
El sistema se organiza por aplicación en la carpeta de configuración:

```text
~/dotfile/
├── install.sh              # Script principal de instalación
├── install-scripts/        # Scripts modulares (inspirado en JaKooLit)
│   ├── 00-dependencies.sh
│   ├── 01-i3-gaps.sh
│   ├── 02-lightdm-custom.sh
│   ├── 03-connectivity.sh
│   └── 04-llm-optiom.sh
├── assets/                 # Wallpapers, iconos y fuentes
└── dotfiles/               # Archivos de configuración (~/.config/)
    ├── i3/                 # Configuración de i3-gaps
    ├── polybar/            # Barra de estado dinámica
    ├── rofi/               # Launcher y menús
    ├── picom/              # Compositor para transparencias/sombras
    └── nvim/               # Configuración de Neovim
```

## Instalación Rápida
1. Clonar el repositorio:
```bash
git clone https://github.com/8a-ma/dotfile.git ~/dotfile
```

2. Ejecutar el orquestador:
```bash
cd ~/dotfile && chmod +x install.sh
./install.sh
```

# Optimización para LLM (Inferencia Local)
El sistema ha sido "tuneado" para permitir que un modelo como Llama-3-8B corra de forma fluida junto al entorno de escritorio.

## Gestión de Memoria y ZRAM
Para maximizar los 16GB de RAM física del L440, implementamos ZRAM con un ratio de 1:1.5.
- **Capacidad Virtual:** Convierte 16GB en ~24GB de espacio de trabajo mediante compresión en tiempo real.
- **Ventaja:** Evita el uso del SWAP en disco (lento), permitiendo que los modelos que exceden la RAM física no congelen el sistema.

## Estabilidad del Entorno (Prioridad de Procesos)
Para garantizar que el mouse y la interfaz no sufran lag durante la inferencia al 100% de CPU, el sistema utiliza un sistema de "niceness" inverso.

- **Uso Obligatorio:** Para lanzar modelos, utiliza siempre el script optimizado:
```bash
~/dotfile/scripts/run-llm.sh ollama run llama3
```
- **Funcionamiento:** Este comando asigna una prioridad reducida al LLM, asegurando que el servidor X y Polybar siempre tengan ciclos de CPU disponibles.

# Monitoreo y Widgets
La barra de Polybar incluye un módulo dedicado de monitoreo de LLM:
- **Script:** ``~/dotfile/scripts/llm_monitor.sh``
- **Función:** Muestra en tiempo real el consumo de recursos del proceso de inferencia y el estado de la carga térmica.
---
Para más detalles técnicos sobre la creación de widgets y ajustes finos del kernel, consulta:
[Documentación Técnica: Optimización y Widgets](./docs/optimization_tech.md)