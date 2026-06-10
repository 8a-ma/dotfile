```
# 1. Verificar que zram está disponible
modinfo zram

# 2. Instalar zram-tools (paquete correcto para Mint/Ubuntu)
sudo apt update
sudo apt install zram-tools

# 3. Configurar tamaño y algoritmo en /etc/default/zramswap
sudo cp -ri zram/zramswap /etc/default/zramswap

# 4. Configurar swappiness (valor válido: 60-100)
sudo cp -ri zram/60-swappiness.conf /etc/sysctl.d/60-swappiness.conf

# 5. Aplicar cambios
sudo sysctl --system

# 6. Verificar
zramctl
swapon --show
```
