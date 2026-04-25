#!/bin/bash

# --- llm_monitor.sh ---
# Script para Polybar que monitorea procesos de Inferencia LLM
# Optimizado para ThinkPad L440

# Definir colores (compatibles con el formato de Polybar)
COLOR_ACTIVE="#bd93f9" # Morado (Primary)
COLOR_IDLE="#707880"   # Gris (Disabled)

# 1. Identificar procesos comunes de LLM
# Buscamos ollama, llama.cpp, local-ai o text-generation-webui
LLM_PROCESS=$(pgrep -x "ollama" || pgrep -f "llama" || pgrep -f "local-ai")

if [ -z "$LLM_PROCESS" ]; then
    # Si no hay procesos activos, mostrar estado inactivo
    echo "%{F$COLOR_IDLE}󱚧 IDLE%{F-}"
else
    # 2. Obtener estadísticas del proceso con mayor consumo (si hay varios)
    # ps -p: selecciona proceso, -o: formato de salida (cpu, memoria rss)
    STATS=$(ps -p "$LLM_PROCESS" -o %cpu,rss --no-headers | awk '{print $1,$2}')
    
    CPU_USAGE=$(echo "$STATS" | awk '{print $1}')
    RAM_RSS=$(echo "$STATS" | awk '{print $2}')
    
    # Convertir RAM de KB a GB para mejor lectura
    RAM_GB=$(echo "scale=1; $RAM_RSS / 1024 / 1024" | bc)

    # 3. Formatear salida para Polybar
    # Usamos iconos de Nerd Fonts (󱚣 es un icono de cerebro/IA)
    echo "%{F$COLOR_ACTIVE}󱚣 ${CPU_USAGE}% CPU | ${RAM_GB}GB%{F-}"
fi