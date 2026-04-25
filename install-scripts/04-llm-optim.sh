#!/bin/bash

# --- 04-llm-optim.sh ---
# Optimización de Memoria y Térmica para Inferencia LLM

CNT="[\e[1;36mOPTIM\e[0m]"

echo -e "$CNT Configurando ZRAM (Crucial para 16GB RAM)..."

# 1. Instalar herramientas de optimización
sudo apt update
sudo apt install -y zram-config tlp thermald

# 2. Configuración de ZRAM (Intercambio en RAM comprimida)
# Esto permite que cuando el LLM llene los 16GB, el sistema use RAM comprimida 
# en lugar de escribir en el SSD/HDD, evitando el lag extremo.
sudo systemctl enable zram-config

# Ajustar 'swappiness' para que use ZRAM agresivamente
echo "vm.swappiness=100" | sudo tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 3. Configuración de Thermald y TLP para el L440
# Evita el Thermal Throttling agresivo durante la inferencia prolongada
echo -e "$CNT Optimizando gestión de energía y térmica..."
sudo systemctl enable tlp
sudo systemctl enable thermald
sudo tlp start

# 4. Crear el script lanzador con 'nice' para LLMs
# Este comando crea un acceso directo para ejecutar modelos con baja prioridad de CPU
# pero alta prioridad de respuesta para el sistema X11/i3.
echo -e "$CNT Creando lanzador optimizado 'run-llm'..."

cat <<EOF > ~/dotfile/scripts/run-llm.sh
#!/bin/bash
# Ejecuta procesos LLM con 'nice' para mantener i3-gaps responsivo
# Uso: ./run-llm.sh ollama serve (o cualquier binario)

echo "Lanzando proceso LLM con prioridad reducida para el sistema..."
# niceness 15 (de 19) da prioridad casi total al entorno gráfico
nice -n 15 "\$@"
EOF

chmod +x ~/dotfile/scripts/run-llm.sh

echo -e "$CNT Optimización LLM completada con éxito."